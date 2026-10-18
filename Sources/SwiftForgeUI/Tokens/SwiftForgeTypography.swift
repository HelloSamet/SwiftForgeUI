//
//  SwiftForgeTypography.swift
//  SwiftForgeUI
//

import SwiftUI

/// A typographic role: a Dynamic Type text style plus weight, design,
/// leading, and tracking.
///
/// Every role is anchored to a `Font.TextStyle`, so text scales with Dynamic
/// Type from `xSmall` through `accessibility5` — including custom fonts,
/// which scale relative to the same text style.
public struct SwiftForgeTextStyle: Sendable, Hashable {

    /// The Dynamic Type style this role scales with.
    public var textStyle: Font.TextStyle

    /// The font weight.
    public var weight: Font.Weight

    /// The system font design. Ignored for custom font families.
    public var design: Font.Design

    /// The line spacing.
    public var leading: Font.Leading

    /// Extra tracking in points, or `nil` to keep the font's own tracking.
    public var tracking: CGFloat?

    /// Creates a text style.
    public init(
        _ textStyle: Font.TextStyle,
        weight: Font.Weight = .regular,
        design: Font.Design = .default,
        leading: Font.Leading = .standard,
        tracking: CGFloat? = nil
    ) {
        self.textStyle = textStyle
        self.weight = weight
        self.design = design
        self.leading = leading
        self.tracking = tracking
    }

    /// Returns a copy with a different weight.
    public func weight(_ weight: Font.Weight) -> SwiftForgeTextStyle {
        var copy = self
        copy.weight = weight
        return copy
    }

    /// Returns a copy with a different system font design.
    public func designed(_ design: Font.Design) -> SwiftForgeTextStyle {
        var copy = self
        copy.design = design
        return copy
    }
}

/// The font family a theme renders text with.
public struct SwiftForgeFontFamily: Sendable, Hashable {

    enum Storage: Sendable, Hashable {
        case system
        case custom(regular: String, medium: String, semibold: String, bold: String)
    }

    let storage: Storage

    /// The system font (SF Pro on iOS).
    public static let system = SwiftForgeFontFamily(storage: .system)

    /// A custom font family, scaled with Dynamic Type relative to each role's
    /// text style.
    ///
    /// Register the fonts with your app (for example through `UIAppFonts`)
    /// before using them. Weights without a dedicated face fall back to the
    /// nearest provided one.
    ///
    /// - Parameters:
    ///   - regular: The PostScript name of the regular face.
    ///   - medium: The medium face. Defaults to `regular`.
    ///   - semibold: The semibold face. Defaults to `bold`, then `medium`.
    ///   - bold: The bold face. Defaults to `semibold`, then `medium`.
    public static func custom(
        regular: String, medium: String? = nil, semibold: String? = nil, bold: String? = nil
    )
        -> SwiftForgeFontFamily
    {
        let medium = medium ?? regular
        return SwiftForgeFontFamily(
            storage: .custom(
                regular: regular,
                medium: medium,
                semibold: semibold ?? bold ?? medium,
                bold: bold ?? semibold ?? medium
            )
        )
    }

    func font(for style: SwiftForgeTextStyle) -> Font {
        switch storage {
        case .system:
            let font = Font.system(style.textStyle, design: style.design, weight: style.weight)
            // `leading(_:)` stops SwiftUI from applying Bold Text to a system
            // font, so it's only applied when a role asks for other leading;
            // `SwiftForgeTypography.adjustedForBoldText()` covers those roles.
            return style.leading == .standard ? font : font.leading(style.leading)
        case let .custom(regular, medium, semibold, bold):
            let name: String
            switch style.weight {
            case .ultraLight, .thin, .light, .regular: name = regular
            case .medium: name = medium
            case .semibold: name = semibold
            default: name = bold
            }
            return Font.custom(name, size: Self.defaultPointSize(for: style.textStyle), relativeTo: style.textStyle)
                .leading(style.leading)
        }
    }

    /// Point sizes of Apple's text styles at the default (`.large`) Dynamic Type size.
    static func defaultPointSize(for textStyle: Font.TextStyle) -> CGFloat {
        switch textStyle {
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline, .body: 17
        case .callout: 16
        case .subheadline: 15
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        #if os(visionOS)
        case .extraLargeTitle: 48
        case .extraLargeTitle2: 40
        #endif
        @unknown default: 17
        }
    }
}

