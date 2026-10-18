import SwiftUI
import Testing

@testable import SwiftForgeUI

@Suite("Color tokens")
struct ColorTokenTests {

    let token = SwiftForgeColor(light: 0xFF0000, dark: 0x0000FF, lightHighContrast: 0x880000, darkHighContrast: 0x00FF00)

    @Test("Resolves each appearance to its own value")
    func resolvesAppearances() {
        #expect(token.resolve(colorScheme: .light, increasedContrast: false) == Color.Resolved(swiftForgeHex: 0xFF0000))
        #expect(token.resolve(colorScheme: .dark, increasedContrast: false) == Color.Resolved(swiftForgeHex: 0x0000FF))
        #expect(token.resolve(colorScheme: .light, increasedContrast: true) == Color.Resolved(swiftForgeHex: 0x880000))
        #expect(token.resolve(colorScheme: .dark, increasedContrast: true) == Color.Resolved(swiftForgeHex: 0x00FF00))
    }

    @Test("High-contrast values default to the regular values")
    func highContrastFallback() {
        let plain = SwiftForgeColor(light: 0x111111, dark: 0xEEEEEE)
        #expect(
            plain.resolve(colorScheme: .light, increasedContrast: true)
                == plain.resolve(colorScheme: .light, increasedContrast: false))
        #expect(
            plain.resolve(colorScheme: .dark, increasedContrast: true)
                == plain.resolve(colorScheme: .dark, increasedContrast: false))
    }

    @Test("Resolving in an environment honors color scheme and the contrast simulation")
    func resolvesInEnvironment() {
        var environment = EnvironmentValues()
        environment.colorScheme = .dark
        #expect(token.resolve(in: environment) == Color.Resolved(swiftForgeHex: 0x0000FF))

        environment.swiftForgeAccessibilitySimulation = SwiftForgeAccessibilitySimulation(increasedContrast: true)
        #expect(token.resolve(in: environment) == Color.Resolved(swiftForgeHex: 0x00FF00))
    }

    @Test("withOpacity scales every appearance")
    func withOpacity() {
        let half = token.withOpacity(0.5)
        for scheme in [ColorScheme.light, .dark] {
            for contrast in [false, true] {
                let resolved = half.resolve(colorScheme: scheme, increasedContrast: contrast)
                #expect(abs(resolved.opacity - 0.5) < 0.001)
            }
        }
    }

    @Test("Fixed-value tokens are explicit; wrapped SwiftUI colors aren't")
    func explicitness() {
        #expect(token.isExplicit)
        #expect(SwiftForgeColor(hex: 0x123456).isExplicit)
        #expect(!SwiftForgeColor(Color.red).isExplicit)
    }

    @Test("A wrapped SwiftUI color resolves through SwiftUI")
    func wrappedColor() {
        let wrapped = SwiftForgeColor(Color(red: 0, green: 0, blue: 1))
        let resolved = wrapped.resolve(colorScheme: .light, increasedContrast: false)
        #expect(resolved.blue > 0.99 && resolved.red < 0.01)
    }

    @Test("A token renders as its resolved color", arguments: [ColorScheme.light, .dark])
    @MainActor
    func rendersAsShapeStyle(colorScheme: ColorScheme) {
        let rendered = RenderedView(Rectangle().fill(token), width: 4, height: 4, colorScheme: colorScheme)
        #expect(rendered.matches(x: 1, y: 1, hex: colorScheme == .light ? 0xFF0000 : 0x0000FF))
    }

    @Test("The contrast simulation reaches rendered tokens")
    @MainActor
    func simulationRenders() {
        let view = Rectangle().fill(token).swiftForgeAccessibilitySimulation(increasedContrast: true)
        let rendered = RenderedView(view, width: 4, height: 4, colorScheme: .dark)
        #expect(rendered.matches(x: 1, y: 1, hex: 0x00FF00))
    }
}

@Suite("Accessibility simulation")
struct AccessibilitySimulationTests {

    @Test("Defaults to deferring to the system")
    func defaults() {
        let simulation = SwiftForgeAccessibilitySimulation()
        #expect(!simulation.increasedContrast && !simulation.reduceMotion && !simulation.reduceTransparency)
        #expect(!EnvironmentValues().swiftForgeIncreasedContrast)
    }

    @Test("Simulated increased contrast turns high-contrast colors on")
    func increasedContrast() {
        var environment = EnvironmentValues()
        environment.swiftForgeAccessibilitySimulation.increasedContrast = true
        #expect(environment.swiftForgeIncreasedContrast)
    }
}
