import SwiftUI
import Testing

@testable import SwiftForgeUI

/// Verifies layout and color contracts of SwiftUI-native components by
/// rendering them. Visual regressions across the full theme × appearance ×
/// Dynamic Type matrix are covered by the Showcase snapshot tests.
@MainActor
@Suite("Component rendering")
struct ComponentRenderingTests {

    // MARK: Button

    @Test("Every button size keeps a 44-pt hit area", arguments: [ControlSize.mini, .small, .regular, .large])
    func buttonHitTarget(size: ControlSize) {
        let button = Button("A") {}.buttonStyle(.swiftForge(.plain)).controlSize(size)
        let rendered = RenderedView(button)
        #expect(rendered.size.height >= 44 && rendered.size.width >= 44, "\(size): \(rendered.size)")
    }

    @Test("Icon buttons are at least square and keep the hit area", arguments: [ControlSize.small, .regular, .large])
    func iconButtonHitTarget(size: ControlSize) {
        let button = Button("Close", systemImage: "xmark") {}.buttonStyle(.swiftForgeIcon(.tinted)).controlSize(size)
        let rendered = RenderedView(button)
        #expect(rendered.size.height >= 44 && rendered.size.width >= 44)
    }

    @Test("Large buttons are 52 pt tall")
    func largeButtonHeight() {
        let rendered = RenderedView(Button("Continue") {}.buttonStyle(.swiftForge()).controlSize(.large))
        #expect(rendered.size.height == 52)
    }

    @Test("Buttons hug their content unless full width is requested")
    func buttonWidth() {
        let hugging = RenderedView(Button("OK") {}.buttonStyle(.swiftForge()), width: 300)
        // The proposed 300 pt frame centers a narrower button: its edges are clear.
        #expect(hugging.color(x: 2, y: 22).alpha == 0)

        let full = RenderedView(Button("OK") {}.buttonStyle(.swiftForge()).swiftForgeFullWidth(), width: 300)
        #expect(full.matches(x: 6, y: 22, hex: 0x0062D1))
    }

    @Test("Filled buttons draw the tone's solid color", arguments: [ColorScheme.light, .dark])
    func filledButtonColor(colorScheme: ColorScheme) {
        let button = Button("Delete", role: .destructive) {}.buttonStyle(.swiftForge(.filled)).swiftForgeFullWidth()
        let rendered = RenderedView(button, width: 200, colorScheme: colorScheme)
        #expect(rendered.matches(x: 8, y: 22, hex: colorScheme == .light ? 0xD70015 : 0xD42A22))
    }

    @Test("Disabled buttons fade; loading buttons don't")
    func disabledVersusLoading() {
        func backgroundAlpha<V: View>(_ view: V) -> Int {
            RenderedView(view.buttonStyle(.swiftForge()).swiftForgeFullWidth(), width: 200).color(x: 8, y: 22).alpha
        }
        #expect(backgroundAlpha(Button("Save") {}) == 255)
        #expect(backgroundAlpha(Button("Save") {}.disabled(true)) < 128)
        #expect(backgroundAlpha(Button("Save") {}.swiftForgeLoading(true)) == 255)
    }

    // MARK: Surfaces

    @Test("A standard card stands out from the canvas", arguments: SwiftForgeTheme.builtIn)
    func cardOnCanvas(theme: SwiftForgeTheme) {
        let view = SwiftForgeCard { Color.clear.frame(height: 40) }
            .padding(20)
            .background(theme.colors.canvas)
            .swiftForgeTheme(theme)
        let rendered = RenderedView(view, width: 200)
        let canvas = rendered.color(x: 5, y: 5)
        let card = rendered.color(x: 100, y: 40)
        #expect(canvas.red != card.red || canvas.green != card.green || canvas.blue != card.blue)
    }

