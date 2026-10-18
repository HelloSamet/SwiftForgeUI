# Introducing Themes

Restyle every SwiftForgeUI component at once — with a built-in theme, your own, or one people choose at runtime.

## Overview

A ``SwiftForgeTheme`` is a value that holds every design decision components make: colors, typography, spacing,
corners, borders, shadows, opacity, motion, haptics, and per-component overrides. Components read the theme from the
SwiftUI environment and never hardcode a visual value, so one modifier changes how an entire app looks:

```swift
ContentView()
    .swiftForgeTheme(.midnight)
```

Views without a theme use ``SwiftForgeTheme/forge``, so existing code keeps working unchanged.

### Built-in themes

Each theme differs in shape, depth, density, and typography — not only in color — and defines light, dark, and both
Increase Contrast appearances.

| Theme | Character |
|---|---|
| ``SwiftForgeTheme/forge`` | The default. Balanced and iOS-native: a blue accent tuned for AA contrast, soft corners, depth from shadows in light mode and lighter surfaces in dark mode. |
| ``SwiftForgeTheme/midnight`` | Dark-first and high-contrast: an ink-navy canvas, neon accents, medium-sharp corners, and an accent glow instead of shadows in dark mode. |
| ``SwiftForgeTheme/aurora`` | Soft and luminous: violet-to-teal gradient buttons, pill-shaped controls, 24-pt cards, glass overlays, SF Rounded, and bouncy motion. |
| ``SwiftForgeTheme/paper`` | Minimal and editorial: ink on warm paper, New York serif headings, hairlines, no shadows, and underlined text fields. |
| ``SwiftForgeTheme/neoBrutal`` | Loud and tactile: square corners, thick outlines, hard offset shadows that controls sink into, and flat saturated colors. |
| ``SwiftForgeTheme/mono`` | A terminal: SF Mono everywhere, one phosphor-green accent, no shadows, and a dense layout that keeps 44-pt hit areas. |
| ``SwiftForgeTheme/ocean`` | Calm and deep: lagoon-teal accents on sea-foam surfaces, pebble-rounded corners, soft sea-tinted shadows, tall controls, lighter headings, and slow motion without bounce. |
| ``SwiftForgeTheme/sunset`` | Warm and expressive: magenta-to-ember gradient buttons, apricot and dusk-plum surfaces, warm glowing shadows, heavy rounded headings, and springy motion. |

Each image shows buttons in light mode and cards in dark mode:

![Forge: blue filled, tinted, and outline buttons with soft corners; dark cards on black.](theme-forge.png)

![Midnight: deep cyan buttons; dark navy cards glowing faintly in cyan.](theme-midnight.png)

![Aurora: pill-shaped buttons with a violet-to-teal gradient; rounded dark violet cards.](theme-aurora.png)

![Paper: square-ish black and outlined buttons on warm paper; flat dark cards with serif titles.](theme-paper.png)

![Neo-Brutal: yellow buttons with thick black outlines and hard shadows; outlined dark cards with yellow shadows.](theme-neo-brutal.png)

![Mono: monospaced green buttons; flat dark cards in a terminal style.](theme-mono.png)

![Ocean: deep teal buttons with generously rounded corners; dark sea-navy cards.](theme-ocean.png)

![Sunset: buttons fading from magenta to orange; dark plum cards with a faint warm glow.](theme-sunset.png)

``SwiftForgeTheme/builtIn`` lists all eight for theme pickers.

### Scope a theme to part of your app

Themes follow SwiftUI's environment, so you can apply one to any subtree — a screen, a card, a preview — and the
innermost theme wins:

```swift
VStack {
    AccountSummary()                       // the app's theme
    PromoCard().swiftForgeTheme(.neoBrutal) // only this card
}
.swiftForgeTheme(.paper)
```

The theme's accent also becomes the view's `tint`, so native controls such as `Slider` match.

### Let people choose a theme

``SwiftForgeThemeManager`` offers a list of themes, remembers the person's choice, and animates changes. Apply it at
the root of your app:

```swift
@main
struct MyApp: App {
    @State private var themes = SwiftForgeThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .swiftForgeTheme(themes)
        }
    }
}
```

Any view beneath reads the manager from the environment:

```swift
struct AppearanceSettings: View {
    @Environment(SwiftForgeThemeManager.self) private var themes

    var body: some View {
        Picker("Theme", selection: Binding(get: { themes.theme.id }, set: { themes.select(id: $0) })) {
            ForEach(themes.themes) { Text($0.displayName).tag($0.id) }
        }
    }
}
```

- The stored choice is read synchronously when the manager is created, so the first frame already shows it — no flash
  of the default theme. An identifier that no longer matches a theme falls back to the default.
- Choices persist in `UserDefaults` by default. Pass an app group with
  ``SwiftForgeUserDefaultsThemeStore/init(key:suiteName:)``, store them elsewhere by conforming to
  ``SwiftForgeThemeStore``, or use ``SwiftForgeInMemoryThemeStore`` in previews and tests.
- Changes interpolate colors, corners, spacing, and shadows with the new theme's standard motion. With Reduce Motion
  on, the theme changes at once.

### How tokens are organized

Tokens come in three layers:

1. **Primitive** values — the raw palette behind the built-in themes. They're internal: themes refer to them by name,
   and your app refers to roles instead.
2. **Semantic** roles in ``SwiftForgeTheme`` — ``SwiftForgeColors/textSecondary``, ``SwiftForgeRadius/card``,
   ``SwiftForgeSpacing/md``, ``SwiftForgeElevation/medium`` — which every component shares, so a role means the same
   thing everywhere.
3. **Component** tokens in ``SwiftForgeTheme/components`` — overrides for one component, such as pill-shaped buttons
   or underlined text fields — that give a theme its character.

Read the theme in your own views to build components that follow it:

```swift
struct PlanRow: View {
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        Text("Pro plan")
            .swiftForgeTextStyle(\.headline)
            .foregroundStyle(theme.colors.textPrimary)
            .padding(theme.spacing.md)
            .background(theme.colors.surface, in: theme.radius.shape(theme.radius.card))
    }
}
```

## Topics

### Next steps

- <doc:CreatingACustomTheme>
- <doc:TokenReference>
- <doc:Accessibility>
