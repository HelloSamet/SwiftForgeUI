import SwiftUI
import Testing

@testable import SwiftForgeUI

@Suite("Theme")
struct ThemeTests {

    @Test("The environment defaults to the Forge theme")
    func environmentDefault() {
        #expect(EnvironmentValues().swiftForgeTheme == .forge)
    }

    @Test("Writing a theme into the environment round-trips")
    func environmentRoundTrip() {
        var environment = EnvironmentValues()
        environment.swiftForgeTheme = .paper
        #expect(environment.swiftForgeTheme == .paper)
    }

    @Test("Built-in themes are distinct and uniquely named")
    func builtInThemes() {
        #expect(SwiftForgeTheme.builtIn.count == 8)
        #expect(Set(SwiftForgeTheme.builtIn).count == SwiftForgeTheme.builtIn.count)
        #expect(Set(SwiftForgeTheme.builtIn.map(\.id)).count == SwiftForgeTheme.builtIn.count)
    }

    @Test("Paper's ink accent flips polarity between light and dark")
    func paperAccentFlips() {
        let accent = SwiftForgeTheme.paper.colors.accent
        let lightSolid = accent.solid.resolve(colorScheme: .light, increasedContrast: false)
        let darkSolid = accent.solid.resolve(colorScheme: .dark, increasedContrast: false)
        let lightContent = accent.onSolid.resolve(colorScheme: .light, increasedContrast: false)
        #expect(WCAG.relativeLuminance(lightSolid) < 0.1)
        #expect(WCAG.relativeLuminance(darkSolid) > 0.8)  // warm chalk, not pure white
        #expect(WCAG.relativeLuminance(lightContent) > 0.8)
    }

    @Test("Tone subscript reads and writes every tone", arguments: SwiftForgeTone.allCases)
    func toneSubscript(tone: SwiftForgeTone) {
        var colors = SwiftForgeTheme.forge.colors
        let replacement = SwiftForgeToneColors(solid: .black, onSolid: .white, text: .black, subtle: .white)
        colors[tone] = replacement
        #expect(colors[tone] == replacement)
        for other in SwiftForgeTone.allCases where other != tone {
            #expect(colors[other] == SwiftForgeTheme.forge.colors[other])
        }
    }

    @Test("Overriding one category leaves the others unchanged")
    func partialOverride() {
        var theme = SwiftForgeTheme.forge
        theme.radius = SwiftForgeTheme.paper.radius
        #expect(theme.radius == SwiftForgeTheme.paper.radius)
        #expect(theme.colors == SwiftForgeTheme.forge.colors)
        #expect(theme.typography == SwiftForgeTheme.forge.typography)
    }
}