/// The type scale: the roles every SwiftForgeUI component sets text in.
///
/// Apply a role to your own text with ``SwiftUICore/View/swiftForgeTextStyle(_:)``:
///
/// ```swift
/// Text("Account").swiftForgeTextStyle(\.title2)
/// ```
public struct SwiftForgeTypography: Sendable, Hashable {

    /// The font family every role uses.
    public var fontFamily: SwiftForgeFontFamily

    /// Large screen titles.
    public var largeTitle: SwiftForgeTextStyle
    /// Screen and section titles.
    public var title1: SwiftForgeTextStyle
    /// Prominent card titles.
    public var title2: SwiftForgeTextStyle
    /// Subtitles.
    public var title3: SwiftForgeTextStyle
    /// List and card titles.
    public var headline: SwiftForgeTextStyle
    /// Body text and text input.
    public var body: SwiftForgeTextStyle
    /// Emphasized descriptions.
    public var callout: SwiftForgeTextStyle
    /// Secondary text.
    public var subheadline: SwiftForgeTextStyle
    /// Helper and error text.
    public var footnote: SwiftForgeTextStyle
    /// Metadata, such as timestamps.
    public var caption1: SwiftForgeTextStyle
    /// The smallest text. Apple's accessibility audit reports this style as
    /// only partially scaling with Dynamic Type; prefer ``caption1`` for
    /// anything a person needs to read.
    public var caption2: SwiftForgeTextStyle

    /// Button labels at regular and large control sizes.
    public var controlLabel: SwiftForgeTextStyle
    /// Button labels at small control size, chips, and segments.
    public var controlLabelSmall: SwiftForgeTextStyle
    /// Text field labels.
    public var fieldLabel: SwiftForgeTextStyle
    /// Text field helper, validation, and counter text.
    public var fieldHelper: SwiftForgeTextStyle
    /// Badge text.
    public var badge: SwiftForgeTextStyle

    /// Creates a type scale. Start from ``standard`` and change individual
    /// roles rather than calling this directly.
    public init(
        fontFamily: SwiftForgeFontFamily,
        largeTitle: SwiftForgeTextStyle,
        title1: SwiftForgeTextStyle,
        title2: SwiftForgeTextStyle,
        title3: SwiftForgeTextStyle,
        headline: SwiftForgeTextStyle,
        body: SwiftForgeTextStyle,
        callout: SwiftForgeTextStyle,
        subheadline: SwiftForgeTextStyle,
        footnote: SwiftForgeTextStyle,
        caption1: SwiftForgeTextStyle,
        caption2: SwiftForgeTextStyle,
        controlLabel: SwiftForgeTextStyle,
        controlLabelSmall: SwiftForgeTextStyle,
        fieldLabel: SwiftForgeTextStyle,
        fieldHelper: SwiftForgeTextStyle,
        badge: SwiftForgeTextStyle
    ) {
        self.fontFamily = fontFamily
        self.largeTitle = largeTitle
        self.title1 = title1
        self.title2 = title2
        self.title3 = title3
        self.headline = headline
        self.body = body
        self.callout = callout
        self.subheadline = subheadline
        self.footnote = footnote
        self.caption1 = caption1
        self.caption2 = caption2
        self.controlLabel = controlLabel
        self.controlLabelSmall = controlLabelSmall
        self.fieldLabel = fieldLabel
        self.fieldHelper = fieldHelper
        self.badge = badge
    }

    /// The font for a role in this scale's font family.
    public func font(_ style: SwiftForgeTextStyle) -> Font {
        fontFamily.font(for: style)
    }

    /// SwiftForgeUI's type scale, built on Apple's text styles.
    public static let standard = SwiftForgeTypography(
        fontFamily: .system,
        largeTitle: SwiftForgeTextStyle(.largeTitle, weight: .bold),
        title1: SwiftForgeTextStyle(.title, weight: .bold),
        title2: SwiftForgeTextStyle(.title2, weight: .bold),
        title3: SwiftForgeTextStyle(.title3, weight: .semibold),
        headline: SwiftForgeTextStyle(.headline, weight: .semibold),
        body: SwiftForgeTextStyle(.body),
        callout: SwiftForgeTextStyle(.callout),
        subheadline: SwiftForgeTextStyle(.subheadline),
        footnote: SwiftForgeTextStyle(.footnote),
        caption1: SwiftForgeTextStyle(.caption),
        caption2: SwiftForgeTextStyle(.caption2, weight: .medium),
        controlLabel: SwiftForgeTextStyle(.body, weight: .semibold),
        controlLabelSmall: SwiftForgeTextStyle(.subheadline, weight: .semibold),
        fieldLabel: SwiftForgeTextStyle(.subheadline, weight: .medium),
        fieldHelper: SwiftForgeTextStyle(.footnote),
        badge: SwiftForgeTextStyle(.caption, weight: .semibold)
    )
}

