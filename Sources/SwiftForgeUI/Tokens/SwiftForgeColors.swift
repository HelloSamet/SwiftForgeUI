//
//  SwiftForgeColors.swift
//  SwiftForgeUI
//

import SwiftUI

/// A semantic color family that SwiftForgeUI components use for a tone, such
/// as the accent or an error state.
///
/// Cases are added only in major releases, so you can switch over it
/// exhaustively.
public enum SwiftForgeTone: String, Sendable, Hashable, CaseIterable {

    /// The brand color — primary actions and selection.
    case accent

    /// A neutral gray — secondary actions and non-status labels.
    case neutral

    /// Informational status.
    case info

    /// Positive status, such as a completed action.
    case success

    /// Cautionary status that needs attention but isn't an error.
    case warning

    /// Errors and destructive actions.
    case danger
}

/// The four colors that make up a ``SwiftForgeTone``.
///
/// Built-in themes guarantee these contrast pairs (WCAG 2.x):
///
/// | Pair | Minimum |
/// |---|---|
/// | `onSolid` on `solid` | 4.5:1 |
/// | `text` on `subtle` | 4.5:1 |
/// | `text` on canvas, surface, and raised surface | 4.5:1 |
public struct SwiftForgeToneColors: Sendable, Hashable {

    /// A filled background, such as a filled button or a count badge.
    public var solid: SwiftForgeColor

    /// Text and icons drawn on ``solid``.
    public var onSolid: SwiftForgeColor

    /// Tinted text and icons drawn on surfaces or on ``subtle``.
    public var text: SwiftForgeColor

    /// A light tinted background, such as a tinted button, banner, or badge.
    public var subtle: SwiftForgeColor

    /// How large solid areas, such as filled buttons, are painted — for
    /// example a gradient — or `nil` to paint them with ``solid``. Small
    /// marks such as progress bars and dots always use ``solid``.
    ///
    /// ``onSolid`` must contrast 4.5:1 with every color in the fill;
    /// ``SwiftForgeContrastAudit`` checks the gradient's stops and the points
    /// between them.
    public var solidFill: SwiftForgeFill?

    /// Creates a tone from its colors.
    public init(
        solid: SwiftForgeColor,
        onSolid: SwiftForgeColor,
        text: SwiftForgeColor,
        subtle: SwiftForgeColor,
        solidFill: SwiftForgeFill? = nil
    ) {
        self.solid = solid
        self.onSolid = onSolid
        self.text = text
        self.subtle = subtle
        self.solidFill = solidFill
    }

    /// ``solidFill``, or ``solid`` as a fill.
    var solidPaint: SwiftForgeFill { solidFill ?? .color(solid) }

    /// Derives a complete tone from a single brand color.
    ///
    /// For each appearance, the derivation picks black or white for
    /// ``onSolid`` (whichever contrasts more), mixes ``subtle`` from the solid
    /// color and the background — keeping the theme's text at 4.5:1 on it —
    /// and darkens (light mode) or lightens (dark
    /// mode) the solid color for ``text`` until it reaches 4.5:1 — 7:1 for
    /// Increase Contrast — against the ``SwiftForgeTheme/forge`` theme's
    /// surfaces and ``subtle``. To derive a tone for another theme, use
    /// ``derived(from:on:)``.
    ///
    /// ```swift
    /// theme.colors.accent = .derived(from: SwiftForgeColor(light: 0x5B3CC4, dark: 0x7B61E0))
    /// ```
    ///
    /// Run ``SwiftForgeContrastAudit`` on the resulting theme to confirm the
    /// derivation met every requirement for your color. A color wrapped from a
    /// SwiftUI `Color` can't be analyzed; it's used as is, with white content
    /// and a 15% tint.
    public static func derived(from solid: SwiftForgeColor) -> SwiftForgeToneColors {
        derived(from: solid, on: SwiftForgeTheme.forge.colors)
    }

