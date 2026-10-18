//
//  SwiftForgeCard.swift
//  SwiftForgeUI
//

import SwiftUI

/// The visual treatment of a ``SwiftForgeCard``.
///
/// New cases may be added in minor releases; when you switch over it,
/// include a `default` case.
public enum SwiftForgeCardStyle: String, Sendable, Hashable, CaseIterable {

    /// A surface with no border or shadow. Use on the grouped canvas.
    case standard

    /// A surface with a hairline border. Use on plain white screens and in
    /// dense lists.
    case outlined

    /// A raised surface with a shadow. Use for a single prominent card.
    case elevated

    var level: SwiftForgeSurfaceLevel { self == .elevated ? .raised : .surface }
}

/// The padding inside a ``SwiftForgeCard``.
///
/// New cases may be added in minor releases; when you switch over it,
/// include a `default` case.
public enum SwiftForgeCardPadding: Sendable, Hashable {
    /// The theme's card padding.
    case standard
    /// No padding, for edge-to-edge content such as images.
    case none
}

extension EnvironmentValues {
    @Entry var swiftForgeCardPadding: SwiftForgeCardPadding = .standard
}

extension View {

    /// Sets the padding of SwiftForgeUI cards beneath this view.
    public func swiftForgeCardPadding(_ padding: SwiftForgeCardPadding) -> some View {
        environment(\.swiftForgeCardPadding, padding)
    }
}

/// A container that groups related content on a surface, with optional
/// header and footer.
///
/// ```swift
/// SwiftForgeCard(style: .elevated) {
///     Text("Your subscription renews on March 4.")
/// } header: {
///     Text("Plan renews")
/// } footer: {
///     Button("Manage") { manage() }
/// }
/// ```
///
/// The header is set in the headline style and read by VoiceOver as a
/// heading; the footer typically holds actions. Both are optional:
///
/// ```swift
/// SwiftForgeCard { PlanSummary(plan) }
/// ```
///
/// To build a card from a `GroupBox`, whose label becomes the header, use
/// ``SwiftForgeCardGroupBoxStyle`` (`.groupBoxStyle(.swiftForgeCard())`).
/// To make the whole card tappable, use a `Button` or `NavigationLink` with
/// ``SwiftForgeCardButtonStyle`` instead.
///
/// The card itself isn't an accessibility element: VoiceOver reads its
/// content in order. Combine it with
/// `accessibilityElement(children: .combine)` when the content reads best as
/// one sentence.
public struct SwiftForgeCard<Header: View, Content: View, Footer: View>: View {

    private let style: SwiftForgeCardStyle
    private let header: Header
    private let content: Content
    private let footer: Footer

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.swiftForgeCardPadding) private var padding

    /// Creates a card with a header and a footer.
    ///
    /// - Parameters:
    ///   - style: The card's treatment. Defaults to ``SwiftForgeCardStyle/standard``.
    ///   - content: The card's content.
    ///   - header: A title above the content.
    ///   - footer: Actions or details below the content.
    public init(
        style: SwiftForgeCardStyle = .standard,
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        self.style = style
        self.header = header()
        self.content = content()
        self.footer = footer()
    }

    /// The content and behavior of the view.
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            header
                .font(theme.typography.font(theme.typography.headline))
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)
            content
            footer
        }
        .padding(padding == .standard ? theme.spacing.cardPadding : 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .swiftForgeSurface(style.level, shape: .card, outlined: style == .outlined)
    }
}

extension SwiftForgeCard where Header == EmptyView, Footer == EmptyView {

    /// Creates a card.
    ///
    /// - Parameters:
    ///   - style: The card's treatment. Defaults to ``SwiftForgeCardStyle/standard``.
    ///   - content: The card's content.
    public init(style: SwiftForgeCardStyle = .standard, @ViewBuilder content: () -> Content) {
        self.init(style: style, content: content, header: { EmptyView() }, footer: { EmptyView() })
    }
}

extension SwiftForgeCard where Footer == EmptyView {

    /// Creates a card with a header.
    public init(style: SwiftForgeCardStyle = .standard, @ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header) {
        self.init(style: style, content: content, header: header, footer: { EmptyView() })
    }
}

extension SwiftForgeCard where Header == EmptyView {

    /// Creates a card with a footer.
    public init(style: SwiftForgeCardStyle = .standard, @ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer) {
        self.init(style: style, content: content, header: { EmptyView() }, footer: footer)
    }
}

/// A `GroupBox` style that draws the group as a SwiftForgeUI card, with the
/// group's label as the card's header.
///
/// ```swift
/// GroupBox("Storage") {
///     ProgressView(value: 0.62).progressViewStyle(.swiftForgeLinear)
/// }
/// .groupBoxStyle(.swiftForgeCard(.outlined))
/// ```
public struct SwiftForgeCardGroupBoxStyle: GroupBoxStyle {

    let style: SwiftForgeCardStyle

    /// Creates a card group box style.
    public init(_ style: SwiftForgeCardStyle = .standard) {
        self.style = style
    }

    /// Creates a view that represents the body of a group box.
    public func makeBody(configuration: Configuration) -> some View {
        SwiftForgeCard(style: style) {
            configuration.content
        } header: {
            configuration.label
        }
    }
}

extension GroupBoxStyle where Self == SwiftForgeCardGroupBoxStyle {

    /// A style that draws a group box as a SwiftForgeUI card.
    public static func swiftForgeCard(_ style: SwiftForgeCardStyle = .standard) -> Self {
        SwiftForgeCardGroupBoxStyle(style)
    }
}

