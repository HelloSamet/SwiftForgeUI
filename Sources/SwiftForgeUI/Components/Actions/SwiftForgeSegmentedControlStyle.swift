//
//  SwiftForgeSegmentedControlStyle.swift
//  SwiftForgeUI
//

import SwiftUI

/// A type that draws every ``SwiftForgeSegmentedControl``: its track, the
/// indicator behind the selected segment, and each segment's label.
///
/// The control keeps layout, motion, and accessibility: segments share the
/// width equally, the indicator slides to the selected segment, and
/// VoiceOver reads each segment's state and position. A style only decides
/// how those parts look:
///
/// ```swift
/// struct UnderlineSegmentedStyle: SwiftForgeSegmentedControlStyle {
///     @Environment(\.swiftForgeTheme) private var theme
///
///     func makeTrack() -> some View {
///         Rectangle().fill(theme.colors.borderSubtle).frame(height: theme.borders.thin)
///             .frame(maxHeight: .infinity, alignment: .bottom)
///     }
///
///     func makeIndicator() -> some View {
///         Rectangle().fill(theme.colors.accent.text).frame(height: theme.borders.thick)
///             .frame(maxHeight: .infinity, alignment: .bottom)
///     }
///
///     func makeSegment(configuration: SegmentConfiguration) -> some View {
///         configuration.label
///             .fontWeight(configuration.isSelected ? .semibold : .regular)
///             .foregroundStyle(configuration.isSelected ? theme.colors.accent.text : theme.colors.textSecondary)
///     }
/// }
/// ```
///
/// Keep the selected segment distinguishable without color — by weight,
/// an underline, or the indicator's shape.
@MainActor
@preconcurrency
public protocol SwiftForgeSegmentedControlStyle: DynamicProperty {

    /// The track behind all segments.
    associatedtype Track: View
    /// The indicator behind the selected segment.
    associatedtype Indicator: View
    /// A segment's label.
    associatedtype Segment: View

    /// The properties of a segment.
    typealias SegmentConfiguration = SwiftForgeSegmentConfiguration

    /// Creates the track behind all segments, sized to the whole control.
    @ViewBuilder func makeTrack() -> Track

    /// Creates the indicator, sized to the selected segment.
    @ViewBuilder func makeIndicator() -> Indicator

    /// Creates a segment's label.
    @ViewBuilder func makeSegment(configuration: SegmentConfiguration) -> Segment
}

/// The properties of a segment, passed to a ``SwiftForgeSegmentedControlStyle``.
public struct SwiftForgeSegmentConfiguration {

    /// A type-erased label of a segment.
    public struct Label: View {
        let content: AnyView  // swiftforge-lint: allow (ADR-0015)
        /// The content and behavior of the view.
        public var body: some View { content }
    }

    /// The segment's label.
    public let label: Label
    /// Whether the segment is selected.
    public let isSelected: Bool
    /// Whether the segment is being pressed.
    public let isPressed: Bool
}

/// The style's parts, erased once per render.
struct SwiftForgeResolvedSegmentedStyle {
    let track: AnyView  // swiftforge-lint: allow (ADR-0015)
    let indicator: AnyView  // swiftforge-lint: allow (ADR-0015)
    let segment: (SwiftForgeSegmentConfiguration) -> AnyView  // swiftforge-lint: allow (ADR-0015)
}

extension SwiftForgeSegmentedControlStyle {

    func resolved() -> SwiftForgeResolvedSegmentedStyle {
        SwiftForgeResolvedSegmentedStyle(
            track: AnyView(SwiftForgeStyleHost(style: self) { $0.makeTrack() }),  // swiftforge-lint: allow (ADR-0015)
            indicator: AnyView(SwiftForgeStyleHost(style: self) { $0.makeIndicator() }),  // swiftforge-lint: allow (ADR-0015)
            segment: { configuration in
                let host = SwiftForgeStyleHost(style: self) { $0.makeSegment(configuration: configuration) }
                return AnyView(host)  // swiftforge-lint: allow (ADR-0015)
            }
        )
    }
}

/// Hosts a style in a view, so its `DynamicProperty` wrappers are updated
/// before one of its methods runs.
struct SwiftForgeStyleHost<Style: DynamicProperty, Content: View>: View {
    let style: Style
    let content: (Style) -> Content

    var body: some View {
        content(style)
    }
}

// MARK: - Automatic style

/// The default segmented control style: segments on a muted track, the
/// selected one on a raised indicator with a semibold title.
public struct SwiftForgeAutomaticSegmentedControlStyle: SwiftForgeSegmentedControlStyle {

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.swiftForgeIncreasedContrast) private var increasedContrast

    /// Creates the default segmented control style.
    nonisolated public init() {}

    /// Creates the muted track.
    public func makeTrack() -> some View {
        let shape = theme.radius.shape(trackRadius)
        return shape.fill(theme.colors.fillMuted)
            .overlay {
                if let width = tokens.borderWidth {
                    shape.strokeBorder(tokens.borderColor ?? theme.colors.borderStrong, lineWidth: width)
                }
            }
    }

    /// Creates the raised indicator, outlined with Increase Contrast on.
    public func makeIndicator() -> some View {
        let shape = theme.radius.shape(SwiftForgeRadius.concentric(outer: trackRadius, inset: tokens.indicatorInset))
        return shape.fill(theme.colors.surfaceRaised)
            .swiftForgeShadow(theme.elevation[tokens.indicatorElevation])
            .overlay {
                if let width = indicatorBorderWidth {
                    shape.strokeBorder(tokens.borderColor ?? theme.colors.borderStrong, lineWidth: width)
                }
            }
    }

    /// Creates a segment's label: semibold and primary when selected.
    public func makeSegment(configuration: SegmentConfiguration) -> some View {
        configuration.label
            .font(
                theme.typography.font(theme.typography.controlLabelSmall.weight(configuration.isSelected ? .semibold : .regular))
            )
            .foregroundStyle(configuration.isSelected ? theme.colors.textPrimary : theme.colors.textSecondary)
            .opacity(configuration.isPressed ? theme.opacity.pressedContent : 1)
    }

    private var tokens: SwiftForgeSegmentedControlTokens { theme.components.segmentedControl }
    private var trackRadius: CGFloat { tokens.cornerRadius ?? theme.radius.control }

    private var indicatorBorderWidth: CGFloat? {
        tokens.borderWidth ?? (increasedContrast ? theme.borders.thin : nil)
    }
}

extension SwiftForgeSegmentedControlStyle where Self == SwiftForgeAutomaticSegmentedControlStyle {

    /// The default segmented control style, drawn from the theme's tokens.
    public static var automatic: Self { SwiftForgeAutomaticSegmentedControlStyle() }
}

// MARK: - Environment

private struct SwiftForgeSegmentedControlStyleKey: EnvironmentKey {
    // Computed: styles aren't `Sendable`, like SwiftUI's own styles.
    static var defaultValue: any SwiftForgeSegmentedControlStyle { SwiftForgeAutomaticSegmentedControlStyle() }
}

extension EnvironmentValues {
    var swiftForgeSegmentedControlStyle: any SwiftForgeSegmentedControlStyle {
        get { self[SwiftForgeSegmentedControlStyleKey.self] }
        set { self[SwiftForgeSegmentedControlStyleKey.self] = newValue }
    }
}

extension View {

    /// Sets the style of SwiftForgeUI segmented controls beneath this view.
    public func swiftForgeSegmentedControlStyle<S: SwiftForgeSegmentedControlStyle>(_ style: S) -> some View {
        environment(\.swiftForgeSegmentedControlStyle, style)
    }
}
