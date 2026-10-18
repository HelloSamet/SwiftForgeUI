//
//  SwiftForgeChipStyle.swift
//  SwiftForgeUI
//

import SwiftUI

/// A type that draws every ``SwiftForgeChip``.
///
/// The default style, ``SwiftForgeAutomaticChipStyle``, draws chips from the
/// theme's ``SwiftForgeChipTokens``. Write your own to change their shape or
/// layout, and apply it with ``SwiftUICore/View/swiftForgeChipStyle(_:)``:
///
/// ```swift
/// struct UnderlinedChipStyle: SwiftForgeChipStyle {
///     @Environment(\.swiftForgeTheme) private var theme
///
///     func makeBody(configuration: Configuration) -> some View {
///         HStack(spacing: theme.spacing.xxs) {
///             configuration.label
///             configuration.removeButton
///         }
///         .padding(.vertical, theme.spacing.xxs)
///         .overlay(alignment: .bottom) {
///             if configuration.isSelected {
///                 Rectangle().fill(theme.colors.accent.text).frame(height: theme.borders.thick)
///             }
///         }
///         .opacity(configuration.isPressed ? theme.opacity.pressedContent : 1)
///     }
/// }
/// ```
///
/// Chips keep their accessibility, hit area, and focus ring whatever the
/// style. A selected chip's label hides its icon; show something in its
/// place, as the default style's checkmark does, so selection never relies
/// on color alone.
@MainActor
@preconcurrency
public protocol SwiftForgeChipStyle: DynamicProperty {

    /// A view that represents the body of a chip.
    associatedtype Body: View

    /// The properties of a chip.
    typealias Configuration = SwiftForgeChipStyleConfiguration

    /// Creates a view that represents the body of a chip.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// The properties of a chip, passed to a ``SwiftForgeChipStyle``.
public struct SwiftForgeChipStyleConfiguration {

    /// A type-erased label of a chip: its icon, if any, and title.
    public struct Label: View {
        let content: AnyView  // swiftforge-lint: allow (ADR-0015)
        /// The content and behavior of the view.
        public var body: some View { content }
    }

    /// A type-erased remove button.
    public struct RemoveButton: View {
        let content: AnyView  // swiftforge-lint: allow (ADR-0015)
        /// The content and behavior of the view.
        public var body: some View { content }
    }

    /// The chip's label.
    public let label: Label

    /// The button that removes the chip, or `nil` if it can't be removed.
    public let removeButton: RemoveButton?

    /// Whether the chip is selected.
    public let isSelected: Bool

    /// Whether the chip is being pressed.
    public let isPressed: Bool

    /// The chip's tone.
    public let tone: SwiftForgeTone
}

extension SwiftForgeChipStyle {

    /// Renders this style, opening the existential stored in the environment.
    func resolvedBody(configuration: Configuration) -> AnyView {  // swiftforge-lint: allow (ADR-0015)
        AnyView(SwiftForgeResolvedChipStyle(style: self, configuration: configuration))  // swiftforge-lint: allow (ADR-0015)
    }
}

private struct SwiftForgeResolvedChipStyle<Style: SwiftForgeChipStyle>: View {
    let style: Style
    let configuration: SwiftForgeChipStyleConfiguration

    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Automatic style

/// The default chip style: an outlined chip that fills with the tone's
/// subtle color and shows a checkmark when selected.
public struct SwiftForgeAutomaticChipStyle: SwiftForgeChipStyle {

    /// Creates the default chip style.
    nonisolated public init() {}

    /// Creates a view that represents the body of a chip.
    public func makeBody(configuration: Configuration) -> some View {
        SwiftForgeAutomaticChipBody(configuration: configuration)
    }
}

extension SwiftForgeChipStyle where Self == SwiftForgeAutomaticChipStyle {

    /// The default chip style, drawn from the theme's chip tokens.
    public static var automatic: Self { SwiftForgeAutomaticChipStyle() }
}

private struct SwiftForgeAutomaticChipBody: View {

    let configuration: SwiftForgeChipStyleConfiguration

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.controlSize) private var controlSize

    var body: some View {
        let shape = theme.radius.shape(cornerRadius)
        HStack(spacing: theme.spacing.xxs) {
            if configuration.isSelected {
                Image(systemName: "checkmark")
                    .accessibilityHidden(true)
            }
            configuration.label
            configuration.removeButton
        }
        .font(theme.typography.font(theme.typography.controlLabelSmall))
        .foregroundStyle(configuration.isSelected ? colors.text : theme.colors.textPrimary)
        .padding(.leading, theme.spacing.sm)
        .padding(.trailing, configuration.removeButton == nil ? theme.spacing.sm : theme.spacing.xs)
        .padding(.vertical, theme.spacing.xxs)
        .frame(minHeight: height)
        .background(configuration.isSelected ? colors.subtle : theme.colors.surface, in: shape)
        .overlay {
            shape.strokeBorder(borderColor, lineWidth: tokens.borderWidth ?? theme.borders.thin)
        }
        .overlay {
            if configuration.isPressed {
                shape.fill(theme.colors.pressedOverlay)
            }
        }
    }

    private var tokens: SwiftForgeChipTokens { theme.components.chip }
    private var colors: SwiftForgeToneColors { theme.colors[configuration.tone] }

    private var cornerRadius: CGFloat { tokens.cornerRadius ?? theme.radius.controlSmall }

    private var height: CGFloat {
        tokens.height ?? theme.sizes.controlHeight(for: controlSize == .large ? .regular : .small)
    }

    private var borderColor: SwiftForgeColor {
        configuration.isSelected ? colors.text : tokens.borderColor ?? theme.colors.borderStrong
    }
}

// MARK: - Environment

private struct SwiftForgeChipStyleKey: EnvironmentKey {
    // Computed: chip styles aren't `Sendable`, like SwiftUI's own styles.
    static var defaultValue: any SwiftForgeChipStyle { SwiftForgeAutomaticChipStyle() }
}

extension EnvironmentValues {
    var swiftForgeChipStyle: any SwiftForgeChipStyle {
        get { self[SwiftForgeChipStyleKey.self] }
        set { self[SwiftForgeChipStyleKey.self] = newValue }
    }
}

extension View {

    /// Sets the style of SwiftForgeUI chips beneath this view.
    public func swiftForgeChipStyle<S: SwiftForgeChipStyle>(_ style: S) -> some View {
        environment(\.swiftForgeChipStyle, style)
    }
}