/// A button style that turns a `Button` or `NavigationLink` into a tappable card.
///
/// ```swift
/// NavigationLink(value: plan) {
///     PlanSummary(plan)
/// }
/// .buttonStyle(.swiftForgeCard(.outlined))
/// ```
///
/// The card is a single accessibility element with the button trait. Avoid
/// placing other buttons inside it; offer secondary actions with
/// `accessibilityAction(named:_:)` instead.
public struct SwiftForgeCardButtonStyle: ButtonStyle {

    let style: SwiftForgeCardStyle

    /// Creates a card button style.
    public init(_ style: SwiftForgeCardStyle = .outlined) {
        self.style = style
    }

    /// Creates a view that represents the body of a styled control.
    public func makeBody(configuration: Configuration) -> some View {
        SwiftForgeCardButtonBody(configuration: configuration, style: style)
    }
}

extension ButtonStyle where Self == SwiftForgeCardButtonStyle {

    /// A style that turns a button into a tappable card.
    public static func swiftForgeCard(_ style: SwiftForgeCardStyle = .outlined) -> Self {
        SwiftForgeCardButtonStyle(style)
    }
}

private struct SwiftForgeCardButtonBody: View {

    let configuration: ButtonStyleConfiguration
    let style: SwiftForgeCardStyle

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.swiftForgeCardPadding) private var padding

    var body: some View {
        let shape = theme.radius.shape(theme.radius.card)
        let isPressed = configuration.isPressed
        let shadow = theme.elevation[style.level.elevation]
        let pressEffect = theme.components.card.pressEffect
        let isSinking = pressEffect.sinks(isPressed: isPressed, shadow: shadow)
        configuration.label
            .foregroundStyle(theme.colors.textPrimary)
            .multilineTextAlignment(.leading)
            .padding(padding == .standard ? theme.spacing.cardPadding : 0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(
                SwiftForgeSurfaceModifier(
                    level: style.level, shape: .card, isOutlined: style == .outlined, hidesShadow: isSinking)
            )
            .overlay {
                if isPressed {
                    shape.fill(theme.colors.pressedOverlay)
                }
            }
            .swiftForgeFocusRing(isFocused, cornerRadius: theme.radius.card)
            .contentShape(shape)
            .swiftForgePressFeedback(pressEffect, isPressed: isPressed, shadow: shadow)
            .opacity(isEnabled ? 1 : theme.opacity.disabled)
    }
}

// MARK: - Previews

private struct CardPreviewContent: View {
    let title: String
    let subtitle: String
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Text(title).swiftForgeTextStyle(\.headline)
            Text(subtitle).swiftForgeTextStyle(\.subheadline).foregroundStyle(theme.colors.textSecondary)
        }
    }
}

#Preview("Header and footer") {
    VStack(spacing: 16) {
        SwiftForgeCard(style: .elevated) {
            Text("Your subscription renews on March 4.")
        } header: {
            Text("Plan renews")
        } footer: {
            Button("Manage") {}.buttonStyle(.swiftForge(.tinted)).controlSize(.small)
        }
        GroupBox("Storage") {
            ProgressView(value: 0.62).progressViewStyle(.swiftForgeLinear)
        }
        .groupBoxStyle(.swiftForgeCard(.outlined))
    }
    .padding()
    .background(SwiftForgeTheme.forge.colors.canvas)
}

#Preview("Styles") {
    VStack(spacing: 16) {
        ForEach(SwiftForgeCardStyle.allCases, id: \.self) { style in
            SwiftForgeCard(style: style) {
                CardPreviewContent(title: style.rawValue.capitalized, subtitle: "Your subscription renews on March 4.")
            }
        }
        Button {
        } label: {
            CardPreviewContent(title: "Tappable", subtitle: "A button styled as a card")
        }
        .buttonStyle(.swiftForgeCard())
    }
    .padding()
    .background(SwiftForgeTheme.forge.colors.canvas)
}

#Preview("Paper, dark, increased contrast") {
    VStack(spacing: 16) {
        ForEach(SwiftForgeCardStyle.allCases, id: \.self) { style in
            SwiftForgeCard(style: style) {
                CardPreviewContent(title: style.rawValue.capitalized, subtitle: "Your subscription renews on March 4.")
            }
        }
    }
    .padding()
    .background(SwiftForgeTheme.paper.colors.canvas)
    .swiftForgeTheme(.paper)
    .swiftForgeAccessibilitySimulation(increasedContrast: true)
    .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        VStack(spacing: 8) {
            ForEach(SwiftForgeCardStyle.allCases, id: \.self) { style in
                SwiftForgeCard(style: style) {
                    CardPreviewContent(title: style.rawValue.capitalized, subtitle: "Renews on March 4.")
                }
            }
            Button {
            } label: {
                CardPreviewContent(title: "Tappable", subtitle: "A button styled as a card")
            }
            .buttonStyle(.swiftForgeCard())
        }
    }
}

#Preview("All themes, AX3") {
    SwiftForgeThemeMatrix(dynamicTypeSize: .accessibility3) {
        VStack(spacing: 8) {
            ForEach(SwiftForgeCardStyle.allCases, id: \.self) { style in
                SwiftForgeCard(style: style) {
                    CardPreviewContent(title: style.rawValue.capitalized, subtitle: "Renews on March 4.")
                }
            }
            Button {
            } label: {
                CardPreviewContent(title: "Tappable", subtitle: "A button styled as a card")
            }
            .buttonStyle(.swiftForgeCard())
        }
    }
}
