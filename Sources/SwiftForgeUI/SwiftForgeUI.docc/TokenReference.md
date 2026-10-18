# Token Reference

Every token a theme defines, what it's for, and its value in the Forge theme.

## Overview

Tokens are grouped into categories on ``SwiftForgeTheme``. Semantic tokens name a role shared by every component;
component tokens in ``SwiftForgeTheme/components`` override a role for one component. Values below are Forge's; the
colors of the other built-in themes, with their contrast ratios, are documented in the repository under
`docs/design/themes/`.

### Colors — ``SwiftForgeColors``

Each color has light, dark, and both Increase Contrast values (``SwiftForgeColor``).

| Token | Role | Contrast guarantee |
|---|---|---|
| ``SwiftForgeColors/canvas`` | Screen background | — |
| ``SwiftForgeColors/surface`` | Cards, list cells, text fields | — |
| ``SwiftForgeColors/surfaceRaised`` | Elevated cards, menus, toasts | — |
| ``SwiftForgeColors/fillMuted`` | Tracks and placeholders | — (decorative) |
| ``SwiftForgeColors/textPrimary`` | Primary text | 4.5:1 on every surface and tinted background |
| ``SwiftForgeColors/textSecondary`` | Secondary text, helpers, prompts | 4.5:1 on every surface and tinted background |
| ``SwiftForgeColors/borderSubtle`` | Decorative separators | — (decorative) |
| ``SwiftForgeColors/borderStrong`` | Control outlines | 3:1 on every surface |
| ``SwiftForgeColors/focusRing`` | Keyboard focus | 3:1 on every surface |
| ``SwiftForgeColors/pressedOverlay`` | Layer over pressed controls | — |

Six tones — ``SwiftForgeTone/accent``, ``SwiftForgeTone/neutral``, ``SwiftForgeTone/info``,
``SwiftForgeTone/success``, ``SwiftForgeTone/warning``, ``SwiftForgeTone/danger`` — each have four colors
(``SwiftForgeToneColors``):

| Token | Role | Contrast guarantee |
|---|---|---|
| ``SwiftForgeToneColors/solid`` | Filled backgrounds: filled buttons, count badges, switch tracks | — |
| ``SwiftForgeToneColors/onSolid`` | Text and icons on `solid` | 4.5:1 on `solid` and every `solidFill` color |
| ``SwiftForgeToneColors/text`` | Tinted text and icons, progress | 4.5:1 on surfaces and `subtle`; 3:1 on `fillMuted` |
| ``SwiftForgeToneColors/subtle`` | Tinted backgrounds: tinted buttons, banners, badges | — |
| ``SwiftForgeToneColors/solidFill`` | Optional gradient or material for large filled areas | — |

### Typography — ``SwiftForgeTypography``

Every role is a ``SwiftForgeTextStyle`` anchored to a Dynamic Type text style, with a weight, a system design
(default, serif, rounded, or monospaced), leading, and tracking. ``SwiftForgeTypography/fontFamily`` sets the system
font or a custom family for all roles.

| Role | Text style | Forge weight | Used by |
|---|---|---|---|
| `largeTitle`, `title1`, `title2` | `.largeTitle`, `.title`, `.title2` | bold | Screen titles |
| `title3` | `.title3` | semibold | Subtitles |
| `headline` | `.headline` | semibold | Card and list titles |
| `body` | `.body` | regular | Body text, text input, toggle labels |
| `callout`, `subheadline`, `footnote` | `.callout`, `.subheadline`, `.footnote` | regular | Descriptions, secondary text, banner messages |
| `caption1`, `caption2` | `.caption`, `.caption2` | regular, medium | Metadata |
| `controlLabel`, `controlLabelSmall` | `.body`, `.subheadline` | semibold | Button labels |
| `fieldLabel`, `fieldHelper` | `.subheadline`, `.footnote` | medium, regular | Text field labels and messages |
| `badge` | `.caption` | semibold | Badge text |

### Layout — ``SwiftForgeSpacing``, ``SwiftForgeRadius``, ``SwiftForgeSizes``, ``SwiftForgeBorders``

| Category | Tokens (Forge) |
|---|---|
| Spacing scale | `xxxs` 2 · `xxs` 4 · `xs` 8 · `sm` 12 · `md` 16 · `lg` 20 · `xl` 24 · `xxl` 32 · `xxxl` 40 |
| Spacing roles | `screenHorizontal` 16 · `section` 24 · `component` 12 · `cardPadding` 16 |
| Radius scale | `xs` 4 · `sm` 8 · `md` 12 · `lg` 16 · `xl` 20 · `xxl` 28 |
| Radius roles | `control` 12 · `controlSmall` 8 · `card` 16 · `sheet` 28 · ``SwiftForgeRadius/cornerStyle`` continuous · ``SwiftForgeRadius/capsule`` for pills |
| Sizes | `minimumHitTarget` 44 (never lower) · control heights 32 / 44 / 52 · icons 16 / 20 / 24 |
| Borders | `thin` 1 · `thick` 2 · `focusRingOffset` 2 · hairlines are one physical pixel |

### Depth — ``SwiftForgeElevation``

| Level | Forge shadow | Used by |
|---|---|---|
| ``SwiftForgeElevationLevel/low`` | 8% black, radius 3, y 1 | Switch thumbs; buttons in themes that give them elevation |
| ``SwiftForgeElevationLevel/medium`` | 10% black, radius 12, y 4 | Elevated cards, raised surfaces |
| ``SwiftForgeElevationLevel/high`` | 16% black, radius 32, y 12 | Overlays |

