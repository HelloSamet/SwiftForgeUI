//
//  SwiftForgeSegmentedControl.swift
//  SwiftForgeUI
//

import SwiftUI

/// A row of two to five mutually exclusive segments, with an indicator that
/// slides to the selected one.
///
/// ```swift
/// SwiftForgeSegmentedControl("Period", selection: $period, options: Period.allCases) { period in
///     Text(period.title)
/// }
/// ```
///
/// Segments can show text, an icon, or both:
///
/// ```swift
/// SwiftForgeSegmentedControl("View", selection: $layout, options: [.list, .grid]) { layout in
///     Label(layout.title, systemImage: layout.symbol)
/// }
/// ```
///
/// Segments share the width equally. When a title doesn't fit its share —
/// at large text sizes — the row scrolls horizontally instead, so titles
/// never truncate or break inside a word. The selected segment sits on a raised indicator
/// with a semibold title, so selection doesn't rely on color. The indicator
/// slides with the theme's motion, and crossfades with Reduce Motion on.
/// Every segment keeps a 44-pt hit area; set the visual height with
/// `controlSize(_:)`.
///
/// The title isn't shown: VoiceOver reads it for the group, and each segment
/// as a button with its state and position, such as "Month, selected,
/// button, 2 of 3".
///
/// - Do: use a segmented control to switch between views of the same content.
/// - Don't: use one for actions, or for more than five options; use a
///   ``SwiftForgePicker`` for longer lists.
public struct SwiftForgeSegmentedControl<Value: Hashable, Label: View>: View {

    private var title: Text
    @Binding private var selection: Value
    private let options: [Value]
    private let label: (Value) -> Label

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.swiftForgeSegmentedControlStyle) private var style
    @SwiftForgeAccessibilityContext private var accessibility
    @State private var availableWidth: CGFloat = 0

    /// Creates a segmented control.
    ///
    /// - Parameters:
    ///   - titleKey: A title that describes the choice, read by VoiceOver.
    ///   - selection: The selected option.
    ///   - options: Two to five options, in display order.
    ///   - label: A label for each option, typically `Text` or a `Label`.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Value>,
        options: [Value],
        @ViewBuilder label: @escaping (Value) -> Label
    ) {
        title = Text(titleKey)
        _selection = selection
        self.options = options
        self.label = label
    }

    /// Creates a segmented control with a title that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Value>,
        options: [Value],
        @ViewBuilder label: @escaping (Value) -> Label
    ) {
        self.title = Text(title)
        _selection = selection
        self.options = options
        self.label = label
    }

    /// The content and behavior of the view.
    public var body: some View {
        // Segments fill the width equally when every title fits its share;
        // otherwise the row grows past it and scrolls, so titles never break
        // inside a word. One structure for both keeps segments' identity as
        // text size changes.
        ScrollView(.horizontal, showsIndicators: false) {
            segments
                .frame(minWidth: availableWidth)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .onGeometryChange(for: CGFloat.self) {
            $0.size.width
        } action: {
            availableWidth = $0
        }
        .opacity(isEnabled ? 1 : theme.opacity.disabled)
        .swiftForgeHaptic(trigger: options.firstIndex(of: selection)) { _, _ in .selection }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }

    private var segments: some View {
        let parts = style.resolved()
        let selectedIndex = options.firstIndex(of: selection)
        return SwiftForgeSegmentLayout(selectedIndex: selectedIndex, inset: tokens.indicatorInset) {
            parts.indicator
                .opacity(selectedIndex == nil ? 0 : 1)
                .accessibilityHidden(true)
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                Button {
                    selection = option
                } label: {
                    label(option)
                }
                .buttonStyle(
                    SwiftForgeSegmentButtonStyle(
                        isSelected: index == selectedIndex, segment: parts.segment, height: height,
                        cornerRadius: indicatorRadius)
                )
                .accessibilityAddTraits(index == selectedIndex ? .isSelected : [])
                .accessibilityValue(SwiftForgeStrings.position(index + 1, of: options.count))
            }
        }
        .padding(tokens.indicatorInset)
        .background { parts.track }
        .animation(theme.motion.standard.animation(reduceMotion: accessibility.reduceMotion), value: selectedIndex)
    }

    private var tokens: SwiftForgeSegmentedControlTokens { theme.components.segmentedControl }

    /// The segment's visual height: the control height minus the track inset.
    private var height: CGFloat {
        theme.sizes.controlHeight(for: controlSize) - 2 * tokens.indicatorInset
    }

    private var indicatorRadius: CGFloat {
        SwiftForgeRadius.concentric(outer: tokens.cornerRadius ?? theme.radius.control, inset: tokens.indicatorInset)
    }
}

