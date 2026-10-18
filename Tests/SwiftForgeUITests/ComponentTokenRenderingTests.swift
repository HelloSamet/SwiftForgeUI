import SwiftUI
import Testing

@testable import SwiftForgeUI

extension SwiftForgeTheme {

    /// A neo-brutalist prototype built only from tokens: sharp corners, thick
    /// black borders, and a hard offset shadow. It proves a theme can change a
    /// component's silhouette without touching component code.
    static let brutalPrototype = SwiftForgeTheme(id: "brutal-prototype", displayName: "Brutal", basedOn: .forge) { theme in
        let ink = SwiftForgeColor(light: 0x000000, dark: 0xFFFFFF)
        theme.radius.control = 0
        theme.radius.controlSmall = 0
        theme.radius.card = 0
        theme.elevation.low = SwiftForgeShadow(color: ink, radius: 0, x: 4, y: 4)
        theme.components.button = SwiftForgeButtonTokens(
            borderWidth: 3, borderColor: ink, elevation: .low, pressEffect: .sinkIntoShadow)
        theme.components.surface = SwiftForgeSurfaceTokens(borderWidth: 3, borderColor: ink, bordersEverySurface: true)
        theme.components.field = SwiftForgeFieldTokens(style: .underlined)
        theme.components.toggle = SwiftForgeToggleTokens(cornerRadius: 0, borderWidth: 2, borderColor: ink)
        theme.components.badge = SwiftForgeBadgeTokens(cornerRadius: 0, borderWidth: 2, borderColor: ink)
        theme.components.banner = SwiftForgeBannerTokens(cornerRadius: 0, borderWidth: 2)
        theme.components.progress = SwiftForgeProgressTokens(barHeight: 10, barCornerRadius: 0)
    }
}

/// Renders components under themes that differ only in tokens.
@MainActor
@Suite("Component tokens")
struct ComponentTokenRenderingTests {

    /// A full-width filled button 200 × 44 pt, inset 8 pt so its shadow is visible.
    private func filledButton(_ theme: SwiftForgeTheme) -> RenderedView {
        let button = Button("Save") {}
            .buttonStyle(.swiftForge(.filled))
            .swiftForgeFullWidth()
            .padding(8)
            .swiftForgeTheme(theme)
        return RenderedView(button, width: 216)
    }

    @Test("Forge buttons have soft corners, no border, and no shadow")
    func forgeButton() {
        let rendered = filledButton(.forge)
        #expect(rendered.color(x: 8, y: 8).alpha == 0)  // rounded corner
        #expect(rendered.matches(x: 9, y: 30, hex: 0x0062D1))  // no border
        #expect(rendered.color(x: 210, y: 30).alpha == 0)  // no shadow
    }

    @Test("Token overrides give buttons sharp corners, a border, and a hard shadow")
    func brutalButton() {
        let rendered = filledButton(.brutalPrototype)
        #expect(rendered.matches(x: 8, y: 8, hex: 0x000000))  // sharp corner, drawn by the border
        #expect(rendered.matches(x: 9, y: 30, hex: 0x000000))  // 3-pt border
        #expect(rendered.matches(x: 14, y: 30, hex: 0x0062D1))  // fill inside the border
        #expect(rendered.matches(x: 210, y: 30, hex: 0x000000))  // shadow offset 4 pt right…
        #expect(rendered.color(x: 210, y: 9).alpha == 0)  // …and 4 pt down
    }

    @Test("A capsule corner radius makes pill-shaped buttons")
    func capsuleButton() {
        var theme = SwiftForgeTheme.forge
        theme.components.button.cornerRadius = SwiftForgeRadius.capsule
        // (11, 16) is inside a 12-pt corner but outside a 22-pt one.
        #expect(filledButton(.forge).color(x: 11, y: 16).alpha == 255)
        #expect(filledButton(theme).color(x: 11, y: 16).alpha == 0)
    }

    @Test("A tone's solid fill paints filled buttons with a gradient")
    func gradientButton() {
        var theme = SwiftForgeTheme.forge
        theme.colors.accent.solidFill = .linearGradient(
            [SwiftForgeColor(hex: 0x5B21B6), SwiftForgeColor(hex: 0x0E7490)], startPoint: .leading, endPoint: .trailing)
        let rendered = filledButton(theme)
        let leading = rendered.color(x: 12, y: 30)
        let trailing = rendered.color(x: 204, y: 30)
        #expect(leading.red > trailing.red)
        #expect(leading.green < trailing.green)
    }