extension SwiftForgeTypography {

    /// Every role in the scale.
    static var allRoles: [WritableKeyPath<SwiftForgeTypography, SwiftForgeTextStyle>] {
        [
            \.largeTitle, \.title1, \.title2, \.title3, \.headline, \.body, \.callout, \.subheadline, \.footnote,
            \.caption1, \.caption2, \.controlLabel, \.controlLabelSmall, \.fieldLabel, \.fieldHelper, \.badge,
        ]
    }

    /// The display roles: titles and headlines.
    static var displayRoles: [WritableKeyPath<SwiftForgeTypography, SwiftForgeTextStyle>] {
        [\.largeTitle, \.title1, \.title2, \.title3, \.headline]
    }

    /// This scale as Bold Text should render it. SwiftUI applies Bold Text to
    /// system fonts with standard leading on its own; custom font families,
    /// and system roles with other leading, move one weight heavier instead.
    func adjustedForBoldText() -> SwiftForgeTypography {
        let isCustom = if case .custom = fontFamily.storage { true } else { false }
        let roles = Self.allRoles.filter { isCustom || self[keyPath: $0].leading != .standard }
        guard !roles.isEmpty else { return self }
        return updating(roles) { $0.weight = $0.weight.heavier }
    }

    /// Returns a copy with `transform` applied to `roles`.
    func updating(
        _ roles: [WritableKeyPath<SwiftForgeTypography, SwiftForgeTextStyle>],
        _ transform: (inout SwiftForgeTextStyle) -> Void
    ) -> SwiftForgeTypography {
        var copy = self
        for role in roles { transform(&copy[keyPath: role]) }
        return copy
    }
}

private struct SwiftForgeTextStyleModifier: ViewModifier {

    let style: KeyPath<SwiftForgeTypography, SwiftForgeTextStyle>
    var color: KeyPath<SwiftForgeColors, SwiftForgeColor>?

    @Environment(\.swiftForgeTheme) private var theme

    func body(content: Content) -> some View {
        let textStyle = theme.typography[keyPath: style]
        let styled =
            content
            .font(theme.typography.font(textStyle))
            .tracking(textStyle.tracking ?? 0)
        if let color {
            styled.foregroundStyle(theme.colors[keyPath: color])
        } else {
            styled
        }
    }
}

extension View {

    /// Sets text in this view in a role from the current theme's type scale.
    ///
    /// ```swift
    /// Text("Recent activity").swiftForgeTextStyle(\.headline)
    /// ```
    public func swiftForgeTextStyle(_ style: KeyPath<SwiftForgeTypography, SwiftForgeTextStyle>) -> some View {
        modifier(SwiftForgeTextStyleModifier(style: style))
    }

    /// Sets text in this view in a role from the current theme's type scale,
    /// and in one of the theme's colors.
    ///
    /// ```swift
    /// Text("Welcome back").swiftForgeTextStyle(\.largeTitle, color: \.textPrimary)
    /// Text("Sign in to continue.").swiftForgeTextStyle(\.body, color: \.textSecondary)
    /// Text("Payment failed").swiftForgeTextStyle(\.headline, color: \.danger.text)
    /// ```
    ///
    /// Text without a color uses SwiftUI's primary color rather than the
    /// theme's, so name one for text on the theme's canvas and surfaces. For
    /// text, use ``SwiftForgeColors/textPrimary``, ``SwiftForgeColors/textSecondary``,
    /// or a tone's ``SwiftForgeToneColors/text``: those are the colors checked
    /// for contrast against every surface.
    ///
    /// - Parameters:
    ///   - style: The role in the theme's type scale.
    ///   - color: The color, as a key path into the theme's colors.
    public func swiftForgeTextStyle(
        _ style: KeyPath<SwiftForgeTypography, SwiftForgeTextStyle>, color: KeyPath<SwiftForgeColors, SwiftForgeColor>
    ) -> some View {
        modifier(SwiftForgeTextStyleModifier(style: style, color: color))
    }
}

extension Font.Weight {

    /// The next heavier weight, as Bold Text renders it.
    var heavier: Font.Weight {
        let ladder: [Font.Weight] = [.ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black]
        guard let index = ladder.firstIndex(of: self) else { return self }
        // Regular text becomes semibold, as with system fonts; other weights move one step.
        if self == .regular { return .semibold }
        return ladder[min(index + 1, ladder.count - 1)]
    }
}