    @Test("Increased contrast adds a border to surfaces")
    func increasedContrastBorder() {
        func edge(_ simulated: Bool) -> (red: Int, green: Int, blue: Int, alpha: Int) {
            let view = SwiftForgeCard { Color.clear.frame(height: 40) }
                .padding(20)
                .background(Color.white)
                .swiftForgeAccessibilitySimulation(increasedContrast: simulated)
            return RenderedView(view, width: 200).color(x: 100, y: 20)
        }
        #expect(edge(false).red == 255)
        #expect(edge(true).red < 200)
    }

    // MARK: Divider

    @Test("Dividers follow the stack axis")
    func dividerAxis() {
        let vertical = RenderedView(
            HStack(spacing: 0) {
                Color.white.frame(width: 10)
                SwiftForgeDivider()
                Color.white.frame(width: 10)
            },
            height: 10
        )
        #expect(vertical.size.width == 21)
        #expect(vertical.matches(x: 10, y: 5, hex: 0xD1D1D6))

        let horizontal = RenderedView(
            VStack(spacing: 0) {
                Color.white.frame(height: 10)
                SwiftForgeDivider()
                Color.white.frame(height: 10)
            },
            width: 10
        )
        #expect(horizontal.size.height == 21)
        #expect(horizontal.matches(x: 5, y: 10, hex: 0xD1D1D6))
    }

    // MARK: Progress

    @Test("Linear progress fills from the leading edge", arguments: [LayoutDirection.leftToRight, .rightToLeft])
    func linearProgressDirection(direction: LayoutDirection) {
        let view = ProgressView(value: 0.25)
            .progressViewStyle(.swiftForgeLinear)
            .environment(\.layoutDirection, direction)
        let rendered = RenderedView(view, width: 100)
        let middle = Int(rendered.size.height) / 2
        let accent: UInt32 = 0x0062D1
        let track: UInt32 = 0xE5E5EA
        if direction == .leftToRight {
            #expect(rendered.matches(x: 12, y: middle, hex: accent))
            #expect(rendered.matches(x: 88, y: middle, hex: track))
        } else {
            #expect(rendered.matches(x: 88, y: middle, hex: accent))
            #expect(rendered.matches(x: 12, y: middle, hex: track))
        }
    }

    // MARK: Skeleton

    @Test("The shimmer band sweeps from the leading edge", arguments: [LayoutDirection.leftToRight, .rightToLeft])
    func shimmerDirection(direction: LayoutDirection) {
        let view = SwiftForgeSkeletonShape()
            .environment(\.swiftForgeShimmerPhase, 0.25)
            .environment(\.layoutDirection, direction)
        let rendered = RenderedView(view, width: 100, height: 20)
        let nearLeft = rendered.color(x: 10, y: 10).alpha
        let nearRight = rendered.color(x: 90, y: 10).alpha
        // Early in the sweep, the band (lower opacity) is near the leading edge.
        if direction == .leftToRight {
            #expect(nearLeft < nearRight)
        } else {
            #expect(nearRight < nearLeft)
        }
    }

    @Test("Reduce Motion stops the shimmer")
    func shimmerReduceMotion() {
        let view = SwiftForgeSkeletonShape()
            .environment(\.swiftForgeShimmerPhase, 0.25)
            .swiftForgeAccessibilitySimulation(reduceMotion: true)
        let rendered = RenderedView(view, width: 100, height: 20)
        #expect(rendered.color(x: 10, y: 10).alpha == rendered.color(x: 90, y: 10).alpha)
    }

    // MARK: Badge

    @Test("Single-digit count badges are circular")
    func countBadgeIsCircular() {
        let rendered = RenderedView(SwiftForgeBadge(count: 3))
        #expect(rendered.size.width == rendered.size.height)
    }

    @Test("A zero count renders nothing")
    func zeroCountIsHidden() {
        let rendered = RenderedView(SwiftForgeBadge(count: 0).frame(minWidth: 1, minHeight: 1))
        #expect(rendered.color(x: 0, y: 0).alpha == 0)
    }
}
