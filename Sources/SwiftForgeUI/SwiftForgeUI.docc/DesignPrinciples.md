# Design Principles

The ideas behind SwiftForgeUI's components, tokens, and themes.

## Overview

SwiftForgeUI builds on iOS's own visual language rather than competing with it. A SwiftForgeUI screen should sit
comfortably next to Settings or Health, yet carry a brand's color, shape, type, and density. These principles
decide what the library does, and what it deliberately leaves to SwiftUI.

### Native first

Where SwiftUI has a control and a style protocol, SwiftForgeUI styles it instead of replacing it: buttons, toggles,
checkboxes, progress views, group boxes, labeled content, and disclosure groups all take `.swiftForge` styles. Sheets,
menus, navigation, and alerts stay native and pick up the theme through `tint`. Custom views appear only where
SwiftUI has nothing comparable — chips, segmented controls with icons, steppers that speed up, one-time code fields,
toasts, and an opt-in tab bar — and those keep native semantics underneath, so VoiceOver, Voice Control, and Full
Keyboard Access see standard controls.

### Tokens, not values

Components never hard-code a color, size, radius, duration, or opacity. Every value comes from the theme in three
layers:

- **Primitive** values, such as a palette and a spacing scale.
- **Semantic** roles, such as ``SwiftForgeColors/textSecondary`` or ``SwiftForgeSpacing/screenHorizontal``.
- **Component** tokens, such as ``SwiftForgeChipTokens``. Their optional values fall back to semantic roles.

A theme changes how every component looks, and a lint script keeps literals out of the library.

### Accessible by construction

Accessibility is part of each component's design, not a later pass:

- Text colors meet WCAG 2.2 AA (4.5:1) on every surface, in light, dark, and Increase Contrast, in every built-in
  theme.
- Text scales through `accessibility5`, and layouts restack rather than truncate.
- Every target is at least 44 × 44 pt.
- Meaning never relies on color alone: selection shows a checkmark, errors show an icon, empty stars are outlined.
- Reduce Motion, Reduce Transparency, Bold Text, Button Shapes, Differentiate Without Color, and right-to-left
  layouts are handled by the components.
- Composite controls read as one element: a stepper is adjustable, and a one-time code field is one text field.

See <doc:Accessibility> for what's guaranteed and how it's verified.

### One way to say it

Concepts are shared across components:

- **Size** is `controlSize(_:)`.
- **Intent** is ``SwiftForgeTone``.
- **Spacing in rows** is ``SwiftForgeDensity``.
- **Validation** is ``SwiftForgeFieldState``.
- **Icons** use ``SwiftForgeIconPlacement``.
- **Focus** uses ``SwiftUICore/View/swiftForgeFocusRing(_:cornerRadius:)``.

Learn them once, and every component reads the same.

Emphasis works the same way in every theme: a tone's `subtle` color is the quiet version, its `solid` color the
loudest, and prominent banners, filled buttons, and badges use `solid`. What `solid` looks like is the theme's
choice. Forge keeps a saturated red with white text in dark mode; the other built-in themes light their solids up
in dark mode, with dark text. Either way, a prominent danger banner is the most
emphatic element on the screen, so choose prominence for its importance, not for a color.

### Extensible where it matters

You can restyle a component without forking it. Native style protocols cover most controls. Four components that
SwiftUI doesn't have get style protocols of their own: ``SwiftForgeFieldStyle``, ``SwiftForgeChipStyle``,
``SwiftForgeSegmentedControlStyle``, and ``SwiftForgeTabBarStyle``. Everything else is shaped through component
tokens. See <doc:WritingACustomComponentStyle>.

### Fast in lists

Components read only the environment values they need. They lay out with `Layout` rather than `GeometryReader`, and
draw continuous animations with `TimelineView` instead of repeating state. The stress page in the Showcase project
scrolls 500 mixed rows to keep this honest.

### No business logic

Components show state; your app decides it. A password field shows the strength you compute, a one-time code field
reports digits, and a presenter queues toasts — none of them validate, persist, or fetch.