    /// Derives a complete tone from a single brand color, meeting contrast
    /// against the canvas, surface, and raised surface of `colors`.
    ///
    /// ```swift
    /// theme.colors.accent = .derived(from: brand, on: theme.colors)
    /// ```
    public static func derived(from solid: SwiftForgeColor, on colors: SwiftForgeColors) -> SwiftForgeToneColors {
        guard case let .adaptive(light, dark, lightHighContrast, darkHighContrast) = solid.storage else {
            return SwiftForgeToneColors(solid: solid, onSolid: .white, text: solid, subtle: solid.withOpacity(0.15))
        }
        func part(_ solid: Color.Resolved, _ scheme: ColorScheme, highContrast: Bool) -> ToneDerivation {
            func resolve(_ token: SwiftForgeColor) -> Color.Resolved {
                token.resolve(colorScheme: scheme, increasedContrast: highContrast)
            }
            return ToneDerivation(
                solid: solid,
                isDark: scheme == .dark,
                background: resolve(colors.surface),
                surfaces: [resolve(colors.canvas), resolve(colors.surface), resolve(colors.surfaceRaised)],
                contents: [resolve(colors.textPrimary), resolve(colors.textSecondary)],
                target: highContrast ? 7 : 4.5
            )
        }
        let parts = [
            part(light, .light, highContrast: false),
            part(dark, .dark, highContrast: false),
            part(lightHighContrast, .light, highContrast: true),
            part(darkHighContrast, .dark, highContrast: true),
        ]
        func token(_ keyPath: KeyPath<ToneDerivation, Color.Resolved>) -> SwiftForgeColor {
            SwiftForgeColor(
                light: parts[0][keyPath: keyPath],
                dark: parts[1][keyPath: keyPath],
                lightHighContrast: parts[2][keyPath: keyPath],
                darkHighContrast: parts[3][keyPath: keyPath]
            )
        }
        return SwiftForgeToneColors(solid: solid, onSolid: token(\.onSolid), text: token(\.text), subtle: token(\.subtle))
    }
}

/// One appearance's worth of ``SwiftForgeToneColors/derived(from:)``.
private struct ToneDerivation {

    let onSolid: Color.Resolved
    let subtle: Color.Resolved
    let text: Color.Resolved

    /// - Parameters:
    ///   - background: The surface the tinted ``subtle`` color is mixed from.
    ///   - surfaces: The backgrounds ``text`` must contrast with, besides ``subtle``.
    ///   - contents: The theme's own text colors, which components also draw
    ///     on ``subtle`` (banner titles and messages) and must stay at 4.5:1.
    init(
        solid: Color.Resolved, isDark: Bool, background: Color.Resolved, surfaces: [Color.Resolved],
        contents: [Color.Resolved], target: Double
    ) {
        let white = Color.Resolved.swiftForgeWhite
        let black = Color.Resolved.swiftForgeBlack
        onSolid = WCAG.contrastRatio(white, solid) >= WCAG.contrastRatio(black, solid) ? white : black

        // Tint the background with the solid color, less if the theme's text
        // would fall below AA on the result.
        var tint: Float = isDark ? 0.28 : 0.12
        var tinted = WCAG.mix(background, solid, tint)
        while tint > 0, contents.contains(where: { WCAG.contrastRatio($0, tinted) < 4.5 }) {
            tint = max(0, tint - 0.02)
            tinted = WCAG.mix(background, solid, tint)
        }
        subtle = tinted

        let surfaces = surfaces + [subtle]
        let towards = isDark ? white : black
        var candidate = solid
        var step: Float = 0
        while step <= 1, surfaces.contains(where: { WCAG.contrastRatio(candidate, $0) < target }) {
            step += 0.02
            candidate = WCAG.mix(solid, towards, min(step, 1))
        }
        text = candidate
    }
}

