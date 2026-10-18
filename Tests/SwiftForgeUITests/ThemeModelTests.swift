import SwiftUI
import Testing

@testable import SwiftForgeUI

@Suite("Theme model")
struct ThemeModelTests {

    @Test("Built-in themes have stable, unique identifiers")
    func identifiers() {
        #expect(SwiftForgeTheme.forge.id == "forge")
        #expect(SwiftForgeTheme.forge.displayName == "Forge")
        #expect(Set(SwiftForgeTheme.builtIn.map(\.id)).count == SwiftForgeTheme.builtIn.count)
        #expect(SwiftForgeTheme.builtIn.first == .forge)
    }

    @Test("A theme based on another copies its tokens and takes a new identity")
    func basedOn() {
        let acme = SwiftForgeTheme(id: "acme", displayName: "Acme", basedOn: .forge) { theme in
            theme.radius.control = 20
        }
        #expect(acme.id == "acme")
        #expect(acme.displayName == "Acme")
        #expect(acme.radius.control == 20)
        #expect(acme.colors == SwiftForgeTheme.forge.colors)
        #expect(SwiftForgeTheme.forge.radius.control == 12)
    }

    @Test("Copies share storage until one of them changes")
    func copyOnWrite() {
        let original = SwiftForgeTheme.forge
        var copy = original
        #expect(copy.sharesStorage(with: original))

        copy.spacing.md = 99
        #expect(!copy.sharesStorage(with: original))
        #expect(original.spacing.md == 16)
        #expect(copy != original)

        copy.spacing.md = 16
        // Equal tokens make equal themes, whatever the storage.
        #expect(copy == original)
        #expect(copy.hashValue == original.hashValue)
    }

    @Test("Every built-in color is explicit, so the audit can verify all four appearances", arguments: SwiftForgeTheme.builtIn)
    func explicitColors(theme: SwiftForgeTheme) {
        let checks = SwiftForgeContrastAudit.checks(for: theme)
        #expect(!checks.isEmpty)
        for check in checks {
            #expect(check.foreground.isExplicit, "\(theme.id): \(check.foregroundName)")
            #expect(check.background.isExplicit, "\(theme.id): \(check.backgroundName)")
        }
    }

    @Test("No theme can shrink a hit area below 44 pt")
    func hitTargetFloor() {
        var sizes = SwiftForgeSizes.standard
        sizes.minimumHitTarget = 30
        #expect(sizes.minimumHitTarget == 44)
        sizes.minimumHitTarget = 48
        #expect(sizes.minimumHitTarget == 48)

        let initialized = SwiftForgeSizes(
            minimumHitTarget: 20, controlHeightSmall: 28, controlHeightRegular: 36, controlHeightLarge: 44,
            iconSmall: 14, iconRegular: 16, iconLarge: 20
        )
        #expect(initialized.minimumHitTarget == 44)
    }

    @Test("Themed shapes clamp their radius and stay concentric when inset")
    func shapes() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 40)
        let capsule = SwiftForgeShape(cornerRadius: SwiftForgeRadius.capsule)
        // A capsule is a rounded rectangle with the largest possible radius.
        #expect(capsule.path(in: rect) == RoundedRectangle(cornerRadius: 20, style: .continuous).path(in: rect))
        #expect(SwiftForgeShape(cornerRadius: 50).path(in: rect) == capsule.path(in: rect))
        #expect(capsule.animatableData.first.isFinite)

        let sharp = SwiftForgeShape(cornerRadius: 0)
        #expect(sharp.path(in: rect).boundingRect == rect)
        #expect(sharp.path(in: rect).contains(CGPoint(x: 0.5, y: 0.5)))

        let inset = SwiftForgeShape(cornerRadius: 12).inset(by: 2)
        #expect(
            inset.path(in: rect) == RoundedRectangle(cornerRadius: 10, style: .continuous).path(in: rect.insetBy(dx: 2, dy: 2)))
    }

    @Test("Gradient fills are audited at their stops and between them")
    func gradientSamples() {
        let fill = SwiftForgeFill.linearGradient([.black, .white])
        let samples = fill.contrastSamples.map { $0.resolve(colorScheme: .light, increasedContrast: false) }
        #expect(samples.count == 5)
        #expect(samples.first == Color.Resolved.swiftForgeBlack)
        #expect(samples.last == Color.Resolved.swiftForgeWhite)
        #expect(abs(samples[2].red - 0.5) < 0.01)
    }

    @Test("A material is audited, and replaced, by its opaque fallback")
    func materialFallback() {
        let fallback = SwiftForgeColor(hex: 0x336699)
        let fill = SwiftForgeFill.material(.thin, fallback: fallback)
        #expect(fill.contrastSamples == [fallback])
    }
}

