//
//  ThemingPages.swift
//  SwiftForgeShowcase
//
//  Runtime theme switching, subtree theming, and every component state.
//

import SwiftForgeUI
import SwiftUI

/// Every theme the manager offers, each previewed by the same view themed for
/// its own subtree. Choosing one restyles the whole app and is remembered.
struct ThemeGalleryPage: View {

    @Environment(SwiftForgeThemeManager.self) private var manager
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        CatalogPageContainer {
            Text(
                "Each preview applies its theme to its own subtree with .swiftForgeTheme(_:). Choose one to restyle the whole app; the choice is remembered between launches."
            )
            .swiftForgeTextStyle(\.subheadline, color: \.textSecondary)

            ForEach(manager.themes) { candidate in
                ThemeOption(theme: candidate, isSelected: candidate.id == manager.theme.id) {
                    manager.select(candidate)
                }
            }

            Button("Reset to Default Theme") { manager.reset() }
                .buttonStyle(.swiftForge(.plain))
        }
    }
}

/// A theme's name, a button that applies it, and a live sample of it.
private struct ThemeOption: View {

    let theme: SwiftForgeTheme
    let isSelected: Bool
    let select: () -> Void
    @Environment(\.swiftForgeTheme) private var appTheme

    var body: some View {
        SwiftForgeCard(style: .outlined) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(theme.displayName)
                        .swiftForgeTextStyle(\.headline)
                        .foregroundStyle(appTheme.colors.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    if isSelected {
                        SwiftForgeBadge("In use", tone: .accent, systemImage: "checkmark", prominence: .prominent)
                    } else {
                        Button("Use", action: select)
                            .buttonStyle(.swiftForge(.tinted))
                            .controlSize(.small)
                            .accessibilityLabel(Text("Use \(theme.displayName)"))
                    }
                }
                .padding(appTheme.spacing.md)

                ThemeSample()
                    .swiftForgeTheme(theme)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .swiftForgeCardPadding(.none)
        .clipShape(appTheme.radius.shape(appTheme.radius.card))
    }
}

/// A compact arrangement that shows a theme's character at a glance.
struct ThemeSample: View {

    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.xs) {
                Button("Continue") {}.buttonStyle(.swiftForge(.filled))
                Button("Later") {}.buttonStyle(.swiftForge(.outlined))
                Spacer(minLength: 0)
                SwiftForgeBadge("New", tone: .info)
            }
            SwiftForgeCard(style: .elevated) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text("Plan renews").swiftForgeTextStyle(\.headline).foregroundStyle(theme.colors.textPrimary)
                    Text("March 4 · $12.00").swiftForgeTextStyle(\.subheadline).foregroundStyle(theme.colors.textSecondary)
                }
            }
            ProgressView(value: 0.6).progressViewStyle(.swiftForgeLinear)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.canvas)
        // A sample may sit inside a card without padding; its own cards keep theirs.
        .swiftForgeCardPadding(.standard)
    }
}

/// The same screen in two themes at once: themes apply to any subtree, and
/// the innermost one wins.
struct ThemeComparisonPage: View {

    @Environment(SwiftForgeThemeManager.self) private var manager
    @State private var leading = SwiftForgeTheme.forge.id
    @State private var trailing = SwiftForgeTheme.neoBrutal.id

    var body: some View {
        CatalogPageContainer {
            HStack {
                themePicker("Left", selection: $leading)
                themePicker("Right", selection: $trailing)
            }
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    panel(leading)
                    panel(trailing)
                }
                VStack(spacing: 12) {
                    panel(leading)
                    panel(trailing)
                }
            }
        }
    }

    private func themePicker(_ title: String, selection: Binding<String>) -> some View {
        Picker(title, selection: selection) {
            ForEach(manager.themes) { Text($0.displayName).tag($0.id) }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity)
    }

    private func panel(_ id: String) -> some View {
        let theme = manager.themes.first { $0.id == id } ?? .forge
        return SignInSample()
            .swiftForgeTheme(theme)
            .frame(minWidth: 300)
    }
}

