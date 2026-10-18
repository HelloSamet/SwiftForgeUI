//
//  SwiftForgeThemeManager.swift
//  SwiftForgeUI
//

import Observation
import SwiftUI

/// Lets people choose a theme at runtime, remembers the choice, and animates
/// the change.
///
/// Create one manager for your app and apply it at the root:
///
/// ```swift
/// @main
/// struct MyApp: App {
///     @State private var themes = SwiftForgeThemeManager()
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .swiftForgeTheme(themes)
///         }
///     }
/// }
/// ```
///
/// Any view beneath can read the manager from the environment and change
/// the theme:
///
/// ```swift
/// struct AppearanceSettings: View {
///     @Environment(SwiftForgeThemeManager.self) private var themes
///
///     var body: some View {
///         Picker("Theme", selection: Binding(get: { themes.theme.id }, set: { themes.select(id: $0) })) {
///             ForEach(themes.themes) { Text($0.displayName).tag($0.id) }
///         }
///     }
/// }
/// ```
///
/// The manager reads the stored choice synchronously when it's created, so
/// the first frame already shows the chosen theme. If the stored identifier
/// no longer matches a theme in ``themes``, it falls back to the default.
@MainActor
@Observable
public final class SwiftForgeThemeManager {

    /// The themes people can choose from, in the order to offer them.
    public let themes: [SwiftForgeTheme]

    /// The theme used when no choice is stored, or the stored one is unknown.
    public let defaultTheme: SwiftForgeTheme

    /// The current theme.
    public private(set) var theme: SwiftForgeTheme

    @ObservationIgnored private let store: (any SwiftForgeThemeStore)?

    /// Creates a manager and restores the stored choice.
    ///
    /// - Parameters:
    ///   - themes: The themes to offer. Defaults to ``SwiftForgeTheme/builtIn``.
    ///   - defaultTheme: The theme to use without a stored choice. Defaults to
    ///     the first of `themes`, or ``SwiftForgeTheme/forge`` if it's empty.
    ///   - store: Where to persist the choice, or `nil` not to persist it.
    ///     Defaults to `UserDefaults`.
    public init(
        themes: [SwiftForgeTheme] = SwiftForgeTheme.builtIn,
        defaultTheme: SwiftForgeTheme? = nil,
        store: (any SwiftForgeThemeStore)? = SwiftForgeUserDefaultsThemeStore()
    ) {
        let defaultTheme = defaultTheme ?? themes.first ?? .forge
        self.themes = themes
        self.defaultTheme = defaultTheme
        self.store = store
        let storedID = store?.loadThemeID()
        theme = themes.first { $0.id == storedID } ?? defaultTheme
    }

    /// Switches to `theme` and stores the choice.
    ///
    /// The theme doesn't have to be in ``themes``, but only themes in
    /// ``themes`` (or the default) are restored on the next launch.
    public func select(_ theme: SwiftForgeTheme) {
        self.theme = theme
        store?.saveThemeID(theme.id)
    }

    /// Switches to the theme in ``themes`` with an identifier, and stores the choice.
    ///
    /// - Returns: `false`, leaving the theme unchanged, if no theme has the identifier.
    @discardableResult
    public func select(id: String) -> Bool {
        guard let theme = themes.first(where: { $0.id == id }) else { return false }
        select(theme)
        return true
    }

    /// Returns to the default theme and forgets the stored choice.
    public func reset() {
        theme = defaultTheme
        store?.saveThemeID(nil)
    }
}

private struct SwiftForgeThemeManagerModifier: ViewModifier {

    let manager: SwiftForgeThemeManager

    @SwiftForgeAccessibilityContext private var accessibility

    func body(content: Content) -> some View {
        let theme = manager.theme
        content
            .swiftForgeTheme(theme)
            .environment(manager)
            // Colors, corners, spacing, and shadows interpolate to the new
            // theme with its standard motion. With Reduce Motion on, the
            // theme changes at once: a layout that reshapes itself is motion.
            .animation(accessibility.reduceMotion ? nil : theme.motion.standard.animation(reduceMotion: false), value: theme.id)
    }
}

extension View {

    /// Applies the manager's current theme to this view and every SwiftForgeUI
    /// component beneath it, animating changes, and makes the manager
    /// available to descendants through `@Environment(SwiftForgeThemeManager.self)`.
    ///
    /// Changing themes interpolates colors, corners, spacing, and shadows with
    /// the new theme's ``SwiftForgeMotion/standard-swift.property`` motion.
    /// With Reduce Motion on, the theme changes without animation.
    public func swiftForgeTheme(_ manager: SwiftForgeThemeManager) -> some View {
        modifier(SwiftForgeThemeManagerModifier(manager: manager))
    }
}