/// Lays out segments at equal widths and places the indicator — the first
/// subview — behind the selected one. Moving the indicator is a layout
/// change, so it animates with the surrounding animation.
struct SwiftForgeSegmentLayout: Layout {

    let selectedIndex: Int?
    let inset: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let segments = subviews.dropFirst()
        guard !segments.isEmpty else { return .zero }
        let count = CGFloat(segments.count)
        let width = proposal.width ?? segments.map { $0.sizeThatFits(.unspecified).width }.max().map { $0 * count } ?? 0
        let segmentWidth = width / count
        let height = segments.map { $0.sizeThatFits(ProposedViewSize(width: segmentWidth, height: nil)).height }.max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let segments = Array(subviews.dropFirst())
        guard !segments.isEmpty, let indicator = subviews.first else { return }
        let segmentWidth = bounds.width / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            segment.place(
                at: CGPoint(x: bounds.minX + CGFloat(index) * segmentWidth, y: bounds.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: segmentWidth, height: bounds.height))
        }
        let index = min(selectedIndex ?? 0, segments.count - 1)
        indicator.place(
            at: CGPoint(x: bounds.minX + CGFloat(index) * segmentWidth, y: bounds.minY),
            anchor: .topLeading,
            proposal: ProposedViewSize(width: segmentWidth, height: bounds.height))
    }
}

/// A segment's button: the style's label, centered, with the hit area,
/// focus ring, and press state every segment gets.
private struct SwiftForgeSegmentButtonStyle: ButtonStyle {

    let isSelected: Bool
    let segment: (SwiftForgeSegmentConfiguration) -> AnyView  // swiftforge-lint: allow (ADR-0015)
    let height: CGFloat
    let cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        SwiftForgeSegmentButton(
            label: segment(
                SwiftForgeSegmentConfiguration(
                    label: .init(content: AnyView(configuration.label)),  // swiftforge-lint: allow (ADR-0015)
                    isSelected: isSelected,
                    isPressed: configuration.isPressed)),
            height: height,
            cornerRadius: cornerRadius)
    }
}

private struct SwiftForgeSegmentButton: View {

    let label: AnyView  // swiftforge-lint: allow (ADR-0015)
    let height: CGFloat
    let cornerRadius: CGFloat

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        label
            .labelStyle(SwiftForgeSegmentLabelStyle(spacing: theme.spacing.xxs))
            .multilineTextAlignment(.center)
            .padding(.horizontal, theme.spacing.xs)
            .padding(.vertical, theme.spacing.xxs)
            .frame(maxWidth: .infinity, minHeight: height)
            .contentShape(Rectangle())
            .swiftForgeFocusRing(isFocused, cornerRadius: cornerRadius)
            // The 44-pt hit area reaches past a shorter track without making
            // the track taller.
            .frame(minHeight: theme.sizes.minimumHitTarget)
            .padding(.vertical, -max(0, theme.sizes.minimumHitTarget - height) / 2)
    }
}

private struct SwiftForgeSegmentLabelStyle: LabelStyle {
    let spacing: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}

// MARK: - Previews

private enum Period: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

private struct SegmentedPreview: View {
    @State private var period = Period.week
    @State private var layout = "List"

    var body: some View {
        VStack(spacing: 24) {
            SwiftForgeSegmentedControl("Period", selection: $period, options: Period.allCases) { Text($0.rawValue) }
            SwiftForgeSegmentedControl("Layout", selection: $layout, options: ["List", "Grid"]) { option in
                Label(option, systemImage: option == "List" ? "list.bullet" : "square.grid.2x2")
            }
            .controlSize(.small)
            SwiftForgeSegmentedControl("Disabled", selection: .constant("A"), options: ["A", "B"]) { Text($0) }
                .disabled(true)
        }
        .padding()
    }
}

#Preview("Segmented control") { SegmentedPreview() }

#Preview("Dark, AX5, RTL") {
    SegmentedPreview()
        .environment(\.dynamicTypeSize, .accessibility5)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SwiftForgeSegmentedControl("Period", selection: .constant(Period.month), options: Period.allCases) {
            Text($0.rawValue)
        }
    }
}
