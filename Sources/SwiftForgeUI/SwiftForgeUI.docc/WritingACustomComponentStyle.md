# Writing a Custom Component Style

Change how a component looks while keeping its behavior and accessibility.

## Overview

There are three ways to customize a component, from lightest to heaviest:

1. **Theme tokens.** Change a value for every instance, in every screen: a chip's corner radius, a toast's width, a
   button's press effect. See <doc:CreatingACustomTheme>.
2. **Native style protocols.** Buttons, toggles, progress views, group boxes, labeled content, and disclosure groups
   are SwiftUI controls, so any `ButtonStyle`, `ToggleStyle`, and so on works with them. SwiftForgeUI's styles are
   ordinary examples of these.
3. **SwiftForgeUI style protocols.** Fields, chips, segmented controls, and tab bars aren't SwiftUI controls, so
   they have style protocols of their own: ``SwiftForgeFieldStyle``, ``SwiftForgeChipStyle``,
   ``SwiftForgeSegmentedControlStyle``, and ``SwiftForgeTabBarStyle``.

The style protocols follow SwiftUI's pattern. A style receives a configuration with the component's parts and state,
and returns a view. The component keeps everything that isn't appearance: its accessibility element, hit area,
focus, keyboard handling, and state.

### Write a style

Conform to the protocol and build the body from the configuration's parts. Read tokens from the theme so that the
style follows theme changes:

```swift
struct UnderlinedChipStyle: SwiftForgeChipStyle {
    @Environment(\.swiftForgeTheme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: theme.spacing.xxs) {
            configuration.label
            configuration.removeButton
        }
        .padding(.vertical, theme.spacing.xxs)
        .overlay(alignment: .bottom) {
            if configuration.isSelected {
                Rectangle()
                    .fill(theme.colors.accent.text)
                    .frame(height: theme.borders.thick)
            }
        }
        .opacity(configuration.isPressed ? theme.opacity.pressedContent : 1)
    }
}
```

Styles are `DynamicProperty` types, so `@Environment` and `@State` work in them, as in a view.

### Apply it

Set the style on a container, and every component inside uses it:

```swift
FilterBar()
    .swiftForgeChipStyle(UnderlinedChipStyle())
```

To offer the style like SwiftForgeUI's own, add a static member:

```swift
extension SwiftForgeChipStyle where Self == UnderlinedChipStyle {
    static var underlined: Self { UnderlinedChipStyle() }
}

FilterBar().swiftForgeChipStyle(.underlined)
```

### Keep it accessible

The component keeps its semantics whatever the style draws, but a style can still undo what the default
guarantees. Check these:

- **Don't rely on color alone.** A selected chip's label hides its icon, so draw something in its place, such as a
  checkmark or an underline.
- **Use text colors for text.** Use ``SwiftForgeColors/textPrimary``, ``SwiftForgeColors/textSecondary``, or a tone's
  ``SwiftForgeToneColors/text``. These are the colors checked for contrast on every surface.
- **Let text grow.** Use the theme's fonts, which scale with Dynamic Type, and allow wrapping instead of fixed
  heights.
- **Mind the motion.** Animate with the theme's motion tokens, passing Reduce Motion, as in
  `theme.motion.fast.animation(reduceMotion:)`.
- **Hide decoration.** Mark icons that repeat the label with `accessibilityHidden(true)`.

Preview your style across themes and settings with the Showcase app's controls, or with
``SwiftUICore/View/swiftForgeAccessibilitySimulation(increasedContrast:reduceMotion:reduceTransparency:differentiateWithoutColor:)``.
