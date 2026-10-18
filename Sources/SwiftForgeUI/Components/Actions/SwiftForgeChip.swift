//
//  SwiftForgeChip.swift
//  SwiftForgeUI
//

import SwiftUI

/// A compact element that represents a choice, a filter, an action, or an
/// entered item.
///
/// A chip is one of three kinds, chosen by its initializer:
///
/// ```swift
/// // Selectable: a filter or choice the person turns on and off.
/// SwiftForgeChip("Vegan", systemImage: "leaf", isSelected: $veganOnly)
///
/// // Removable: an item the person entered, such as a recipient.
/// SwiftForgeChip("Ada Lovelace", onRemove: { recipients.remove("Ada Lovelace") })
///
/// // Action: a suggestion that does something right away.
/// SwiftForgeChip("Add to calendar", systemImage: "calendar.badge.plus", action: addToCalendar)
/// ```
///
/// To offer a set of chips, use ``SwiftForgeChipGroup``.
///
/// A selected chip fills with the tone, and its icon becomes a checkmark, so
/// selection never relies on color. Chips are 32 pt tall at the default
/// size — 44 pt with `controlSize(.large)` — and keep a 44-pt hit area.
///
/// VoiceOver reads a selectable chip as a toggle with its state, an action
/// chip as a button, and a removable chip's title followed by its own
/// "Remove" button, which Full Keyboard Access can reach too.
///
/// - Do: keep chip titles to one or two words.
/// - Don't: use a chip for a screen's main action; use a button.
///
/// The chip's appearance comes from the ``SwiftForgeChipStyle`` in the
/// environment.
public struct SwiftForgeChip<Label: View>: View {

    private enum Kind {
        case selectable(Binding<Bool>)
        case action(@MainActor () -> Void)
        case removable(title: Text, onRemove: @MainActor () -> Void)
    }

    private let kind: Kind
    private let tone: SwiftForgeTone
    private let label: Label

    @Environment(\.swiftForgeChipStyle) private var style
    @Environment(\.swiftForgeTheme) private var theme

    /// Creates a selectable chip with a custom label.
    ///
    /// - Parameters:
    ///   - isSelected: Whether the chip is selected.
    ///   - tone: The color of the selected chip. Defaults to the accent.
    ///   - label: The chip's label, typically a `Label`.
    public init(isSelected: Binding<Bool>, tone: SwiftForgeTone = .accent, @ViewBuilder label: () -> Label) {
        kind = .selectable(isSelected)
        self.tone = tone
        self.label = label()
    }

    /// Creates an action chip with a custom label.
    ///
    /// - Parameters:
    ///   - tone: The chip's tone. Defaults to the accent.
    ///   - action: What the chip does when tapped.
    ///   - label: The chip's label, typically a `Label`.
    public init(tone: SwiftForgeTone = .accent, action: @escaping @MainActor () -> Void, @ViewBuilder label: () -> Label) {
        kind = .action(action)
        self.tone = tone
        self.label = label()
    }

    /// The content and behavior of the view.
    public var body: some View {
        switch kind {
        case .selectable(let isSelected):
            Button {
                isSelected.wrappedValue.toggle()
            } label: {
                label
            }
            .buttonStyle(SwiftForgeChipButtonStyle(style: style, isSelected: isSelected.wrappedValue, tone: tone))
            .accessibilityAddTraits(isSelected.wrappedValue ? [.isToggle, .isSelected] : .isToggle)
            .swiftForgeHaptic(trigger: isSelected.wrappedValue) { _, _ in .selection }
        case .action(let action):
            Button(action: action) {
                label
            }
            .buttonStyle(SwiftForgeChipButtonStyle(style: style, isSelected: false, tone: tone))
        case .removable(let title, let onRemove):
            SwiftForgeRemovableChip(style: style, label: label, title: title, tone: tone, onRemove: onRemove)
        }
    }
}

extension SwiftForgeChip where Label == SwiftUI.Label<Text, Image?> {

    /// Creates a selectable chip with a localized title and an optional symbol.
    ///
    /// - Parameters:
    ///   - titleKey: The chip's title.
    ///   - systemImage: An SF Symbol shown before the title.
    ///   - isSelected: Whether the chip is selected.
    ///   - tone: The color of the selected chip. Defaults to the accent.
    public init(
        _ titleKey: LocalizedStringKey, systemImage: String? = nil, isSelected: Binding<Bool>, tone: SwiftForgeTone = .accent
    ) {
        self.init(isSelected: isSelected, tone: tone) { Self.makeLabel(Text(titleKey), systemImage: systemImage) }
    }

    /// Creates an action chip with a localized title and an optional symbol.
    public init(
        _ titleKey: LocalizedStringKey, systemImage: String? = nil, tone: SwiftForgeTone = .accent,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(tone: tone, action: action) { Self.makeLabel(Text(titleKey), systemImage: systemImage) }
    }

    /// Creates a removable chip with a localized title and an optional symbol.
    ///
    /// - Parameters:
    ///   - titleKey: The chip's title.
    ///   - systemImage: An SF Symbol shown before the title.
    ///   - tone: The chip's tone. Defaults to the accent.
    ///   - onRemove: Removes the chip's item. The chip doesn't hide itself.
    public init(
        _ titleKey: LocalizedStringKey, systemImage: String? = nil, tone: SwiftForgeTone = .accent,
        onRemove: @escaping @MainActor () -> Void
    ) {
        kind = .removable(title: Text(titleKey), onRemove: onRemove)
        self.tone = tone
        label = Self.makeLabel(Text(titleKey), systemImage: systemImage)
    }