/// Every semantic color SwiftForgeUI components draw with.
///
/// Components read colors from ``SwiftForgeTheme/colors`` in the environment,
/// never from constants, so changing a token restyles every component that
/// uses it. See <doc:TokenReference>.
public struct SwiftForgeColors: Sendable, Hashable {

    // MARK: Surfaces

    /// The screen background, in the grouped style.
    public var canvas: SwiftForgeColor

    /// Cards, list cells, and text fields placed on ``canvas``.
    public var surface: SwiftForgeColor

    /// Surfaces that float above content: elevated cards, menus, toasts.
    /// Lighter than ``surface`` in dark mode, which conveys depth there.
    public var surfaceRaised: SwiftForgeColor

    /// A muted fill for tracks and placeholders. Decorative; carries no
    /// contrast requirement.
    public var fillMuted: SwiftForgeColor

    // MARK: Content

    /// Primary text. At least 4.5:1 on every surface.
    public var textPrimary: SwiftForgeColor

    /// Secondary text, helper text, and placeholders. At least 4.5:1 on every surface.
    public var textSecondary: SwiftForgeColor

    // MARK: Lines

    /// Decorative separators and hairlines. Carries no contrast requirement.
    public var borderSubtle: SwiftForgeColor

    /// Boundaries that identify a control, such as a text field's outline.
    /// At least 3:1 on every surface.
    public var borderStrong: SwiftForgeColor

    /// The keyboard focus ring. At least 3:1 on every surface.
    public var focusRing: SwiftForgeColor

    // MARK: Interaction

    /// The layer drawn over a control while it's pressed.
    public var pressedOverlay: SwiftForgeColor

    // MARK: Tones

    /// The brand tone.
    public var accent: SwiftForgeToneColors

    /// The neutral tone.
    public var neutral: SwiftForgeToneColors

    /// The informational tone.
    public var info: SwiftForgeToneColors

    /// The success tone.
    public var success: SwiftForgeToneColors

    /// The warning tone.
    public var warning: SwiftForgeToneColors

    /// The danger tone, for errors and destructive actions.
    public var danger: SwiftForgeToneColors

    /// Creates a color set. Start from a built-in theme's colors and change
    /// individual tokens rather than calling this directly.
    public init(
        canvas: SwiftForgeColor,
        surface: SwiftForgeColor,
        surfaceRaised: SwiftForgeColor,
        fillMuted: SwiftForgeColor,
        textPrimary: SwiftForgeColor,
        textSecondary: SwiftForgeColor,
        borderSubtle: SwiftForgeColor,
        borderStrong: SwiftForgeColor,
        focusRing: SwiftForgeColor,
        pressedOverlay: SwiftForgeColor,
        accent: SwiftForgeToneColors,
        neutral: SwiftForgeToneColors,
        info: SwiftForgeToneColors,
        success: SwiftForgeToneColors,
        warning: SwiftForgeToneColors,
        danger: SwiftForgeToneColors
    ) {
        self.canvas = canvas
        self.surface = surface
        self.surfaceRaised = surfaceRaised
        self.fillMuted = fillMuted
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.borderSubtle = borderSubtle
        self.borderStrong = borderStrong
        self.focusRing = focusRing
        self.pressedOverlay = pressedOverlay
        self.accent = accent
        self.neutral = neutral
        self.info = info
        self.success = success
        self.warning = warning
        self.danger = danger
    }

    /// The colors for a tone.
    public subscript(tone: SwiftForgeTone) -> SwiftForgeToneColors {
        get {
            switch tone {
            case .accent: accent
            case .neutral: neutral
            case .info: info
            case .success: success
            case .warning: warning
            case .danger: danger
            }
        }
        set {
            switch tone {
            case .accent: accent = newValue
            case .neutral: neutral = newValue
            case .info: info = newValue
            case .success: success = newValue
            case .warning: warning = newValue
            case .danger: danger = newValue
            }
        }
    }
}
