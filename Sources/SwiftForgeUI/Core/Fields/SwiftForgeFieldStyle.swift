//
//  SwiftForgeFieldStyle.swift
//  SwiftForgeUI
//

import SwiftUI

/// A type that arranges and draws every SwiftForgeUI form field: text
/// fields, secure fields, and fields you build with ``SwiftForgeFieldContainer``.
///
/// The default style, ``SwiftForgeAutomaticFieldStyle``, draws the input area
/// as the theme's ``SwiftForgeFieldTokens/style`` says. To change how fields
/// look beyond what tokens allow, write a style and apply it to a hierarchy
/// with ``SwiftUICore/View/swiftForgeFieldStyle(_:)``:
///
/// ```swift
/// struct FloatingCardFieldStyle: SwiftForgeFieldStyle {
///     @Environment(\.swiftForgeTheme) private var theme
///
///     func makeBody(configuration: Configuration) -> some View {
///         VStack(alignment: .leading, spacing: theme.spacing.xxs) {
///             configuration.label
///                 .swiftForgeTextStyle(\.caption1)
///                 .foregroundStyle(configuration.isFocused ? theme.colors.accent.text : theme.colors.textSecondary)
///             configuration.content
///             if let message = configuration.message {
///                 message
///             }
///         }
///         .padding(theme.spacing.sm)
///         .swiftForgeSurface(.raised)
///     }
/// }
///
/// Form()
///     .swiftForgeFieldStyle(FloatingCardFieldStyle())
/// ```
///
/// Styles control appearance only. Fields keep their accessibility
/// whatever the style: the label stays the VoiceOver label, messages are
/// read and announced, and the disabled state dims the whole field.
@MainActor
@preconcurrency
public protocol SwiftForgeFieldStyle: DynamicProperty {

    /// A view that represents the body of a field.
    associatedtype Body: View

    /// The properties of a field.
    typealias Configuration = SwiftForgeFieldStyleConfiguration

    /// Creates a view that represents the body of a field.
    ///
    /// - Parameter configuration: The properties of the field.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// The properties of a SwiftForgeUI form field, passed to a ``SwiftForgeFieldStyle``.
public struct SwiftForgeFieldStyleConfiguration {

    /// A type-erased label of a field.
    public struct Label: View {
        let content: AnyView  // swiftforge-lint: allow (ADR-0015)
        /// The content and behavior of the view.
        public var body: some View { content }
    }

    /// A type-erased input area of a field: its accessories and editable
    /// control, already inset by the theme's content padding.
    public struct Content: View {
        let content: AnyView  // swiftforge-lint: allow (ADR-0015)
        /// The content and behavior of the view.
        public var body: some View { content }
    }

    /// A type-erased message row of a field: the state's icon and message,
    /// and the character counter.
    public struct Message: View {
        let content: AnyView  // swiftforge-lint: allow (ADR-0015)
        /// The content and behavior of the view.
        public var body: some View { content }
    }

    /// The field's title. It's hidden from VoiceOver, which reads it as the
    /// editable control's label instead. Set its font and color.
    public let label: Label

    /// The localized "Optional" note for fields marked with
    /// ``SwiftUICore/View/swiftForgeOptionalField(_:)``, or `nil`.
    public let optionalNote: Text?

    /// The input area's content. Draw the field's background, border, and
    /// minimum height around it.
    public let content: Content

    /// The message row, already styled for ``state``, or `nil` when the field
    /// has neither a message nor a character counter.
    public let message: Message?

    /// The validation state.
    public let state: SwiftForgeFieldState

    /// Whether the editable control has keyboard focus.
    public let isFocused: Bool
}

extension SwiftForgeFieldStyle {

    /// Renders this style, opening the existential stored in the environment.
    func resolvedBody(configuration: Configuration) -> AnyView {  // swiftforge-lint: allow (ADR-0015)
        AnyView(SwiftForgeResolvedFieldStyle(style: self, configuration: configuration))  // swiftforge-lint: allow (ADR-0015)
    }
}

/// Hosts a style in a view, so its `DynamicProperty` wrappers, such as
/// `@Environment`, are updated before `makeBody(configuration:)` runs.
private struct SwiftForgeResolvedFieldStyle<Style: SwiftForgeFieldStyle>: View {
    let style: Style
    let configuration: SwiftForgeFieldStyleConfiguration

    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Automatic style

/// The default field style: a label above an input area drawn as the
/// theme's ``SwiftForgeFieldTokens/style`` says — outlined, filled, or
/// underlined — with the message row below.
///
/// The outline turns the focus color and thickens while editing, and the
/// danger or success color for those states, so the state never relies on
/// the message's color alone.
public struct SwiftForgeAutomaticFieldStyle: SwiftForgeFieldStyle {

