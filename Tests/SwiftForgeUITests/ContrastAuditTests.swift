import SwiftUI
import Testing

@testable import SwiftForgeUI

@Suite("Contrast audit")
struct ContrastAuditTests {

    @Test("Built-in themes have no contrast violations", arguments: SwiftForgeTheme.builtIn)
    func builtInThemesPass(theme: SwiftForgeTheme) {
        let violations = SwiftForgeContrastAudit.run(on: theme)
        #expect(violations.isEmpty, "\(theme.id): \(violations.map(\.description).joined(separator: "\n"))")
    }

    @Test("Contrast ratio matches WCAG reference values")
    func referenceRatios() {
        let white = Color.Resolved(swiftForgeHex: 0xFFFFFF)
        let black = Color.Resolved(swiftForgeHex: 0x000000)
        let gray = Color.Resolved(swiftForgeHex: 0x767676)

        #expect(abs(SwiftForgeContrastAudit.contrastRatio(black, white) - 21) < 0.01)
        #expect(abs(SwiftForgeContrastAudit.contrastRatio(white, white) - 1) < 0.01)
        // #767676 on white is the well-known 4.54:1 AA threshold gray.
        #expect(abs(SwiftForgeContrastAudit.contrastRatio(gray, white) - 4.54) < 0.01)
        // Contrast is symmetric.
        #expect(SwiftForgeContrastAudit.contrastRatio(gray, white) == SwiftForgeContrastAudit.contrastRatio(white, gray))
    }

    @Test("Translucent foregrounds are composited before measuring")
    func translucentForeground() {
        let halfBlack = Color.Resolved(swiftForgeHex: 0x000000, opacity: 0.5)
        let white = Color.Resolved(swiftForgeHex: 0xFFFFFF)
        let ratio = SwiftForgeContrastAudit.contrastRatio(halfBlack, white)
        // 50% black over white is #808080 → about 3.95:1.
        #expect(ratio > 3.9 && ratio < 4.0)
    }

    @Test("A low-contrast custom theme is reported")
    func detectsViolations() {
        var theme = SwiftForgeTheme.forge
        theme.colors.textSecondary = SwiftForgeColor(light: 0xC7C7CC, dark: 0x48484A)
        let violations = SwiftForgeContrastAudit.run(on: theme)
        #expect(violations.contains { $0.foreground == "textSecondary" && $0.appearance == .light })
        #expect(violations.contains { $0.foreground == "textSecondary" && $0.appearance == .dark })
        #expect(violations.allSatisfy { $0.ratio < $0.required })
    }

    @Test(
        "Derived tones meet text contrast against standard surfaces",
        arguments: [0x5B3CC4, 0xE4572E, 0x00A6A6, 0xF2C14E, 0x2E294E] as [UInt32]
    )
    func derivedTonesAreAccessible(hex: UInt32) {
        var theme = SwiftForgeTheme.forge
        theme.colors.accent = .derived(from: SwiftForgeColor(light: hex, dark: hex))
        let accentViolations = SwiftForgeContrastAudit.run(on: theme).filter { $0.foreground.hasPrefix("accent.") }
        #expect(accentViolations.isEmpty, "\(accentViolations.map(\.description))")
    }
}

@Suite("Contrast audit of theme fills and component tokens")
struct ContrastAuditFillTests {

    @Test("A gradient stop that's too light for white text is reported")
    func gradientStop() {
        var theme = SwiftForgeTheme.forge
        theme.colors.accent.solidFill = .linearGradient([SwiftForgeColor(hex: 0x0062D1), SwiftForgeColor(hex: 0x7DD3FC)])
        let violations = SwiftForgeContrastAudit.run(on: theme).filter { $0.appearance == .light }
        #expect(violations.contains { $0.foreground == "accent.onSolid" && $0.background.hasPrefix("accent.solidFill[") })
        // White on the dark-blue stop passes; only the light end fails.
        #expect(!violations.contains { $0.background == "accent.solidFill[0]" })
    }

    @Test("Text must contrast with a material surface's fallback")
    func materialFallback() {
        var theme = SwiftForgeTheme.forge
        theme.components.surface.fills[.raised] = .material(.thin, fallback: SwiftForgeColor(hex: 0x8E8E93))
        let violations = SwiftForgeContrastAudit.run(on: theme)
        #expect(violations.contains { $0.foreground == "textSecondary" && $0.background == "fills[.raised][0]" })
    }

    @Test("A button border color must contrast 3:1 with surfaces")
    func buttonBorder() {
        var theme = SwiftForgeTheme.forge
        theme.components.button.borderColor = SwiftForgeColor(hex: 0xD1D1D6)
        let violations = SwiftForgeContrastAudit.run(on: theme)
        #expect(violations.contains { $0.foreground == "components.button.borderColor" && $0.required == 3 })
    }
}

@Suite("Tone derivation")
struct ToneDerivationTests {

    @Test("Derived tones meet contrast against the theme they're derived for")
    func derivedOnTheme() {
        var dark = SwiftForgeTheme.forge
        // A theme whose light-mode surfaces are a mid gray, unlike Forge's white.
        dark.colors.canvas = SwiftForgeColor(light: 0xD4D4D8, dark: 0x000000)
        dark.colors.surface = SwiftForgeColor(light: 0xE4E4E7, dark: 0x1C1C1E)
        dark.colors.surfaceRaised = SwiftForgeColor(light: 0xE4E4E7, dark: 0x2C2C2E)
        let brand = SwiftForgeColor(light: 0x7B61E0, dark: 0x7B61E0)

        dark.colors.accent = .derived(from: brand, on: dark.colors)
        let violations = SwiftForgeContrastAudit.run(on: dark).filter { $0.foreground.hasPrefix("accent.text") }
        #expect(violations.isEmpty, "\(violations.map(\.description))")
    }

    @Test("Deriving for Forge matches the original derivation")
    func forgeDefault() {
        let brand = SwiftForgeColor(light: 0x5B3CC4, dark: 0x7B61E0)
        #expect(SwiftForgeToneColors.derived(from: brand) == .derived(from: brand, on: SwiftForgeTheme.forge.colors))
    }
}

@Suite("Tone derivation keeps theme text readable")
struct ToneDerivationContentTests {

    @Test(
        "Derived tinted backgrounds keep primary and secondary text at AA",
        arguments: [0x0B6E6E, 0x3CC6C6, 0x7B61E0, 0xE4572E, 0xF2C14E] as [UInt32]
    )
    func subtleKeepsText(hex: UInt32) {
        var theme = SwiftForgeTheme.forge
        theme.colors.accent = .derived(from: SwiftForgeColor(light: hex, dark: hex), on: theme.colors)
        let violations = SwiftForgeContrastAudit.run(on: theme).filter { $0.background == "accent.subtle" }
        #expect(violations.isEmpty, "\(violations.map(\.description))")
    }
}
