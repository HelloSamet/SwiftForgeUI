//
//  SwiftForgeTheme.swift
//  SwiftForgeUI
//

import SwiftUI
import os

/// The complete set of design tokens SwiftForgeUI components render with.
///
/// Components read the theme from the SwiftUI environment, so you restyle
/// every component at once by applying a theme near the root of your app:
///
/// ```swift
/// @main
/// struct MyApp: App {
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .swiftForgeTheme(.midnight)
///         }
///     }
/// }
/// ```
///
/// Views without an explicit theme use ``forge``. Create your own theme from
/// a built-in one by changing only what makes it yours:
///
/// ```swift
/// extension SwiftForgeTheme {
///     static let acme = SwiftForgeTheme(id: "acme", displayName: "Acme", basedOn: .forge) { theme in
///         theme.colors.accent = .derived(from: SwiftForgeColor(light: 0x5B3CC4, dark: 0x7B61E0))
///         theme.components.button.cornerRadius = SwiftForgeRadius.capsule
///     }
/// }
/// ```
///
/// Tokens come in three layers. *Semantic* tokens — ``colors``,
/// ``typography``, ``spacing``, and the other categories — name a role, such
/// as the primary text color. *Component* tokens in ``components`` override
/// a role for one component. The raw values behind the built-in themes are
/// the *primitive* layer, which themes refer to by name.
///
/// A theme is a value: copying one is as cheap as copying a reference, and
/// comparing a theme with an unchanged copy of itself doesn't compare tokens.
public struct SwiftForgeTheme: Sendable, Hashable, Identifiable {

    struct Tokens: Sendable, Hashable {
        var id: String
        var displayName: String
        var colors: SwiftForgeColors
        var typography: SwiftForgeTypography
        var spacing: SwiftForgeSpacing
        var radius: SwiftForgeRadius
        var sizes: SwiftForgeSizes
        var borders: SwiftForgeBorders
        var elevation: SwiftForgeElevation
        var opacity: SwiftForgeOpacity
        var motion: SwiftForgeMotion
        var haptics: SwiftForgeHaptics
        var components: SwiftForgeComponentTokens
    }

    /// Immutable shared storage. Themes are read on every component update
    /// and rarely changed, so mutations allocate new storage instead of
    /// copying several kilobytes of tokens on every read.
    final class Storage: Sendable {
        let tokens: Tokens
        init(_ tokens: Tokens) { self.tokens = tokens }
    }

    private var storage: Storage

    private subscript<Value>(_ keyPath: WritableKeyPath<Tokens, Value>) -> Value {
        get { storage.tokens[keyPath: keyPath] }
        set {
            var tokens = storage.tokens
            tokens[keyPath: keyPath] = newValue
            storage = Storage(tokens)
        }
    }

    /// A stable identifier, such as `"forge"`. Use it to persist the person's
    /// choice; it never changes between releases.
    public var id: String {
        get { self[\.id] }
        set { self[\.id] = newValue }
    }
    /// The name shown in theme pickers and diagnostics.
    public var displayName: String {
        get { self[\.displayName] }
        set { self[\.displayName] = newValue }
    }
    /// Semantic colors.
    public var colors: SwiftForgeColors {
        get { self[\.colors] }
        set { self[\.colors] = newValue }
    }
    /// The type scale.
    public var typography: SwiftForgeTypography {
        get { self[\.typography] }
        set { self[\.typography] = newValue }
    }
    /// The spacing scale.
    public var spacing: SwiftForgeSpacing {
        get { self[\.spacing] }
        set { self[\.spacing] = newValue }
    }
    /// The corner-radius scale and corner style.
    public var radius: SwiftForgeRadius {
        get { self[\.radius] }
        set { self[\.radius] = newValue }
    }
    /// Component dimensions.
    public var sizes: SwiftForgeSizes {
        get { self[\.sizes] }
        set { self[\.sizes] = newValue }
    }
    /// Line widths.
    public var borders: SwiftForgeBorders {
        get { self[\.borders] }
        set { self[\.borders] = newValue }
    }
    /// Shadows for each elevation level.
    public var elevation: SwiftForgeElevation {
        get { self[\.elevation] }
        set { self[\.elevation] = newValue }
    }
    /// Opacities for interaction states.
    public var opacity: SwiftForgeOpacity {
        get { self[\.opacity] }
        set { self[\.opacity] = newValue }
    }
    /// Animation tokens.
    public var motion: SwiftForgeMotion {
        get { self[\.motion] }
        set { self[\.motion] = newValue }
    }
    /// Haptic feedback configuration.
    public var haptics: SwiftForgeHaptics {
        get { self[\.haptics] }
        set { self[\.haptics] = newValue }
    }
    /// Component-specific overrides of the semantic tokens.
    public var components: SwiftForgeComponentTokens {
        get { self[\.components] }
        set { self[\.components] = newValue }
    }

