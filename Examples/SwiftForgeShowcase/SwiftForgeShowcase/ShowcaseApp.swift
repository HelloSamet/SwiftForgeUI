//
//  ShowcaseApp.swift
//  SwiftForgeShowcase
//
//  A live catalog of every SwiftForgeUI component, with controls for theme,
//  appearance, Dynamic Type, layout direction, language, and accessibility
//  settings. UI tests launch it with `-uiTestFixture <name>` to open a
//  deterministic test screen instead.
//

import SwiftForgeUI
import SwiftUI

@main
struct ShowcaseApp: App {

    @State private var settings = ShowcaseSettings()
    /// Shows the catalog's toasts and dialogs; fixtures install their own.
    @State private var presenter = SwiftForgePresenter()

    var body: some Scene {
        WindowGroup {
            Group {
                if let fixture = UITestFixture.fromLaunchArguments {
                    fixture.view
                } else {
                    CatalogView()
                        .swiftForgePresentationHost(presenter)
                }
            }
            .showcaseSettings(settings)
            .environment(settings)
        }
    }
}

/// Preview controls applied to the whole catalog.
@MainActor
@Observable
final class ShowcaseSettings {

    enum Appearance: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: Self { self }
        var colorScheme: ColorScheme? {
            switch self {
            case .system: nil
            case .light: .light
            case .dark: .dark
            }
        }
    }

    enum Language: String, CaseIterable, Identifiable {
        case english = "en", turkish = "tr"
        var id: Self { self }
        var name: String { self == .english ? "English" : "Türkçe" }
    }

    /// The theme, chosen at runtime and remembered between launches. UI tests
    /// choose it with `-uiTestTheme <id>` and never persist it.
    let themes: SwiftForgeThemeManager =
        UITestFixture.fromLaunchArguments == nil
        ? SwiftForgeThemeManager()
        : SwiftForgeThemeManager(store: SwiftForgeInMemoryThemeStore(themeID: launchArgument("-uiTestTheme")))
    // UI tests choose the appearance with `-uiTestAppearance light|dark`.
    var appearance = ShowcaseSettings.launchArgument("-uiTestAppearance").flatMap(Appearance.init(rawValue:)) ?? .system
    /// `nil` follows the system setting.
    var dynamicTypeSize: DynamicTypeSize?
    var isRightToLeft = false
    var language = Language.english
    var increasedContrast = false
    var reduceMotion = false
    var reduceTransparency = false

    nonisolated private static func launchArgument(_ name: String) -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: name), arguments.indices.contains(index + 1) else { return nil }
        return arguments[index + 1]
    }
}

private struct ShowcaseSettingsModifier: ViewModifier {

    let settings: ShowcaseSettings

    func body(content: Content) -> some View {
        content
            .swiftForgeTheme(settings.themes)
            .swiftForgeAccessibilitySimulation(
                increasedContrast: settings.increasedContrast,
                reduceMotion: settings.reduceMotion,
                reduceTransparency: settings.reduceTransparency
            )
            .transformEnvironment(\.dynamicTypeSize) { size in
                if let override = settings.dynamicTypeSize { size = override }
            }
            .environment(\.layoutDirection, settings.isRightToLeft ? .rightToLeft : .leftToRight)
            .environment(\.locale, Locale(identifier: settings.language.rawValue))
            .preferredColorScheme(settings.appearance.colorScheme)
    }
}

extension View {
    func showcaseSettings(_ settings: ShowcaseSettings) -> some View {
        modifier(ShowcaseSettingsModifier(settings: settings))
    }
}