``SwiftForgeElevation/raisedSurfacesHaveBorder`` draws hairlines around raised surfaces, for themes that convey depth
with lines. Surfaces always gain a border with Increase Contrast on.

### State and motion — ``SwiftForgeOpacity``, ``SwiftForgeMotion``, ``SwiftForgeHaptics``

| Token | Forge | Role |
|---|---|---|
| `opacity.disabled` | 0.38 | Whole disabled control |
| `opacity.pressedContent` | 0.6 | Plain button content while pressed |
| `opacity.scrim`, `scrimReducedTransparency` | 0.72, 0.95 | Loading overlay scrim |
| `opacity.skeletonPulse` | 0.45 | Center of the shimmer band |
| `motion.fast`, `standard`, `emphasized` | 0.2 s (bounce 0.15), 0.3 s, 0.45 s (bounce 0.15) | Press feedback; appearing content and theme changes; emphasis |
| `motion.pressedScale` | 0.97 | Default press effect |
| `motion.shimmerDuration`, `shimmerBandWidth` | 1.4 s, 0.6 | Loading placeholders |
| `haptics` | selection and status events | Which events play feedback |

### Component tokens — ``SwiftForgeComponentTokens``

`nil` means "derive from the semantic tokens".

| Component | Token | Default |
|---|---|---|
| ``SwiftForgeButtonTokens`` | `cornerRadius` | `nil` → `radius.control` / `controlSmall` |
| | `borderWidth`, `borderColor` | `nil` → outline buttons only, `borders.thin`, tone text color |
| | `elevation` | `.none` |
| | `pressEffect` | `nil` → `.scale(motion.pressedScale)` |
| ``SwiftForgeCardTokens`` | `pressEffect` | `.scale(0.98)` |
| ``SwiftForgeSurfaceTokens`` | `borderWidth`, `borderColor` | `nil` → hairline, `borderSubtle` |
| | `bordersEverySurface` | `false` |
| | `fills` | `[:]` → each level's color |
| ``SwiftForgeFieldTokens`` | `style`, `cornerRadius`, `background` | `.outlined`, `nil` → `radius.control`, `nil` → `surface` |
| ``SwiftForgeToggleTokens`` | `trackWidth`, `trackHeight`, `thumbInset`, `cornerRadius` | 51, 31, 2, capsule |
| | `borderWidth`, `borderColor`, `thumbElevation` | `nil` → off track only, `borderStrong`, `.low` |
| ``SwiftForgeBadgeTokens`` | `cornerRadius`, `borderWidth`, `borderColor` | capsule, `nil`, `nil` → tone text |
| | `countDiameter`, `countDiameterSmall`, `countDiameterLarge`, `dotDiameter` | 18, 16, 24, 8 (scaled with Dynamic Type) |
| ``SwiftForgeBannerTokens`` | `cornerRadius`, `borderWidth`, `title` | `nil` → `radius.card`, `nil`, `nil` → semibold subheadline |
| ``SwiftForgeProgressTokens`` | `barHeight`, `barHeightLarge`, `barCornerRadius` | 4, 8, capsule |
| | `ringDiameters`, `ringLineWidth`, `ringLineWidthLarge` | 24 / 32 / 48, 4, 6 |
| ``SwiftForgeLoadingOverlayTokens`` | `scrim` | `nil` → `canvas` |
| ``SwiftForgeSelectionControlTokens`` | `size`, `checkboxCornerRadius` | 22 (scaled with Dynamic Type), `nil` → `radius.xs` |
| | `borderWidth`, `borderColor` | `nil` → `borders.thick`, `nil` → `borderStrong` (tone text when checked) |
| ``SwiftForgeChipTokens`` | `cornerRadius`, `height` | `nil` → `radius.controlSmall`, `nil` → `sizes.controlHeightSmall` |
| | `borderWidth`, `borderColor` | `nil` → `borders.thin`, `nil` → `borderStrong` (tone text when selected) |
| ``SwiftForgeSegmentedControlTokens`` | `cornerRadius`, `indicatorInset`, `indicatorElevation` | `nil` → `radius.control`, 2, `.low` |
| | `borderWidth`, `borderColor` | `nil` → none (thin with Increase Contrast), `nil` → `borderStrong` |
| ``SwiftForgeSliderTokens`` | `trackHeight`, `thumbDiameter`, `thumbCornerRadius` | 4, 24, capsule |
| | `thumbBorderWidth`, `thumbBorderColor`, `thumbElevation` | `nil` → none, `nil` → `borderStrong`, `.low` |
| ``SwiftForgeAvatarTokens`` | `diameters`, `cornerRadius`, `ringWidth`, `groupOverlap` | 28 / 40 / 64, capsule, 2, 0.3 |
| | `borderWidth`, `borderColor` | `nil` → none, `nil` → `borderStrong` |
| ``SwiftForgeEmptyStateTokens`` | `iconSize`, `maxContentWidth` | 48 (scaled with Dynamic Type), 420 |
| ``SwiftForgeToastTokens`` | `cornerRadius`, `maxWidth` | `nil` → `radius.card`, 560 |
| | `shortDuration`, `longDuration` | 4, 8 seconds (doubled with VoiceOver; toasts with an action stay) |
| ``SwiftForgeDialogTokens`` | `cornerRadius`, `width`, `scrim` | `nil` → `radius.sheet`, 320 (scaled with Dynamic Type), `nil` → `canvas` |
| ``SwiftForgeTabBarTokens`` | `height`, `iconSize` | 49, 24 |
| ``SwiftForgeTooltipTokens`` | `maxWidth` | 280 |