    /// Creates the default field style.
    nonisolated public init() {}

    /// Creates a view that represents the body of a field.
    public func makeBody(configuration: Configuration) -> some View {
        SwiftForgeAutomaticFieldBody(configuration: configuration)
    }
}

extension SwiftForgeFieldStyle where Self == SwiftForgeAutomaticFieldStyle {

    /// The default field style, drawn from the theme's field tokens.
    public static var automatic: Self { SwiftForgeAutomaticFieldStyle() }
}

private struct SwiftForgeAutomaticFieldBody: View {

    let configuration: SwiftForgeFieldStyleConfiguration

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.controlSize) private var controlSize
    @SwiftForgeAccessibilityContext private var accessibility

    var body: some View {
        let shape = theme.radius.shape(cornerRadius)

        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            HStack(alignment: .firstTextBaseline) {
                configuration.label
                    .font(theme.typography.font(theme.typography.fieldLabel))
                    .foregroundStyle(theme.colors.textSecondary)
                if let optionalNote = configuration.optionalNote {
                    Spacer(minLength: theme.spacing.xs)
                    optionalNote
                        .font(theme.typography.font(theme.typography.fieldHelper))
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            configuration.content
                .frame(minHeight: fieldHeight)
                .background(background, in: shape)
                .overlay { indicator(in: shape) }
                // The input never gives up height to its neighbors: clipped input
                // text is never acceptable.
                .fixedSize(horizontal: false, vertical: true)
                .animation(theme.motion.fast.animation(reduceMotion: accessibility.reduceMotion), value: configuration.isFocused)

            if let message = configuration.message {
                message
            }
        }
    }

    private var tokens: SwiftForgeFieldTokens { theme.components.field }

    private var cornerRadius: CGFloat {
        tokens.style == .underlined ? 0 : tokens.cornerRadius ?? theme.radius.control
    }

    private var background: SwiftForgeColor {
        switch tokens.style {
        case .outlined: tokens.background ?? theme.colors.surface
        case .filled: tokens.background ?? theme.colors.fillMuted
        case .underlined: .clear
        }
    }

    /// The outline, or the line along the bottom edge.
    @ViewBuilder
    private func indicator(in shape: SwiftForgeShape) -> some View {
        switch tokens.style {
        case .outlined:
            shape.strokeBorder(borderColor, lineWidth: borderWidth)
        case .filled, .underlined:
            Rectangle()
                .fill(borderColor)
                .frame(height: borderWidth)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .clipShape(shape)
        }
    }

    private var fieldHeight: CGFloat {
        SwiftForgeControlSize(controlSize) == .large ? theme.sizes.controlHeightLarge : theme.sizes.controlHeightRegular
    }

    private var borderColor: SwiftForgeColor {
        switch configuration.state {
        case .error: theme.colors.danger.text
        case .success: theme.colors.success.text
        case .normal, .helper: configuration.isFocused ? theme.colors.focusRing : theme.colors.borderStrong
        }
    }

    private var borderWidth: CGFloat {
        if case .error = configuration.state { return theme.borders.thick }
        return configuration.isFocused ? theme.borders.thick : theme.borders.thin
    }
}

// MARK: - Environment

private struct SwiftForgeFieldStyleKey: EnvironmentKey {
    // Computed: field styles aren't `Sendable`, like SwiftUI's own styles.
    static var defaultValue: any SwiftForgeFieldStyle { SwiftForgeAutomaticFieldStyle() }
}

extension EnvironmentValues {
    var swiftForgeFieldStyle: any SwiftForgeFieldStyle {
        get { self[SwiftForgeFieldStyleKey.self] }
        set { self[SwiftForgeFieldStyleKey.self] = newValue }
    }
}

extension View {

    /// Sets the style of SwiftForgeUI form fields beneath this view.
    ///
    /// ```swift
    /// SignUpForm()
    ///     .swiftForgeFieldStyle(FloatingCardFieldStyle())
    /// ```
    public func swiftForgeFieldStyle<S: SwiftForgeFieldStyle>(_ style: S) -> some View {
        environment(\.swiftForgeFieldStyle, style)
    }
}
