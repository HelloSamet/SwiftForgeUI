# Accessibility

What SwiftForgeUI guarantees, how it's verified, and what remains your responsibility.

## Overview

SwiftForgeUI targets WCAG 2.2 AA and Apple's Human Interface Guidelines for accessibility. Each guarantee below holds
in **every built-in theme**, in light and dark mode, and is covered by an automated test in the repository.

### Guarantees

| Area | Guarantee | Verified by |
|---|---|---|
| Contrast | Text is at least 4.5:1; outlines, focus rings, and progress are at least 3:1, in light, dark, and both Increase Contrast appearances, including every gradient stop and the opaque fallback of every material. | ``SwiftForgeContrastAudit`` unit tests for all eight themes, and Apple's accessibility audit in each theme in light and dark mode |
| Increase Contrast | Secondary text reaches 7:1 or more, and every surface gains a border. | Unit tests, snapshot tests |
| Color | Status is never conveyed by color alone: banners, fields, and badges pair color with an icon and text; a switch's thumb position shows its state, and Differentiate Without Color adds on/off glyphs. | Snapshot tests |
| Dynamic Type | Text scales through `accessibility5` in every theme, including custom font families; inputs and rings grow instead of clipping. | Snapshot tests at AX5 in Forge, Neo-Brutal, and Mono; Apple's accessibility audit |
| Bold Text | Every text gets heavier: system fonts through SwiftUI, custom font families by moving to the next heavier face. | Unit tests, Bold Text snapshot tests |
| Hit areas | Every interactive element is at least 44 × 44 pt, including small buttons and switches. No theme can lower this: dense themes shrink controls visually, not their hit areas. | Rendering tests, UI tests, Apple's accessibility audit |
| VoiceOver | Text fields use their visible label, never the prompt; icon buttons use their title; banners read their tone, title, and message together; badges on buttons become the button's value; switches are standard switches with an on/off value. | UI tests |
| Localization | The library's own strings — "Loading", tone names, "Show password" — are localized and follow the environment's locale. | Unit and UI tests |
| Motion | With Reduce Motion, springs become short eases, press scaling and sinking stop, placeholders stop shimmering, and theme changes happen without animation. | Rendering tests, theme transition tests |
| Transparency | With Reduce Transparency, glass surfaces and scrims become opaque. | Rendering tests, Reduce Transparency snapshot tests |
| Layout direction | Layouts, directional icons, progress bars, and the shimmer mirror in right-to-left languages. | Rendering and snapshot tests |

### Your responsibilities

- **Labels for custom content.** Give custom button labels and icon-only controls an accessible title. Prefer
  `Button(_:systemImage:action:)`, whose title SwiftForgeUI keeps as the VoiceOver label.
- **Validation messages.** SwiftForgeUI announces the messages you provide; write them to say what's wrong and how
  to fix it.
- **Custom themes.** Run ``SwiftForgeContrastAudit`` on them in your tests (see <doc:CreatingACustomTheme>). Give
  every color Increase Contrast values, every material an opaque fallback, and register custom fonts in all the
  weights you use, so Bold Text has a heavier face to move to.
- **Meaningful dots.** ``SwiftForgeBadge/dot(tone:)`` is decorative. If it carries meaning, describe it in the
  label of the element it decorates.

### Preview accessibility settings

SwiftUI's Increase Contrast, Reduce Motion, and Reduce Transparency settings are read-only, so they can't be set in a
preview. Simulate them for SwiftForgeUI components instead:

```swift
#Preview("Increased contrast, reduced motion") {
    SettingsScreen()
        .swiftForgeAccessibilitySimulation(increasedContrast: true, reduceMotion: true)
}
```

A simulation only turns settings on; it never overrides a setting the person has enabled. Build your own components
on ``SwiftForgeAccessibilityContext`` to honor the same simulation. Differentiate Without Color can be simulated the
same way; Bold Text can be set directly with `.environment(\.legibilityWeight, .bold)`.

### How it's verified

Contrast is checked twice. ``SwiftForgeContrastAudit`` measures every token pairing exactly, in all four appearances.
Apple's runtime accessibility audit then inspects rendered screens in every built-in theme, in light and dark mode,
and catches problems a token check can't see — it found that progress rings drew in a color too faint for their
canvas, which led to drawing progress in each tone's text color. When the runtime audit reports a text contrast
problem, the tests measure the rendered pixels independently and accept the report as a false positive only if the
text really meets 4.5:1.

Every component's behavior with VoiceOver, Voice Control, and the keyboard is summarized in <doc:ComponentCatalog>.
UI tests check each component's accessibility tree — its labels, values, traits, and the
number of elements — and the runtime audit runs on every component page and example screen in all eight themes, in
light and dark mode. A handful of runtime-audit reports are known false positives, such as composite controls judged
as a whole; each exception is narrow, explained beside the test, and backed by a measurement or a native baseline.

### When you build screens

- Name text colors with ``SwiftUICore/View/swiftForgeTextStyle(_:color:)``. Text without a color uses SwiftUI's
  primary color, which isn't checked against the theme's surfaces.
- Put lists and forms on the theme with ``SwiftUICore/View/swiftForgeListStyle()`` and
  ``SwiftUICore/View/swiftForgeListRowBackground()``. Theme text isn't checked against the system's list colors.
- Use `Text(verbatim:)` for email addresses and URLs that aren't links. A string literal is read as Markdown, so
  they draw in the link color.

