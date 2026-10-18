//
//  SwiftForgeContrastAudit.swift
//  SwiftForgeUI
//

import SwiftUI

/// Verifies a theme's colors against WCAG 2.x contrast requirements in light,
/// dark, and both Increase Contrast appearances.
///
/// Built-in themes pass with no violations. Run the audit on your own theme
/// in a unit test to keep it accessible as it changes:
///
/// ```swift
/// @Test func brandThemeIsAccessible() {
///     #expect(SwiftForgeContrastAudit.run(on: .brand).isEmpty)
/// }
/// ```
///
/// The audit checks every pairing SwiftForgeUI components draw:
///
/// | Foreground | Background | Minimum |
/// |---|---|---|
/// | `textPrimary`, `textSecondary` | canvas, surface, raised surface, each tone's `subtle` | 4.5:1 |
/// | `borderStrong`, `focusRing` | canvas, surface, raised surface | 3:1 |
/// | each tone's `onSolid` | the tone's `solid`, and every color in its `solidFill` | 4.5:1 |
/// | each tone's `text` | canvas, surface, raised surface, the tone's `subtle` | 4.5:1 |
/// | ``SwiftForgeButtonTokens/borderColor``, which outlines outline buttons | canvas, surface, raised surface | 3:1 |
/// | `neutral.solid`, the off switch's thumb | `fillMuted`, the off switch's track | 3:1 |
/// | each tone's `text`, drawn as progress | `fillMuted`, the progress track | 3:1 |
/// | ``SwiftForgeToggleTokens/borderColor`` | canvas, surface, raised surface | 3:1 |
/// | text and `borderStrong` in filled text fields | the field's background | 4.5:1 and 3:1 |
/// | `textPrimary`, `textSecondary` — segment titles, search text | `fillMuted` | 4.5:1 |
/// | the border colors of ``SwiftForgeSelectionControlTokens``, ``SwiftForgeChipTokens``, ``SwiftForgeSegmentedControlTokens``, and ``SwiftForgeSliderTokens`` | canvas, surface, raised surface | 3:1 |
///
/// Surfaces include the fills set in ``SwiftForgeSurfaceTokens/fills``: every
/// gradient stop and the points between them, and a material's opaque fallback.
public enum SwiftForgeContrastAudit {

    /// An appearance the audit evaluates.
    ///
    /// Cases are added only in major releases, so you can switch over it
    /// exhaustively.
    public enum Appearance: String, Sendable, Hashable, CaseIterable, CustomStringConvertible {
        /// Light mode.
        case light
        /// Dark mode.
        case dark
        /// Light mode with Increase Contrast on.
        case lightHighContrast
        /// Dark mode with Increase Contrast on.
        case darkHighContrast

        /// The color scheme of this appearance.
        public var colorScheme: ColorScheme {
            switch self {
            case .light, .lightHighContrast: .light
            case .dark, .darkHighContrast: .dark
            }
        }

        /// Whether Increase Contrast is on in this appearance.
        public var increasedContrast: Bool {
            self == .lightHighContrast || self == .darkHighContrast
        }

        /// A textual representation of this value.
        public var description: String { rawValue }
    }

    /// A pairing that falls below its required contrast.
    public struct Violation: Sendable, Hashable, CustomStringConvertible {
        /// The foreground token, such as `"danger.text"`.
        public var foreground: String
        /// The background token, such as `"surface"`.
        public var background: String
        /// The appearance the violation occurs in.
        public var appearance: Appearance
        /// The measured contrast ratio.
        public var ratio: Double
        /// The required contrast ratio.
        public var required: Double

        /// A textual representation of this value.
        public var description: String {
            let measured = (ratio * 100).rounded() / 100
            return "\(foreground) on \(background) [\(appearance)]: \(measured):1, needs \(required):1"
        }
    }

    /// Minimum contrast for text (WCAG 1.4.3).
    public static let textMinimum = 4.5

    /// Minimum contrast for meaningful non-text elements (WCAG 1.4.11).
    public static let nonTextMinimum = 3.0

    /// Returns every pairing in the theme that falls below its required contrast.
    public static func run(on theme: SwiftForgeTheme) -> [Violation] {
        var violations: [Violation] = []
        for appearance in Appearance.allCases {
            for check in checks(for: theme) {
                let foreground = check.foreground.resolve(
                    colorScheme: appearance.colorScheme,
                    increasedContrast: appearance.increasedContrast
                )
                let background = check.background.resolve(
                    colorScheme: appearance.colorScheme,
                    increasedContrast: appearance.increasedContrast
                )
                let ratio = WCAG.contrastRatio(foreground, background)
                if ratio < check.required {
                    violations.append(
                        Violation(
                            foreground: check.foregroundName,
                            background: check.backgroundName,
                            appearance: appearance,
                            ratio: ratio,
                            required: check.required
                        )
                    )
                }
            }
        }
        return violations
    }

