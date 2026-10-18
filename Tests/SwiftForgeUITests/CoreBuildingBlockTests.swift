import SwiftUI
import Testing

@testable import SwiftForgeUI

/// The shared building blocks every component is made of: focus ring, press
/// feedback, density, icons, and the field container and style.
@MainActor
@Suite("Core building blocks")
struct CoreBuildingBlockTests {

    private let theme = SwiftForgeTheme.forge

    // MARK: Focus ring

    /// The ring's outer band on the leading side: offset 2 pt and width 2 pt
    /// outside a view inset 10 pt cover x = 6..<8.
    private var ringColumn: Int { 10 - Int(theme.borders.focusRingOffset + theme.borders.thick) + 1 }

    // An opaque background writes every pixel: ImageRenderer can reuse a
    // backing buffer of the same size without clearing it, so a pixel nothing
    // draws to may still hold an earlier render.
    private func renderRing(_ isVisible: Bool) -> RenderedView {
        RenderedView(
            Color.white.frame(width: 40, height: 40)
                .swiftForgeFocusRing(isVisible, cornerRadius: 0)
                .padding(10)
                .background(Color.white)
        )
    }

    @Test("The focus ring surrounds the view at the theme's offset, only when visible")
    func focusRing() {
        #expect(renderRing(true).matches(x: ringColumn, y: 30, token: theme.colors.focusRing))
        #expect(renderRing(true).matches(x: 30, y: 30, hex: 0xFFFFFF))
        #expect(renderRing(false).matches(x: ringColumn, y: 30, hex: 0xFFFFFF))
    }

    // MARK: Press feedback

    @Test("Only a pressed control with a visible shadow sinks into it")
    func sinking() {
        let shadow = SwiftForgeShadow(color: .black, radius: 0, x: 4, y: 4)
        #expect(SwiftForgePressEffect.sinkIntoShadow.sinks(isPressed: true, shadow: shadow))
        #expect(!SwiftForgePressEffect.sinkIntoShadow.sinks(isPressed: false, shadow: shadow))
        #expect(!SwiftForgePressEffect.sinkIntoShadow.sinks(isPressed: true, shadow: .none))
        #expect(!SwiftForgePressEffect.scale(0.9).sinks(isPressed: true, shadow: shadow))
    }

    // MARK: Density

    @Test("Density steps grow from compact to spacious", arguments: SwiftForgeTheme.builtIn)
    func densityIsMonotonic(theme: SwiftForgeTheme) {
        let rows = SwiftForgeDensity.allCases.map { $0.rowPadding(in: theme.spacing) }
        let items = SwiftForgeDensity.allCases.map { $0.itemSpacing(in: theme.spacing) }
        #expect(rows == rows.sorted() && Set(rows).count == rows.count)
        #expect(items == items.sorted() && Set(items).count == items.count)
    }

    @Test("Density defaults to regular and is set through the environment")
    func densityEnvironment() {
        #expect(EnvironmentValues().swiftForgeDensity == .regular)
        var environment = EnvironmentValues()
        environment.swiftForgeDensity = .compact
        #expect(environment.swiftForgeDensity == .compact)
    }

    // MARK: Icons

    @Test(
        "Icons take the theme's size for the control size",
        arguments: [(ControlSize.small, 16), (.regular, 20), (.large, 24)] as [(ControlSize, CGFloat)]
    )
    func iconSize(controlSize: ControlSize, expected: CGFloat) {
        let rendered = RenderedView(SwiftForgeIcon(Image(systemName: "star.fill")).controlSize(controlSize))
        #expect(rendered.size == CGSize(width: expected, height: expected))
    }

    @Test("Icons grow with Dynamic Type")
    func iconScales() {
        let rendered = RenderedView(
            SwiftForgeIcon(Image(systemName: "star.fill")).environment(\.dynamicTypeSize, .accessibility5))
        #expect(rendered.size.width > 40)
    }

    @Test("Mono's smaller icon tokens reach the icon")
    func iconFollowsTheme() {
        let rendered = RenderedView(SwiftForgeIcon(Image(systemName: "star.fill")).swiftForgeTheme(.mono))
        #expect(rendered.size.width == SwiftForgeTheme.mono.sizes.iconRegular)
    }

    @Test(
        "Icon placement puts a button's icon before or after its title, following reading direction",
        arguments: [
            (SwiftForgeIconPlacement.leading, LayoutDirection.leftToRight, true),
            (.trailing, .leftToRight, false),
            (.leading, .rightToLeft, false),
            (.trailing, .rightToLeft, true),
        ] as [(SwiftForgeIconPlacement, LayoutDirection, Bool)]
    )
    func iconPlacement(placement: SwiftForgeIconPlacement, direction: LayoutDirection, iconIsOnLeft: Bool) {
        let button = Button {
        } label: {
            Label {
                Text(verbatim: "Continue")
            } icon: {
                // A fixed sRGB red: system colors change between OS releases
                // (iOS 26's red has more blue than the threshold below allows).
                Color(.sRGB, red: 1, green: 0, blue: 0).frame(width: 10, height: 10)
            }
        }
        .buttonStyle(.swiftForge(.plain))
        .swiftForgeIconPlacement(placement)
        .environment(\.layoutDirection, direction)
        let rendered = RenderedView(button)
        let middle = Int(rendered.size.height) / 2
        let redColumns = (0..<Int(rendered.size.width)).filter {
            let pixel = rendered.color(x: $0, y: middle)
            return pixel.red > 200 && pixel.green < 60 && pixel.blue < 60
        }
        #expect(!redColumns.isEmpty)
        let center = Int(rendered.size.width) / 2
        #expect(((redColumns.max() ?? 0) < center) == iconIsOnLeft)
    }

