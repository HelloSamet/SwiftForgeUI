# Creating a Custom Theme

Define your brand's theme in a few lines, give it its own character, and prove it stays accessible.

## Overview

You never need to change SwiftForgeUI to add a theme: a theme is a value you create in your app. Start from the
built-in theme closest to what you want and change only what makes it yours.

### Start from a built-in theme

``SwiftForgeTheme/init(id:displayName:basedOn:customize:)`` copies a theme, gives it a new identity, and lets you
change any token:

```swift
import SwiftForgeUI

extension SwiftForgeTheme {
    static let harbor = SwiftForgeTheme(id: "harbor", displayName: "Harbor", basedOn: .forge) { theme in
        theme.colors.accent = .derived(
            from: SwiftForgeColor(light: 0x0B6E6E, dark: 0x3CC6C6),
            on: theme.colors
        )
    }
}
```

Apply it like any other theme: `.swiftForgeTheme(.harbor)`.

- The `id` is persisted when people choose the theme, so keep it stable across releases.
- ``SwiftForgeToneColors/derived(from:on:)`` turns one brand color into a complete tone — the color on it, tinted text,
  and a tinted background — adjusting lightness until each pairing meets WCAG AA against the theme's surfaces, in
  light, dark, and Increase Contrast.

### Choose colors for every appearance

A ``SwiftForgeColor`` holds a value for light mode, dark mode, and both Increase Contrast appearances. Define light
and dark side by side, and stronger variants for Increase Contrast:

```swift
theme.colors.canvas = SwiftForgeColor(light: 0xF3F7F7, dark: 0x061414)
theme.colors.textSecondary = SwiftForgeColor(
    light: 0x4A5C5C, dark: 0xA3B8B8,
    lightHighContrast: 0x2C3A3A, darkHighContrast: 0xD0E0E0
)
```

To use an asset-catalog color, wrap it with ``SwiftForgeColor/init(_:)``; SwiftUI resolves it, and the contrast
audit can check it only in light and dark mode.

### Give the theme its own character

Change more than color. Each category is independent:

```swift
static let harbor = SwiftForgeTheme(id: "harbor", displayName: "Harbor", basedOn: .forge) { theme in
    // Typography: serif headings, scaled with Dynamic Type.
    theme.typography.title1 = theme.typography.title1.designed(.serif)
    theme.typography.headline = theme.typography.headline.designed(.serif)

    // Shape: pill buttons, rounder cards.
    theme.components.button.cornerRadius = SwiftForgeRadius.capsule
    theme.radius.card = 20

    // Depth: a softer, tinted shadow for raised surfaces.
    theme.elevation.medium = SwiftForgeShadow(color: SwiftForgeColor(light: 0x0B6E6E, dark: 0x000000).withOpacity(0.18), radius: 20, y: 8)

    // Density: roomier cards.
    theme.spacing.cardPadding = 20

    // Motion: a gentle bounce.
    theme.motion.standard = SwiftForgeMotionToken(duration: 0.35, bounce: 0.15)
}
```

Component tokens in ``SwiftForgeComponentTokens`` change one component without affecting the others:

| To get | Set |
|---|---|
| Outlined, square, shadow-casting buttons that press into their shadow | `button.borderWidth`, `button.borderColor`, `button.elevation`, `button.pressEffect = .sinkIntoShadow`, `radius.control = 0` |
| A gradient on filled buttons | `colors.accent.solidFill = .linearGradient([start, end])` |
| Glass overlays | `components.surface.fills[.overlay] = .material(.thin, fallback: colors.surfaceRaised)` |
| Underlined or filled text fields | `components.field.style` |
| A square switch | `components.toggle.cornerRadius = 0` |
| Bordered badges | `components.badge.borderWidth` |

Optional component tokens default to `nil`, meaning "derive from the semantic tokens", so changing
``SwiftForgeTheme/radius`` still reshapes every component you haven't overridden. See <doc:TokenReference>.

### Use your own fonts

``SwiftForgeFontFamily/custom(regular:medium:semibold:bold:)`` sets every role in a font you register with your
app. Each role keeps its Dynamic Type text style, so custom fonts scale through `accessibility5`, and with Bold Text on
each role moves to the next heavier face:

```swift
theme.typography.fontFamily = .custom(regular: "Inter-Regular", semibold: "Inter-SemiBold", bold: "Inter-Bold")
```

### Prove it's accessible

``SwiftForgeContrastAudit`` checks every pairing components draw — text on every surface and tinted background,
outlines and focus rings, content on filled controls including every gradient stop, and component border colors — in
all four appearances. Keep it in your tests:

```swift
import SwiftForgeUI
import Testing

@Test func harborMeetsWCAGAA() {
    let violations = SwiftForgeContrastAudit.run(on: .harbor)
    #expect(violations.isEmpty, "\(violations.map(\.description))")
}
```

In debug builds, a custom theme with violations also logs them once when it's first applied. Themes can't make hit
areas smaller than 44 pt: ``SwiftForgeSizes/minimumHitTarget`` never goes below
``SwiftForgeSizes/accessibleHitTarget``.

### Offer it with the built-in themes

Pass your theme to ``SwiftForgeThemeManager`` so people can choose it and the choice is restored:

```swift
@State private var themes = SwiftForgeThemeManager(
    themes: SwiftForgeTheme.builtIn + [.harbor],
    defaultTheme: .harbor
)
```

### Build a theme from scratch

For full control, create a theme from its categories with
``SwiftForgeTheme/init(id:displayName:colors:typography:spacing:radius:sizes:borders:elevation:opacity:motion:haptics:components:)``.
Every category except colors and elevation has a standard default.