    /// The WCAG contrast ratio between two resolved colors, from 1 to 21.
    /// A translucent foreground is composited over the background first.
    public static func contrastRatio(_ foreground: Color.Resolved, _ background: Color.Resolved) -> Double {
        WCAG.contrastRatio(foreground, background)
    }

    struct Check {
        let foregroundName: String
        let foreground: SwiftForgeColor
        let backgroundName: String
        let background: SwiftForgeColor
        let required: Double
    }

    static func checks(for theme: SwiftForgeTheme) -> [Check] {
        let colors = theme.colors
        var surfaces: [(String, SwiftForgeColor)] = [
            ("canvas", colors.canvas), ("surface", colors.surface), ("surfaceRaised", colors.surfaceRaised),
        ]
        let fills = theme.components.surface.fills.sorted { "\($0.key)" < "\($1.key)" }
        for (level, fill) in fills {
            for (index, sample) in fill.contrastSamples.enumerated() {
                surfaces.append(("fills[.\(level)][\(index)]", sample))
            }
        }
        var checks: [Check] = []
        func add(_ name: String, _ color: SwiftForgeColor, on backgrounds: [(String, SwiftForgeColor)], _ required: Double) {
            for (backgroundName, background) in backgrounds {
                checks.append(
                    Check(
                        foregroundName: name, foreground: color,
                        backgroundName: backgroundName, background: background,
                        required: required
                    ))
            }
        }

        let toneSubtles = SwiftForgeTone.allCases.map { ("\($0.rawValue).subtle", colors[$0].subtle) }
        add("textPrimary", colors.textPrimary, on: surfaces + toneSubtles, textMinimum)
        add("textSecondary", colors.textSecondary, on: surfaces + toneSubtles, textMinimum)
        add("borderStrong", colors.borderStrong, on: surfaces, nonTextMinimum)
        add("focusRing", colors.focusRing, on: surfaces, nonTextMinimum)

        for tone in SwiftForgeTone.allCases {
            let toneColors = colors[tone]
            let name = tone.rawValue
            var solids = [("\(name).solid", toneColors.solid)]
            if let fill = toneColors.solidFill {
                solids += fill.contrastSamples.enumerated().map { ("\(name).solidFill[\($0.offset)]", $0.element) }
            }
            add("\(name).onSolid", toneColors.onSolid, on: solids, textMinimum)
            add("\(name).text", toneColors.text, on: surfaces + [("\(name).subtle", toneColors.subtle)], textMinimum)
        }

        if let borderColor = theme.components.button.borderColor {
            add("components.button.borderColor", borderColor, on: surfaces, nonTextMinimum)
        }

        let field = theme.components.field
        if field.background != nil || field.style == .filled {
            let background = ("components.field.background", field.background ?? colors.fillMuted)
            add("textPrimary", colors.textPrimary, on: [background], textMinimum)
            add("textSecondary", colors.textSecondary, on: [background], textMinimum)
            add("borderStrong", colors.borderStrong, on: [background], nonTextMinimum)
        }

        // Progress bars and rings draw each tone's text color on the muted track.
        for tone in SwiftForgeTone.allCases {
            add("\(tone.rawValue).text", colors[tone].text, on: [("fillMuted", colors.fillMuted)], nonTextMinimum)
        }

        // The off switch: its thumb on its track, and its outline on surfaces.
        add("neutral.solid", colors.neutral.solid, on: [("fillMuted", colors.fillMuted)], nonTextMinimum)
        if let borderColor = theme.components.toggle.borderColor {
            add("components.toggle.borderColor", borderColor, on: surfaces, nonTextMinimum)
        }

        // Text on the muted fill: unselected segments on the segmented
        // control's track, and the search field's prompt and query.
        add("textPrimary", colors.textPrimary, on: [("fillMuted", colors.fillMuted)], textMinimum)
        add("textSecondary", colors.textSecondary, on: [("fillMuted", colors.fillMuted)], textMinimum)

        // Outlines that mark a control's boundary or state.
        let components = theme.components
        let outlines: [(String, SwiftForgeColor?)] = [
            ("components.selectionControl.borderColor", components.selectionControl.borderColor),
            ("components.chip.borderColor", components.chip.borderColor),
            ("components.segmentedControl.borderColor", components.segmentedControl.borderColor),
            ("components.slider.thumbBorderColor", components.slider.thumbBorderColor),
            ("components.avatar.borderColor", components.avatar.borderColor),
        ]
        for case let (name, color?) in outlines {
            add(name, color, on: surfaces, nonTextMinimum)
        }
        return checks
    }
}