    @Test("Surface tokens border every card")
    func surfaceBorders() {
        func edge(_ theme: SwiftForgeTheme) -> Bool {
            let card = SwiftForgeCard { Color.clear.frame(height: 40) }.swiftForgeTheme(theme)
            return RenderedView(card, width: 200).matches(x: 1, y: 30, hex: 0x000000)
        }
        #expect(!edge(.forge))
        #expect(edge(.brutalPrototype))
    }

    @Test("A material surface shows its fallback with Reduce Transparency on")
    func materialSurface() {
        var theme = SwiftForgeTheme.forge
        theme.components.surface.fills[.surface] = .material(.thin, fallback: SwiftForgeColor(hex: 0x336699))
        let card = SwiftForgeCard { Color.clear.frame(height: 40) }
            .swiftForgeTheme(theme)
            .swiftForgeAccessibilitySimulation(reduceTransparency: true)
        #expect(RenderedView(card, width: 200).matches(x: 100, y: 30, hex: 0x336699))
    }

    // MARK: Toggle

    private func toggle(isOn: Bool, theme: SwiftForgeTheme = .forge) -> RenderedView {
        let view = Toggle("Wi-Fi", isOn: .constant(isOn))
            .toggleStyle(.swiftForge)
            .swiftForgeTheme(theme)
        return RenderedView(view, width: 200)
    }

    @Test("A switch shows its state by the thumb's position, and fills its track when on")
    func toggleStates() {
        // The 51 × 31 pt track sits at the trailing edge of the 44-pt-tall row.
        let on = toggle(isOn: true)
        #expect(on.size.height >= 44)
        #expect(on.matches(x: 156, y: 22, hex: 0x0062D1))  // track, leading side
        #expect(on.matches(x: 184, y: 22, hex: 0xFFFFFF))  // thumb, trailing side

        let off = toggle(isOn: false)
        #expect(off.matches(x: 166, y: 22, hex: 0x48484A))  // neutral thumb, leading side
        #expect(off.matches(x: 190, y: 22, hex: 0xE5E5EA))  // muted track, trailing side
        #expect(off.matches(x: 199, y: 22, hex: 0x7C7C80))  // strong outline
    }

    @Test("Toggle tokens square the track and outline it in both states")
    func brutalToggle() {
        let on = toggle(isOn: true, theme: .brutalPrototype)
        #expect(on.matches(x: 150, y: 8, hex: 0x000000))  // square corner, drawn by the border
        #expect(toggle(isOn: true).color(x: 150, y: 8).alpha < 255)  // Forge's capsule corner
    }

    // MARK: Badge, banner, progress

    @Test("Badge tokens replace the capsule with a bordered rectangle")
    func badgeShape() {
        func corner(_ theme: SwiftForgeTheme) -> (red: Int, green: Int, blue: Int, alpha: Int) {
            RenderedView(SwiftForgeBadge("New", tone: .info).swiftForgeTheme(theme)).color(x: 0, y: 0)
        }
        #expect(corner(.forge).alpha == 0)
        #expect(corner(.brutalPrototype) == (0, 0, 0, 255))
    }

    @Test("Progress tokens set the bar's thickness and corners")
    func progressBar() {
        func bar(_ theme: SwiftForgeTheme) -> RenderedView {
            RenderedView(ProgressView(value: 1).progressViewStyle(.swiftForgeLinear).swiftForgeTheme(theme), width: 100)
        }
        #expect(bar(.forge).size.height == 4)
        #expect(bar(.forge).color(x: 0, y: 0).alpha < 255)
        #expect(bar(.brutalPrototype).size.height == 10)
        #expect(bar(.brutalPrototype).matches(x: 0, y: 0, hex: 0x0062D1))
    }

    @Test("Banner tokens square its corners and outline it in the tone's color")
    func bannerShape() {
        let banner = SwiftForgeBanner(.danger, title: "Couldn't save").swiftForgeTheme(.brutalPrototype)
        #expect(RenderedView(banner, width: 300).matches(x: 0, y: 0, hex: 0xC4001A))
    }

    @Test("Underlined fields drop their horizontal inset")
    func underlinedInset() {
        #expect(SwiftForgeTheme.forge.fieldContentInset == SwiftForgeTheme.forge.spacing.sm)
        #expect(SwiftForgeTheme.brutalPrototype.fieldContentInset == 0)
    }

    @Test("The brutal prototype is still accessible")
    func prototypeContrast() {
        #expect(SwiftForgeContrastAudit.run(on: .brutalPrototype).isEmpty)
    }
}