@Suite("Theme environment")
@MainActor
struct ThemeEnvironmentTests {

    private struct AccentProbe: View {
        @Environment(\.swiftForgeTheme) private var theme
        var body: some View {
            Rectangle().fill(theme.colors.accent.solid).frame(width: 10, height: 10)
        }
    }

    @Test("Components without a theme use Forge")
    func defaultTheme() {
        #expect(RenderedView(AccentProbe()).matches(x: 5, y: 5, hex: 0x0062D1))
    }

    @Test("The innermost theme wins, so a subtree can use its own theme")
    func nestedThemes() {
        let view = VStack(spacing: 0) {
            AccentProbe()
            AccentProbe().swiftForgeTheme(.paper)
        }
        .swiftForgeTheme(.forge)
        let rendered = RenderedView(view)
        #expect(rendered.matches(x: 5, y: 5, hex: 0x0062D1))
        #expect(rendered.matches(x: 5, y: 15, hex: 0x1C1A17))
    }
}

@Suite("Bold Text")
@MainActor
struct BoldTextTests {

    private static let custom = SwiftForgeTheme(id: "custom-font", displayName: "Custom", basedOn: .forge) { theme in
        theme.typography.fontFamily = .custom(
            regular: "Inter-Regular", medium: "Inter-Medium", semibold: "Inter-SemiBold", bold: "Inter-Bold")
    }

    private struct WeightProbe: View {
        let onRead: (SwiftForgeTheme) -> Void
        @Environment(\.swiftForgeTheme) private var theme
        var body: some View {
            onRead(theme)
            return Color.clear.frame(width: 1, height: 1)
        }
    }

    private func theme(_ base: SwiftForgeTheme, boldText: Bool) -> SwiftForgeTheme? {
        var read: SwiftForgeTheme?
        _ = RenderedView(
            WeightProbe { read = $0 }
                .swiftForgeTheme(base)
                .environment(\.legibilityWeight, boldText ? .bold : .regular)
        )
        return read
    }

    @Test("Custom font families move one weight heavier with Bold Text")
    func customFamily() {
        let bold = theme(Self.custom, boldText: true)
        #expect(bold?.typography.body.weight == .semibold)
        #expect(bold?.typography.headline.weight == .bold)
        #expect(bold?.typography.largeTitle.weight == .heavy)
        #expect(theme(Self.custom, boldText: false)?.typography.body.weight == .regular)
    }

    @Test("System fonts are left to the system, which already applies Bold Text", arguments: SwiftForgeTheme.builtIn)
    func systemFamily(base: SwiftForgeTheme) {
        #expect(theme(base, boldText: true) == base)
    }
}

@Suite("Bold Text and leading")
struct BoldTextLeadingTests {

    @Test("System roles with non-standard leading move one weight heavier with Bold Text")
    func leading() {
        var typography = SwiftForgeTypography.standard
        typography.body.leading = .loose
        let adjusted = typography.adjustedForBoldText()
        #expect(adjusted.body.weight == .semibold)
        #expect(adjusted.headline == typography.headline)
    }

    @Test("Standard leading isn't applied, so SwiftUI's own Bold Text still works")
    func standardLeadingOmitted() {
        let style = SwiftForgeTextStyle(.body)
        #expect(SwiftForgeFontFamily.system.font(for: style) == Font.system(.body, design: .default, weight: .regular))
    }
}
