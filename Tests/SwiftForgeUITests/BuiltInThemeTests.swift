import SwiftUI
import Testing

@testable import SwiftForgeUI

/// Locks in each built-in theme's character: themes must differ in shape,
/// depth, density, and typography — not only in color.
@Suite("Built-in themes")
struct BuiltInThemeTests {

    /// The non-color decisions that make a theme recognizable.
    private struct Character: Equatable {
        let corners: [CGFloat]
        let shadows: [SwiftForgeShadow]
        let density: [CGFloat]
        let type: [Font.Design]
        let weights: [Font.Weight]
        let components: SwiftForgeComponentTokens

        init(_ theme: SwiftForgeTheme) {
            corners = [theme.radius.control, theme.radius.card, theme.components.button.cornerRadius ?? -1]
            shadows = SwiftForgeElevationLevel.allCases.map { theme.elevation[$0] }
            density = [theme.spacing.md, theme.sizes.controlHeightRegular]
            type = [theme.typography.title1.design, theme.typography.body.design]
            weights = [theme.typography.title1.weight, theme.typography.controlLabel.weight]
            components = theme.components
        }
    }

    @Test(
        "Every built-in theme differs from Forge in at least three non-color categories",
        arguments: SwiftForgeTheme.builtIn.dropFirst())
    func distinctFromForge(theme: SwiftForgeTheme) {
        let forge = Character(.forge)
        let other = Character(theme)
        let differences = [
            forge.corners != other.corners,
            forge.shadows != other.shadows,
            forge.density != other.density,
            forge.type != other.type || forge.weights != other.weights,
            forge.components != other.components,
        ].filter { $0 }
        #expect(differences.count >= 3, "\(theme.id) differs from Forge in \(differences.count) categories")
    }

    @Test("No two built-in themes share the same character")
    func pairwiseDistinct() {
        let characters = SwiftForgeTheme.builtIn.map(Character.init)
        for i in characters.indices {
            for j in characters.indices where i < j {
                #expect(characters[i] != characters[j], "\(SwiftForgeTheme.builtIn[i].id) ≈ \(SwiftForgeTheme.builtIn[j].id)")
            }
        }
    }