    /// Creates a theme from its token categories.
    ///
    /// To change a few tokens of an existing theme, use
    /// ``init(id:displayName:basedOn:customize:)`` instead.
    ///
    /// - Parameters:
    ///   - id: A stable identifier, used to persist the theme choice.
    ///   - displayName: The name shown in theme pickers.
    ///   - colors: Semantic colors.
    ///   - typography: The type scale. Defaults to ``SwiftForgeTypography/standard``.
    ///   - spacing: The spacing scale. Defaults to ``SwiftForgeSpacing/standard``.
    ///   - radius: The corner-radius scale. Defaults to ``SwiftForgeRadius/standard``.
    ///   - sizes: Component dimensions. Defaults to ``SwiftForgeSizes/standard``.
    ///   - borders: Line widths. Defaults to ``SwiftForgeBorders/standard``.
    ///   - elevation: Shadows for each elevation level.
    ///   - opacity: Opacities for interaction states. Defaults to ``SwiftForgeOpacity/standard``.
    ///   - motion: Animation tokens. Defaults to ``SwiftForgeMotion/standard-type.property``.
    ///   - haptics: Haptic feedback. Defaults to ``SwiftForgeHaptics/standard``.
    ///   - components: Component-specific overrides. Defaults to none.
    public init(
        id: String,
        displayName: String,
        colors: SwiftForgeColors,
        typography: SwiftForgeTypography = .standard,
        spacing: SwiftForgeSpacing = .standard,
        radius: SwiftForgeRadius = .standard,
        sizes: SwiftForgeSizes = .standard,
        borders: SwiftForgeBorders = .standard,
        elevation: SwiftForgeElevation,
        opacity: SwiftForgeOpacity = .standard,
        motion: SwiftForgeMotion = .standard,
        haptics: SwiftForgeHaptics = .standard,
        components: SwiftForgeComponentTokens = SwiftForgeComponentTokens()
    ) {
        storage = Storage(
            Tokens(
                id: id,
                displayName: displayName,
                colors: colors,
                typography: typography,
                spacing: spacing,
                radius: radius,
                sizes: sizes,
                borders: borders,
                elevation: elevation,
                opacity: opacity,
                motion: motion,
                haptics: haptics,
                components: components
            )
        )
    }

    /// Creates a theme from another one, changing only what you need.
    ///
    /// ```swift
    /// let acme = SwiftForgeTheme(id: "acme", displayName: "Acme", basedOn: .forge) { theme in
    ///     theme.colors.accent = .derived(from: SwiftForgeColor(light: 0x5B3CC4, dark: 0x7B61E0))
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - id: A stable identifier, used to persist the theme choice.
    ///   - displayName: The name shown in theme pickers.
    ///   - base: The theme to start from.
    ///   - customize: Changes to make to the copy.
    public init(
        id: String,
        displayName: String,
        basedOn base: SwiftForgeTheme,
        customize: (inout SwiftForgeTheme) -> Void = { _ in }
    ) {
        var tokens = base.storage.tokens
        tokens.id = id
        tokens.displayName = displayName
        storage = Storage(tokens)
        customize(&self)
    }

    /// Returns a Boolean value indicating whether two themes have the same tokens.
    public static func == (lhs: SwiftForgeTheme, rhs: SwiftForgeTheme) -> Bool {
        lhs.storage === rhs.storage || lhs.storage.tokens == rhs.storage.tokens
    }

    /// Hashes the theme's tokens.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storage.tokens)
    }

    /// This theme as Bold Text should render it: unchanged where SwiftUI applies
    /// Bold Text itself, one weight heavier where it doesn't (custom font
    /// families and system roles with non-standard leading).
    func adjustedForBoldText() -> SwiftForgeTheme {
        let adjusted = typography.adjustedForBoldText()
        guard adjusted != typography else { return self }
        var copy = self
        copy.typography = adjusted
        return copy
    }

    /// Whether two values share storage, for tests of the copy-on-write behavior.
    func sharesStorage(with other: SwiftForgeTheme) -> Bool {
        storage === other.storage
    }
}

extension EnvironmentValues {

    /// The theme SwiftForgeUI components render with. Defaults to
    /// ``SwiftForgeTheme/forge``.
    @Entry public var swiftForgeTheme: SwiftForgeTheme = .forge
}

private struct SwiftForgeThemeModifier: ViewModifier {

    let theme: SwiftForgeTheme

    @Environment(\.legibilityWeight) private var legibilityWeight

    func body(content: Content) -> some View {
        content
            .environment(\.swiftForgeTheme, legibilityWeight == .bold ? theme.adjustedForBoldText() : theme)
            .tint(theme.colors.accent.solid)
            #if DEBUG
        .onAppear { SwiftForgeThemeDiagnostics.auditOnce(theme) }
            #endif
    }
}

extension View {

    /// Applies a theme to this view and every SwiftForgeUI component beneath it.
    ///
    /// The theme's accent also becomes the view's `tint`, so native controls
    /// such as `Toggle`, `Slider`, and `ProgressView` match. Themes can be
    /// nested; the innermost one wins, so you can theme a single screen or
    /// card differently from the rest of the app.
    ///
    /// Text follows Bold Text in every theme: SwiftUI makes system fonts
    /// heavier, and the theme moves custom font families one weight heavier.
    ///
    /// In debug builds, a custom theme that fails ``SwiftForgeContrastAudit``
    /// logs its violations once.
    public func swiftForgeTheme(_ theme: SwiftForgeTheme) -> some View {
        modifier(SwiftForgeThemeModifier(theme: theme))
    }
}

#if DEBUG
@MainActor
enum SwiftForgeThemeDiagnostics {

    private static var auditedThemes = Set(SwiftForgeTheme.builtIn)
    private static let logger = Logger(subsystem: "SwiftForgeUI", category: "Theme")

    static func auditOnce(_ theme: SwiftForgeTheme) {
        guard auditedThemes.insert(theme).inserted else { return }
        let violations = SwiftForgeContrastAudit.run(on: theme)
        guard !violations.isEmpty else { return }
        let summary = violations.prefix(10).map(\.description).joined(separator: "\n")
        logger.warning(
            "Theme '\(theme.displayName, privacy: .public)' has \(violations.count) contrast violation(s):\n\(summary, privacy: .public)"
        )
    }
}
#endif
