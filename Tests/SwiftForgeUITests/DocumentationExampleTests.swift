import SwiftUI
import Testing

@testable import SwiftForgeUI

/// The code samples in the DocC articles, verbatim, so documentation can't
/// drift from the API or recommend an inaccessible theme.
extension SwiftForgeTheme {

    // "Creating a Custom Theme"
    static let harbor = SwiftForgeTheme(id: "harbor", displayName: "Harbor", basedOn: .forge) { theme in
        theme.colors.accent = .derived(
            from: SwiftForgeColor(light: 0x0B6E6E, dark: 0x3CC6C6),
            on: theme.colors
        )

        // Typography: serif headings, scaled with Dynamic Type.
        theme.typography.title1 = theme.typography.title1.designed(.serif)
        theme.typography.headline = theme.typography.headline.designed(.serif)

        // Shape: pill buttons, rounder cards.
        theme.components.button.cornerRadius = SwiftForgeRadius.capsule
        theme.radius.card = 20

        // Depth: a softer, tinted shadow for raised surfaces.
        theme.elevation.medium = SwiftForgeShadow(
            color: SwiftForgeColor(light: 0x0B6E6E, dark: 0x000000).withOpacity(0.18), radius: 20, y: 8)

        // Density: roomier cards.
        theme.spacing.cardPadding = 20

        // Motion: a gentle bounce.
        theme.motion.standard = SwiftForgeMotionToken(duration: 0.35, bounce: 0.15)
    }
}

/// "Introducing Themes"
private struct PlanRow: View {
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        Text("Pro plan")
            .swiftForgeTextStyle(\.headline)
            .foregroundStyle(theme.colors.textPrimary)
            .padding(theme.spacing.md)
            .background(theme.colors.surface, in: theme.radius.shape(theme.radius.card))
    }
}

@MainActor
@Suite("Documentation examples")
struct DocumentationExampleTests {

    @Test("The custom theme example meets WCAG AA")
    func harborMeetsWCAGAA() {
        let violations = SwiftForgeContrastAudit.run(on: .harbor)
        #expect(violations.isEmpty, "\(violations.map(\.description))")
    }

    @Test("The custom theme example can be offered, chosen, and restored")
    func harborWithManager() {
        let store = SwiftForgeInMemoryThemeStore()
        let themes = SwiftForgeThemeManager(themes: SwiftForgeTheme.builtIn + [.harbor], defaultTheme: .harbor, store: store)
        #expect(themes.theme == .harbor)
        themes.select(id: "paper")
        #expect(
            SwiftForgeThemeManager(themes: SwiftForgeTheme.builtIn + [.harbor], defaultTheme: .harbor, store: store).theme
                == .paper)
    }

    @Test("The themed row example renders with the theme's surface")
    func planRow() {
        let rendered = RenderedView(PlanRow().swiftForgeTheme(.harbor))
        #expect(rendered.size.height > 0)
    }
}

// MARK: - Symbol documentation samples

/// ``SwiftForgeFieldStyle``
private struct FloatingCardFieldStyle: SwiftForgeFieldStyle {
    @Environment(\.swiftForgeTheme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            configuration.label
                .swiftForgeTextStyle(\.caption1)
                .foregroundStyle(configuration.isFocused ? theme.colors.accent.text : theme.colors.textSecondary)
            configuration.content
            if let message = configuration.message {
                message
            }
        }
        .padding(theme.spacing.sm)
        .swiftForgeSurface(.raised)
    }
}

/// ``SwiftForgeFieldContainer``
private struct AmountField: View {
    @Binding var amount: Decimal
    @FocusState private var isFocused: Bool

    var body: some View {
        SwiftForgeFieldContainer("Amount", isFocused: isFocused) {
            TextField("Amount", value: $amount, format: .currency(code: "EUR"))
                .keyboardType(.decimalPad)
                .focused($isFocused)
        } leading: {
            Image(systemName: "eurosign")
        }
    }
}

/// ``SwiftUICore/View/swiftForgeFocusRing(_:cornerRadius:)``
private struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        PillButton(configuration: configuration)
    }
}

private struct PillButton: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isFocused) private var isFocused
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        configuration.label
            .padding(theme.spacing.sm)
            .background(theme.colors.accent.subtle, in: .capsule)
            .swiftForgeFocusRing(isFocused, cornerRadius: SwiftForgeRadius.capsule)
    }
}

@MainActor
@Suite("Symbol documentation samples")
struct SymbolDocumentationSampleTests {

    @Test("The field style, field container, and focus ring samples build and render")
    func samplesRender() {
        let samples = VStack {
            AmountField(amount: .constant(12)).swiftForgeFieldStyle(FloatingCardFieldStyle())
            Button("Pill") {}.buttonStyle(PillButtonStyle())
            SwiftForgeIcon("bell.badge")
            Button("Continue", systemImage: "arrow.forward") {}
                .buttonStyle(.swiftForge(.filled))
                .swiftForgeIconPlacement(.trailing)
        }
        .swiftForgeDensity(.compact)
        #expect(RenderedView(samples, width: 300).size.height > 0)
    }
}
