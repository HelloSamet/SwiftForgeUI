# Architecture

How SwiftForgeUI is put together and why. For using the library, read the DocC documentation; this page is for
contributors and for anyone evaluating the design.

## Goals

- **Native first.** Style SwiftUI's own controls instead of replacing them, so apps keep system behavior —
  accessibility, keyboard, iPad adaptation, and future platform changes — for free.
- **Themes with character.** A theme changes shape, depth, density, typography, and motion, not only color.
- **Accessible by construction.** Every theme meets WCAG AA in every appearance, and tests prove it.
- **Small and dependency-free.** One module, pure SwiftUI, no networking, analytics, or persistence beyond the theme
  choice.

## Package layout

One library product and one target, `SwiftForgeUI`, organized by folder
([ADR-0005](#adr-0005-one-module-and-a-separate-showcase-project)):

```
Sources/SwiftForgeUI/
  Tokens/Primitives/   Raw palettes (internal)
  Tokens/              Semantic and component tokens: colors, typography, spacing, radius, sizes, …
  Theming/             SwiftForgeTheme, the theme manager and store, the contrast audit, accessibility context
  Themes/              The eight built-in themes
  Core/                Shared building blocks: surfaces, focus ring, press feedback, field container, presentation
  Components/          Actions, Inputs, Display, Feedback, Navigation
  Internal/            Color math, localized strings, helpers
  Resources/           Localizable.xcstrings (English, Turkish)
  SwiftForgeUI.docc/   DocC catalog
Tests/SwiftForgeUITests/          Unit tests (Swift Testing)
Examples/SwiftForgeShowcase/      Showcase app and the snapshot, UI, and accessibility-audit tests
scripts/                          Design-token lint, snapshot checkout, theme color design
```

Dependencies point one way: tokens → theming → themes → core → components. `scripts/lint-design-tokens.sh` rejects
literal colors, spacing, radii, and animations in component code, so components can only read the theme.

## Theme model

- **Three token layers** ([ADR-0011](#adr-0011-theme-model)). *Primitive* palettes are internal. *Semantic* tokens
  (`theme.colors.textPrimary`, `theme.spacing.md`, …) name a role. *Component* tokens (`theme.components.button`)
  override a role for one component; an optional component token left `nil` follows its semantic token.
- **A value in the environment** ([ADR-0004](#adr-0004-theme-injection)). `SwiftForgeTheme` is a `Sendable`,
  `Hashable` value stored with `@Entry`. Its tokens sit in one immutable shared box, so copying a theme copies a
  reference and comparing a theme with an unchanged copy doesn't compare tokens.
- **Colors** ([ADR-0003](#adr-0003-color-tokens)) are explicit sRGB values for light, dark, and both Increase
  Contrast appearances, never system dynamic colors, so contrast can be computed in unit tests.
- **Runtime switching** ([ADR-0013](#adr-0013-runtime-theme-switching)). `SwiftForgeThemeManager` holds the choice,
  not the tokens: components still read the theme value. The choice is restored synchronously before the first frame.

## Component API

In order of preference ([ADR-0002](#adr-0002-style-based-api), [ADR-0015](#adr-0015-common-concepts-and-extensibility)):

1. **A SwiftUI style** where SwiftUI has a styling hook: `ButtonStyle`, `ToggleStyle`, `ProgressViewStyle`,
   `GroupBoxStyle`, `LabeledContentStyle`, `DisclosureGroupStyle`. Size comes from `controlSize`, destructive styling
   from `role`, and enablement from `disabled(_:)`.
2. **A modifier carrying extra behavior** through the environment, such as `.swiftForgeLoading(_:)`.
3. **A view** only where SwiftUI offers no hook, such as `SwiftForgeTextField`. These views still wrap native controls.

Common concepts have one spelling everywhere: size is `controlSize`, emphasis is a nested `Variant`, meaning is
`SwiftForgeTone`, validation is `SwiftForgeFieldState`, values are `Binding`s. Four components that SwiftUI can't
style get their own style protocols — `SwiftForgeFieldStyle`, `SwiftForgeChipStyle`,
`SwiftForgeSegmentedControlStyle`, and `SwiftForgeTabBarStyle` — whose configurations type-erase their parts the way
SwiftUI's own configurations do.

## Accessibility

Verified in two layers ([ADR-0012](#adr-0012-built-in-themes-and-two-layer-accessibility-checks)):

1. **Static:** `SwiftForgeContrastAudit` checks every token pair in every theme and appearance in unit tests.
2. **Runtime:** Apple's `performAccessibilityAudit()` runs on fixture screens in every theme, in light and dark, and
   UI tests check VoiceOver labels, values, and traits. Findings are checked against screenshot pixels before being
   accepted or dismissed as false positives.

System accessibility settings that SwiftUI exposes read-only (Increase Contrast, Reduce Motion, Reduce
Transparency, Differentiate Without Color) are read through `SwiftForgeAccessibilityContext`, which previews and
tests can override with `.swiftForgeAccessibilitySimulation(…)`.

## Testing

| Layer | Where | Checks |
|---|---|---|
| Unit | `Tests/SwiftForgeUITests` | Tokens, theme resolution, contrast, state mapping, localization, rendering contracts |
| Snapshot | `Examples/SwiftForgeShowcase/SnapshotTests` | Every component in every theme × light/dark, plus AX5 Dynamic Type, right-to-left, Bold Text, and Increase Contrast |
| UI and audit | `Examples/SwiftForgeShowcase/UITests` | Interaction, VoiceOver semantics, `performAccessibilityAudit()` |
| Performance | `ScrollPerformanceTests` (on demand) | Scrolling hitches against a baseline built from native controls |

Snapshots are dependency-free and hosted in the Showcase app, because `ImageRenderer` can't draw UIKit-backed
controls. They're compared on iOS 18 only, in English, on a fixed canvas. The reference images live in the separate
`SwiftForgeUI-Snapshots` repository, pinned by `Examples/SwiftForgeShowcase/snapshots.revision`, so they never reach
apps that depend on the package.

## Decision log

Summaries of the architecture decision records. The full records, with spikes and alternatives, are kept with the
maintainers' planning documents.

### ADR-0001: Naming

Every public type starts with `SwiftForge`; modifiers, style statics, and environment keys start with `swiftForge`.
Unprefixed names such as `PrimaryButton` collide with app types and hide where a symbol comes from.

### ADR-0002: Style-based API

Prefer SwiftUI style protocols, then behavior modifiers, then custom views — so `Menu`, `NavigationLink`, and
`ShareLink` get the same look, and variants don't multiply into types.

### ADR-0003: Color tokens

`SwiftForgeColor` holds explicit light, dark, and Increase Contrast values and is a `ShapeStyle`. System dynamic
colors were rejected: several fail AA with white text, and their values can't be checked in a unit test.

### ADR-0004: Theme injection

The theme is one value in the environment, not an observable object: value semantics, `Sendable`, and no shared
mutable state in previews. Accessibility settings go through `SwiftForgeAccessibilityContext` so they can be simulated.

### ADR-0005: One module and a separate Showcase project

A single target, organized by folders, instead of separate Core/Theme/Components modules: one import for apps, no
cross-module environment keys, and the dependency direction is enforced by lint instead. The Showcase is an Xcode
project that depends on the local package and hosts the snapshot and UI tests.

### ADR-0006: Testing strategy

Dependency-free snapshot tests hosted in an app, contrast audits as unit tests, and Apple's accessibility audit in UI
tests. SwiftUI builds its accessibility tree only while assistive technology is attached, so accessibility checks run
in XCUITest rather than hosted unit tests.

### ADR-0007: Toolchain, lint, and CI

Swift tools 6.0 (Xcode 16) in the Swift 6 language mode with complete strict concurrency; iOS 17 and visionOS 1.
Newer OS APIs only behind availability checks. `swift format` and a design-token lint, not SwiftLint: one formatter,
no extra tool to install. CI tests the oldest supported Xcode and the newest.

### ADR-0008: Localization

Library strings live in the package's String Catalog with `swiftforge.`-prefixed keys and follow the environment's
locale, not only the device language. English and Turkish ship; other languages are welcome.

### ADR-0009: Performance

Components read only the environment keys they need, never `@Environment(\.self)`; no `GeometryReader` in component
bodies; animations scoped with `animation(_:value:)`; continuous animations driven by `TimelineView`; `AnyView` only
where a style configuration must type-erase.

### ADR-0010: Versioning

Semantic Versioning. Public API is every `public` symbol plus documented visual and accessibility guarantees, such as
44 pt hit areas. Before 1.0, minor versions may break, with a migration path in the changelog; from 1.0, only major
versions break, after at least one minor version of deprecation. Token value changes are not breaking but are listed
under **Visual** in the changelog.

Swift packages can't declare an enum non-exhaustive, so a new case breaks every exhaustive `switch` over it. Enums
whose values SwiftForgeUI hands to app code — in style configurations, environment values, theme tokens, and audit
results (`SwiftForgeFieldState`, `SwiftForgeTone`, `SwiftForgeDensity`, `SwiftForgeIconPlacement`,
`SwiftForgeCornerStyle`, `SwiftForgeElevationLevel`, `SwiftForgePressEffect`, `SwiftForgeFieldTokens.Style`, and
`SwiftForgeContrastAudit.Appearance`) gain cases only in major versions. Enums apps only pass in as options may gain
cases in minor versions. Each enum's documentation says which kind it is.

### ADR-0011: Theme model

Themes have a stable `id` and a `displayName`; three token layers; `SwiftForgeShape` (radius clamped to half the
short side, so a capsule radius animates); `SwiftForgeFill` (color, gradient, or material with an opaque fallback for
Reduce Transparency); `SwiftForgePressEffect`; a 44 pt floor on hit areas; shared immutable token storage.

### ADR-0012: Built-in themes and two-layer accessibility checks

Theme colors are designed in `scripts/theme-design` on ramps of constant perceptual lightness (OKLab), so a step that
works for one hue works for every hue, and are checked with the same WCAG math as the Swift audit. Generated tables are
in [docs/design/themes](design/themes). The runtime audit caught problems the static audit can't see, such as
progress rings drawn in a fill color.

### ADR-0013: Runtime theme switching

`SwiftForgeThemeManager` is a `@MainActor @Observable` class holding the choice; persistence goes through the
`SwiftForgeThemeStore` protocol (`UserDefaults` by default). Colors, corners, spacing, and shadows interpolate between
themes; with Reduce Motion, the change is instant.

### ADR-0014: Catalog scope

Alert dialog, bottom sheet, tab bar, and navigation header are in scope, each built without rewriting what the
system does well: the bottom sheet wraps the native sheet, the navigation header hands off to the navigation bar's
title, and the documentation says when the native component is the better choice.

### ADR-0015: Common concepts and extensibility

One spelling per concept (see *Component API*); shared building blocks in `Core/` (focus ring, press feedback,
icon, field container, presentation queue); own style protocols only for the four components SwiftUI can't style.
Type-erased style configurations are the only accepted use of `AnyView`, marked
`// swiftforge-lint: allow (ADR-0015)`.