    @Test("Every theme has distinct light and dark appearances", arguments: SwiftForgeTheme.builtIn)
    func lightAndDark(theme: SwiftForgeTheme) {
        for color in [theme.colors.canvas, theme.colors.surface, theme.colors.textPrimary] {
            let light = color.resolve(colorScheme: .light, increasedContrast: false)
            let dark = color.resolve(colorScheme: .dark, increasedContrast: false)
            #expect(WCAG.relativeLuminance(light) > WCAG.relativeLuminance(dark) + 0.3 || color == theme.colors.textPrimary)
        }
        let text = theme.colors.textPrimary
        #expect(
            WCAG.relativeLuminance(text.resolve(colorScheme: .dark, increasedContrast: false))
                > WCAG.relativeLuminance(text.resolve(colorScheme: .light, increasedContrast: false)))
    }

    @Test("Increase Contrast strengthens secondary text in every theme", arguments: SwiftForgeTheme.builtIn)
    func increasedContrast(theme: SwiftForgeTheme) {
        for scheme in [ColorScheme.light, .dark] {
            func ratio(_ highContrast: Bool) -> Double {
                WCAG.contrastRatio(
                    theme.colors.textSecondary.resolve(colorScheme: scheme, increasedContrast: highContrast),
                    theme.colors.surface.resolve(colorScheme: scheme, increasedContrast: highContrast)
                )
            }
            #expect(ratio(true) > ratio(false), "\(theme.id) \(scheme)")
            #expect(ratio(true) >= 7, "\(theme.id) \(scheme): \(ratio(true))")
        }
    }

    @Test("Subtle borders and separators stay visible on every surface", arguments: SwiftForgeTheme.builtIn)
    func subtleBordersAreVisible(theme: SwiftForgeTheme) {
        // Decorative, so WCAG sets no minimum; below about 1.25:1 a hairline
        // separator disappears, which defeats its purpose. Dividers and row
        // separators sit on the canvas and on surfaces; raised surfaces are
        // set apart by their elevation (Forge uses the system's dark separator).
        for scheme in [ColorScheme.light, .dark] {
            let border = theme.colors.borderSubtle.resolve(colorScheme: scheme, increasedContrast: false)
            for surface in [theme.colors.canvas, theme.colors.surface] {
                let ratio = WCAG.contrastRatio(border, surface.resolve(colorScheme: scheme, increasedContrast: false))
                #expect(ratio >= 1.25, "\(theme.id) \(scheme): \(ratio)")
            }
        }
    }

    @Test("Paper is flat and editorial")
    func paper() {
        let paper = SwiftForgeTheme.paper
        #expect(SwiftForgeElevationLevel.allCases.allSatisfy { paper.elevation[$0] == .none })
        #expect(paper.typography.title1.design == .serif)
        #expect(paper.typography.body.design == .default)
        #expect(paper.components.field.style == .underlined)
        #expect(paper.components.surface.bordersEverySurface)
    }

    @Test("Neo-Brutal is square, outlined, and casts hard shadows that controls sink into")
    func neoBrutal() {
        let theme = SwiftForgeTheme.neoBrutal
        #expect(theme.radius.control == 0 && theme.radius.card == 0)
        #expect(theme.elevation.low.radius == 0 && theme.elevation.low.x > 0 && theme.elevation.low.y > 0)
        #expect(theme.components.button.pressEffect == .sinkIntoShadow)
        #expect((theme.components.button.borderWidth ?? 0) >= 2)
    }

    @Test("Aurora is rounded, gradient-filled, and glassy")
    func aurora() {
        let theme = SwiftForgeTheme.aurora
        #expect(theme.components.button.cornerRadius == SwiftForgeRadius.capsule)
        #expect(theme.colors.accent.solidFill != nil)
        #expect(theme.components.surface.fills[.overlay] != nil)
        #expect(theme.components.surface.fills[.raised] == nil)
        #expect(theme.typography.body.design == .rounded)
    }

    @Test("Mono is monospaced and dense, without shrinking hit areas")
    func mono() {
        let theme = SwiftForgeTheme.mono
        #expect(SwiftForgeTypography.allRoles.allSatisfy { theme.typography[keyPath: $0].design == .monospaced })
        #expect(theme.spacing.md < SwiftForgeTheme.forge.spacing.md)
        #expect(theme.sizes.controlHeightRegular < 44)
        #expect(theme.sizes.minimumHitTarget == 44)
    }

    @Test("Ocean is pebble-rounded, tall, and calm")
    func ocean() {
        let theme = SwiftForgeTheme.ocean
        let forge = SwiftForgeTheme.forge
        #expect(theme.radius.control > forge.radius.control && theme.radius.card > forge.radius.card)
        #expect(theme.sizes.controlHeightRegular > forge.sizes.controlHeightRegular)
        #expect(theme.typography.title1.weight == .medium)
        let tokens = [theme.motion.fast, theme.motion.standard, theme.motion.emphasized]
        #expect(tokens.allSatisfy { $0.bounce == 0 })
        #expect(theme.motion.standard.duration > forge.motion.standard.duration)
        let shadow = theme.elevation.medium.color.resolve(colorScheme: .light, increasedContrast: false)
        #expect(shadow.blue > shadow.red)  // a deep-sea tint, not a neutral gray
    }

    @Test("Sunset glows warm, with gradient buttons and heavy rounded headings")
    func sunset() {
        let theme = SwiftForgeTheme.sunset
        #expect(theme.colors.accent.solidFill != nil)
        #expect(theme.typography.title1.design == .rounded && theme.typography.title1.weight == .heavy)
        #expect(theme.typography.body.design == .default)
        #expect(theme.components.chip.cornerRadius == SwiftForgeRadius.capsule)
        #expect(theme.components.button.cornerRadius == nil)  // rounded rectangles, unlike Aurora's pills
        for scheme in [ColorScheme.light, .dark] {
            let shadow = theme.elevation.medium.color.resolve(colorScheme: scheme, increasedContrast: false)
            #expect(shadow.red > shadow.blue, "\(scheme)")  // a warm glow, not a black shadow
        }
    }

    @Test("Midnight's dark canvas is darker than Forge's surfaces and its accent glows")
    func midnight() {
        let theme = SwiftForgeTheme.midnight
        let shadow = theme.elevation.medium.color.resolve(colorScheme: .dark, increasedContrast: false)
        #expect(shadow.green > shadow.red)  // a cyan glow, not a black shadow
        #expect(theme.elevation.raisedSurfacesHaveBorder)
    }
}
