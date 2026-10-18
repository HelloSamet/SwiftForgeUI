# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/). Until 1.0.0, minor versions may contain breaking changes; each is listed
under **Breaking** with its migration path.

## [Unreleased]

## [0.2.0] - 2026-10-18

The first public release: a themeable component library built on native SwiftUI controls. Eight built-in themes
that differ in shape, depth, density, typography, and motion; more than 30 components; and WCAG AA contrast in every
theme and appearance, verified by unit tests, snapshots, and Apple's accessibility audit. Requires Xcode 16.4 and
iOS 17 or visionOS 1.

### Added

#### Theming

- **`SwiftForgeTheme`** with token categories for colors, typography, spacing, radius, sizes, borders, elevation,
  opacity, motion, and haptics, plus **component tokens** for every component. Apply it with
  `.swiftForgeTheme(_:)`; nested themes scope to a subtree, and the innermost wins.
- **Eight built-in themes**, each with light, dark, and both Increase Contrast appearances: `.forge` (the default),
  `.midnight`, `.aurora`, `.paper`, `.neoBrutal`, `.mono`, `.ocean`, and `.sunset`. `SwiftForgeTheme.builtIn` lists
  them.
- **Runtime theme switching** with `SwiftForgeThemeManager`: offers a list of themes, restores the stored choice
  before the first frame, and animates changes (instantly with Reduce Motion). Persistence goes through
  `SwiftForgeThemeStore`, with `SwiftForgeUserDefaultsThemeStore` and `SwiftForgeInMemoryThemeStore`.
- **Custom themes** in a few lines with `SwiftForgeTheme(id:displayName:basedOn:customize:)`, and
  `SwiftForgeToneColors.derived(from:on:)` to build a contrast-checked tone from one brand color.
- **`SwiftForgeContrastAudit`**: checks a theme against WCAG 2.x contrast in four appearances, including gradient
  stops, material fallbacks, and component borders. Debug builds log a custom theme's violations once.
- `SwiftForgeColor` (light, dark, and Increase Contrast values; usable as a `ShapeStyle`), `SwiftForgeFill` (color,
  gradient, or material with an opaque Reduce Transparency fallback), `SwiftForgeShape`, `SwiftForgePressEffect`,
  and custom font families that scale with Dynamic Type.

#### Components

- **Actions:** `.buttonStyle(.swiftForge(_:tone:))` with filled, tinted, outlined, and plain variants, sizes from
  `controlSize`, and destructive styling from `role`; `.buttonStyle(.swiftForgeIcon(…))`; `SwiftForgeButton`, which
  runs an `async` action with a loading state and never runs it twice; `.toggleStyle(.swiftForge)` and
  `.toggleStyle(.swiftForgeCheckbox)` (with the mixed state); `SwiftForgeChip` and `SwiftForgeChipGroup`;
  `SwiftForgeSegmentedControl`.
- **Inputs:** `SwiftForgeTextField`, `SwiftForgeSecureField` (with `.swiftForgePasswordStrength(_:)`),
  `SwiftForgeTextArea`, `SwiftForgeSearchField`, `SwiftForgePicker`, `SwiftForgeRadioGroup`, `SwiftForgeSlider`,
  `SwiftForgeRangeSlider`, `SwiftForgeStepper`, and `SwiftForgeOTPField`; `SwiftForgeFieldContainer` gives any control
  the label, message row, and accessibility of a SwiftForgeUI field.
- **Display:** `SwiftForgeCard` (header, footer, `.groupBoxStyle(.swiftForgeCard(_:))`, tappable cards),
  `SwiftForgeListRow`, `SwiftForgeSectionHeader`, `.swiftForgeListStyle()`, `SwiftForgeAvatar`,
  `SwiftForgeAvatarGroup`, `SwiftForgeBadge`, `SwiftForgeRating`, `SwiftForgeDivider` (with a label),
  `.disclosureGroupStyle(.swiftForge)`, `.progressViewStyle(.swiftForgeLinear / .swiftForgeCircular)`,
  `.swiftForgeSkeleton(isActive:)`, and `SwiftForgeEmptyState`.
- **Feedback and overlays:** `SwiftForgeBanner`; `SwiftForgePresenter` with `SwiftForgeToast` and
  `SwiftForgeAlertDialog`, shown one at a time and in order, with localized or plain-string text; `.swiftForgeBottomSheet(isPresented:)`;
  `.swiftForgeTooltip(_:isPresented:)`, which also works on iPhone; and `.swiftForgeLoadingOverlay(isPresented:)`.
- **Navigation:** `SwiftForgeTabBar` and `SwiftForgeNavigationHeader`.
- **Screens and layout:** `.swiftForgeScreen()`, `.swiftForgeTextStyle(_:color:)`, `SwiftForgeDensity`,
  `SwiftForgeFlowLayout`, `SwiftForgeIcon`, `.swiftForgeIconPlacement(_:)`, `.swiftForgeSurface(_:shape:outlined:)`,
  and `.swiftForgeFocusRing(_:cornerRadius:)`.
- **Customization:** native style protocols, plus `SwiftForgeFieldStyle`, `SwiftForgeChipStyle`,
  `SwiftForgeSegmentedControlStyle`, and `SwiftForgeTabBarStyle`.

#### Accessibility and localization

- AA contrast in every theme and appearance; Dynamic Type through `accessibility5`; 44 × 44 pt hit areas; VoiceOver
  labels that match visible text; Bold Text, Reduce Motion, Reduce Transparency, Differentiate Without Color, Button
  Shapes, and right-to-left layouts.
- `.swiftForgeAccessibilitySimulation(…)` previews Increase Contrast, Reduce Motion, Reduce Transparency, and
  Differentiate Without Color; `SwiftForgeAccessibilityContext` lets custom styles honor them.
- Library strings in English and Turkish that follow the environment's locale.

#### Documentation and tooling

- DocC: Getting Started, Design Principles, Component Catalog, Introducing Themes, Creating a Custom Theme, Token
  Reference, Writing a Custom Component Style, and Accessibility.
- Showcase app with a live catalog, theme gallery and comparison, a state matrix, three example screens, and the
  snapshot, UI, accessibility-audit, and scrolling-performance test suites.
- CI for the minimum and latest toolchains, `swift format` and design-token linting, and DocC.

[Unreleased]: https://github.com/HelloSamet/SwiftForgeUI/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/HelloSamet/SwiftForgeUI/releases/tag/v0.2.0