    /// Creates a selectable chip with a title that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S, systemImage: String? = nil, isSelected: Binding<Bool>, tone: SwiftForgeTone = .accent
    ) {
        self.init(isSelected: isSelected, tone: tone) { Self.makeLabel(Text(title), systemImage: systemImage) }
    }

    /// Creates an action chip with a title that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S, systemImage: String? = nil, tone: SwiftForgeTone = .accent, action: @escaping @MainActor () -> Void
    ) {
        self.init(tone: tone, action: action) { Self.makeLabel(Text(title), systemImage: systemImage) }
    }

    /// Creates a removable chip with a title that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S, systemImage: String? = nil, tone: SwiftForgeTone = .accent, onRemove: @escaping @MainActor () -> Void
    ) {
        kind = .removable(title: Text(title), onRemove: onRemove)
        self.tone = tone
        label = Self.makeLabel(Text(title), systemImage: systemImage)
    }

    private static func makeLabel(_ title: Text, systemImage: String?) -> SwiftUI.Label<Text, Image?> {
        SwiftUI.Label {
            title
        } icon: {
            systemImage.map { Image(systemName: $0) }
        }
    }
}

/// Lays out a chip's label with the theme's icon spacing. A selected chip
/// hides its icon: the style shows a checkmark in its place.
private struct SwiftForgeChipLabelStyle: LabelStyle {

    let isSelected: Bool
    let spacing: CGFloat
    let iconPlacement: SwiftForgeIconPlacement

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            if iconPlacement == .leading { icon(configuration) }
            configuration.title
            if iconPlacement == .trailing { icon(configuration) }
        }
    }

    @ViewBuilder
    private func icon(_ configuration: Configuration) -> some View {
        if !isSelected {
            configuration.icon
        }
    }
}

/// Draws a tappable chip through the chip style, adding the hit area and
/// focus ring every chip gets.
private struct SwiftForgeChipButtonStyle: ButtonStyle {

    let style: any SwiftForgeChipStyle
    let isSelected: Bool
    let tone: SwiftForgeTone

    func makeBody(configuration: Configuration) -> some View {
        SwiftForgeChipChrome(
            style: style,
            label: configuration.label,
            removeButton: nil,
            isSelected: isSelected,
            isPressed: configuration.isPressed,
            tone: tone
        )
    }
}

private struct SwiftForgeRemovableChip<Label: View>: View {

    let style: any SwiftForgeChipStyle
    let label: Label
    let title: Text
    let tone: SwiftForgeTone
    let onRemove: @MainActor () -> Void

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.controlSize) private var controlSize

    var body: some View {
        SwiftForgeChipChrome(
            style: style,
            label: label,
            removeButton: AnyView(removeButton),  // swiftforge-lint: allow (ADR-0015)
            isSelected: false,
            isPressed: false,
            tone: tone
        )
        .accessibilityElement(children: .contain)
    }

    private var removeButton: some View {
        Button(action: onRemove) {
            Image(systemName: "xmark")
                .font(theme.typography.font(theme.typography.caption1).weight(.bold))
                .frame(minWidth: theme.sizes.minimumHitTarget, minHeight: theme.sizes.minimumHitTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(SwiftForgeStrings.remove(title))
        // The 44-pt hit area extends past the chip's outline instead of
        // making the chip taller and wider than its siblings.
        .padding(.vertical, -verticalOverhang)
        .padding(.horizontal, -theme.spacing.xs)
    }

    /// How far the remove button's hit area reaches above and below the
    /// default chip's outline.
    private var verticalOverhang: CGFloat {
        let tokens = theme.components.chip
        let height = tokens.height ?? theme.sizes.controlHeight(for: controlSize == .large ? .regular : .small)
        return max(0, (theme.sizes.minimumHitTarget - height) / 2 + theme.spacing.xxs)
    }
}

/// What every chip shares regardless of style: label layout, the 44-pt hit
/// area, the focus ring, and the disabled state.
private struct SwiftForgeChipChrome<Label: View>: View {

    let style: any SwiftForgeChipStyle
    let label: Label
    let removeButton: AnyView?  // swiftforge-lint: allow (ADR-0015)
    let isSelected: Bool
    let isPressed: Bool
    let tone: SwiftForgeTone

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.swiftForgeIconPlacement) private var iconPlacement
    @SwiftForgeAccessibilityContext private var accessibility

    var body: some View {
        style.resolvedBody(
            configuration: SwiftForgeChipStyleConfiguration(
                label: .init(
                    content: AnyView(  // swiftforge-lint: allow (ADR-0015)
                        label.labelStyle(
                            SwiftForgeChipLabelStyle(
                                isSelected: isSelected, spacing: theme.spacing.xxs, iconPlacement: iconPlacement)))),
                removeButton: removeButton.map { .init(content: $0) },
                isSelected: isSelected,
                isPressed: isPressed,
                tone: tone
            )
        )
        .swiftForgeFocusRing(isFocused, cornerRadius: theme.components.chip.cornerRadius ?? theme.radius.controlSmall)
        .frame(minHeight: theme.sizes.minimumHitTarget)
        .contentShape(Rectangle())
        .opacity(isEnabled ? 1 : theme.opacity.disabled)
        .animation(theme.motion.fast.animation(reduceMotion: accessibility.reduceMotion), value: isSelected)
    }
}