/// A compact sign-in form.
private struct SignInSample: View {

    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.component) {
            Text("Welcome back").swiftForgeTextStyle(\.title2).foregroundStyle(theme.colors.textPrimary)
            SwiftForgeTextField("Email", text: .constant("sam@example.com"))
            SwiftForgeSecureField("Password", text: .constant("hunter22"), state: .error("Use at least 12 characters."))
            Toggle("Remember me", isOn: .constant(true)).toggleStyle(.swiftForge)
            Button("Sign In") {}
                .buttonStyle(.swiftForge(.filled))
                .controlSize(.large)
                .swiftForgeFullWidth()
        }
        .padding(theme.spacing.md)
        .background(theme.colors.canvas, in: theme.radius.shape(theme.radius.card))
        .overlay { theme.radius.shape(theme.radius.card).strokeBorder(theme.colors.borderSubtle) }
    }
}

/// Every interactive component in each state the theme defines.
struct StateMatrixPage: View {

    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        CatalogPageContainer {
            Text("Pressed and focused states are interactive: press a control, or focus it with a keyboard.")
                .swiftForgeTextStyle(\.subheadline, color: \.textSecondary)

            Specimen("Button") {
                FlowRow {
                    StateCell("Default") { Button("Save") {}.buttonStyle(.swiftForge()) }
                    StateCell("Disabled") { Button("Save") {}.buttonStyle(.swiftForge()).disabled(true) }
                    StateCell("Loading") { Button("Save") {}.buttonStyle(.swiftForge()).swiftForgeLoading(true) }
                    StateCell("Destructive") { Button("Delete", role: .destructive) {}.buttonStyle(.swiftForge()) }
                    StateCell("Icon") {
                        Button("Share", systemImage: "square.and.arrow.up") {}.buttonStyle(.swiftForgeIcon(.tinted))
                    }
                }
            }
            Specimen("Toggle") {
                StateCell("On") { Toggle("Notifications", isOn: .constant(true)) }
                StateCell("Off") { Toggle("Notifications", isOn: .constant(false)) }
                StateCell("Disabled") { Toggle("Notifications", isOn: .constant(true)).disabled(true) }
                StateCell("Without color") {
                    Toggle("Notifications", isOn: .constant(true))
                        .swiftForgeAccessibilitySimulation(differentiateWithoutColor: true)
                }
            }
            .toggleStyle(.swiftForge)
            Specimen("Text field") {
                StateCell("Default") { SwiftForgeTextField("Name", text: .constant(""), prompt: Text("Jane Appleseed")) }
                StateCell("Helper") {
                    SwiftForgeTextField("Bio", text: .constant("Designer"), state: .helper("Shown on your profile."))
                }
                StateCell("Success") {
                    SwiftForgeTextField("Username", text: .constant("sam"), state: .success("That username is available."))
                }
                StateCell("Error") {
                    SwiftForgeTextField("Email", text: .constant("sam@"), state: .error("Enter a valid email address."))
                }
                StateCell("Disabled") { SwiftForgeTextField("Account", text: .constant("Read only")).disabled(true) }
            }
            Specimen("Card") {
                StateCell("Static") { SwiftForgeCard { Text("Plan renews March 4.") } }
                StateCell("Tappable") {
                    Button {
                    } label: {
                        Text("Open plan")
                    }.buttonStyle(.swiftForgeCard())
                }
                StateCell("Disabled") {
                    Button {
                    } label: {
                        Text("Open plan")
                    }.buttonStyle(.swiftForgeCard()).disabled(true)
                }
            }
            Specimen("Feedback") {
                FlowRow {
                    ForEach(SwiftForgeTone.allCases, id: \.self) { tone in
                        SwiftForgeBadge(tone.rawValue.capitalized, tone: tone)
                    }
                }
                ProgressView(value: 0.4).progressViewStyle(.swiftForgeLinear)
            }
        }
    }
}

/// A component with the name of its state.
private struct StateCell<Content: View>: View {

    let title: String
    @ViewBuilder let content: Content
    @Environment(\.swiftForgeTheme) private var theme

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Text(title).swiftForgeTextStyle(\.caption1).foregroundStyle(theme.colors.textSecondary)
            content
        }
    }
}