    // MARK: Field container and style

    /// Paints the input area with the theme's accent, reading the theme
    /// through `@Environment` like a third-party style would.
    private struct AccentFieldStyle: SwiftForgeFieldStyle {
        @Environment(\.swiftForgeTheme) private var theme

        func makeBody(configuration: Configuration) -> some View {
            configuration.content.background(theme.colors.accent.solid)
        }
    }

    /// Reports what the configuration carries by drawing colored bars.
    private struct ProbeFieldStyle: SwiftForgeFieldStyle {
        static let on = Color(red: 0, green: 1, blue: 0)
        static let off = Color(red: 1, green: 0, blue: 0)

        func makeBody(configuration: Configuration) -> some View {
            VStack(spacing: 0) {
                (configuration.message == nil ? Self.off : Self.on).frame(height: 10)
                (configuration.optionalNote == nil ? Self.off : Self.on).frame(height: 10)
                (configuration.isFocused ? Self.on : Self.off).frame(height: 10)
            }
        }
    }

    private func isGreen(_ rendered: RenderedView, y: Int) -> Bool {
        let pixel = rendered.color(x: 5, y: y)
        return pixel.green > 100 && pixel.red < 50
    }

    @Test("A custom field style draws the field and reads the environment", arguments: [SwiftForgeTheme.forge, .neoBrutal])
    func customFieldStyle(theme: SwiftForgeTheme) {
        let field = SwiftForgeFieldContainer("Name") {
            Color.clear.frame(height: 20)
        }
        .swiftForgeFieldStyle(AccentFieldStyle())
        .swiftForgeTheme(theme)
        let rendered = RenderedView(field, width: 100)
        #expect(rendered.matches(x: 50, y: Int(rendered.size.height) / 2, token: theme.colors.accent.solid))
    }

    @Test("Disabled fields dim whatever their style")
    func disabledFieldDims() {
        let field = SwiftForgeFieldContainer("Name") { Color.clear.frame(height: 20) }
            .swiftForgeFieldStyle(AccentFieldStyle())
            .disabled(true)
        let rendered = RenderedView(field, width: 100)
        #expect(rendered.color(x: 50, y: Int(rendered.size.height) / 2).alpha < 128)
    }

    @Test("The configuration carries the message row, optional note, and focus only when they apply")
    func configurationContents() {
        func probe<V: View>(_ field: V) -> RenderedView {
            RenderedView(field.swiftForgeFieldStyle(ProbeFieldStyle()), width: 10)
        }
        let plain = probe(SwiftForgeFieldContainer("Name") { Color.clear })
        #expect(!isGreen(plain, y: 5) && !isGreen(plain, y: 15) && !isGreen(plain, y: 25))

        let rich = probe(
            SwiftForgeFieldContainer("Name", state: .helper("Shown publicly."), isFocused: true) { Color.clear }
                .swiftForgeOptionalField())
        #expect(isGreen(rich, y: 5) && isGreen(rich, y: 15) && isGreen(rich, y: 25))
    }

    @Test("The counter appears only with both a character count and a limit")
    func counterNeedsCountAndLimit() {
        #expect(!SwiftForgeFieldMessage.isVisible(state: .normal, characterCount: 3, characterLimit: nil))
        #expect(!SwiftForgeFieldMessage.isVisible(state: .normal, characterCount: nil, characterLimit: 10))
        #expect(SwiftForgeFieldMessage.isVisible(state: .normal, characterCount: 3, characterLimit: 10))
        #expect(SwiftForgeFieldMessage.isVisible(state: .error("Required."), characterCount: nil, characterLimit: nil))

        func messageRow<V: View>(_ field: V) -> Bool {
            isGreen(RenderedView(field.swiftForgeFieldStyle(ProbeFieldStyle()), width: 10), y: 5)
        }
        #expect(messageRow(SwiftForgeFieldContainer("Bio", characterCount: 3) { Color.clear }.swiftForgeCharacterLimit(80)))
        #expect(!messageRow(SwiftForgeFieldContainer("Bio", characterCount: 3) { Color.clear }))
    }

    @Test("The default field style is the automatic style")
    func defaultFieldStyle() {
        #expect(EnvironmentValues().swiftForgeFieldStyle is SwiftForgeAutomaticFieldStyle)
    }

    // MARK: Text color and screen

    @Test("A text style with a color draws in that theme color", arguments: [SwiftForgeTheme.forge, .midnight, .paper])
    func textStyleColor(theme: SwiftForgeTheme) {
        func render(_ color: KeyPath<SwiftForgeColors, SwiftForgeColor>) -> RenderedView {
            RenderedView(
                Rectangle().frame(width: 20, height: 20)
                    .swiftForgeTextStyle(\.body, color: color)
                    .padding(4)
                    .background(Color.white)
                    .swiftForgeTheme(theme)
            )
        }
        #expect(render(\.textSecondary).matches(x: 14, y: 14, token: theme.colors.textSecondary))
        #expect(render(\.danger.text).matches(x: 14, y: 14, token: theme.colors.danger.text))
    }

    @Test("A screen is drawn on the theme's canvas", arguments: [ColorScheme.light, .dark])
    func screenCanvas(colorScheme: ColorScheme) {
        let theme = SwiftForgeTheme.midnight
        let screen = RenderedView(
            Color.clear.frame(width: 40, height: 40).swiftForgeScreen().swiftForgeTheme(theme),
            colorScheme: colorScheme)
        #expect(screen.matches(x: 20, y: 20, token: theme.colors.canvas, colorScheme: colorScheme))
    }
}
