# ``SwiftForgeUI``

An accessible, themeable SwiftUI design system that speaks SwiftUI's own language.

## Overview

SwiftForgeUI styles native SwiftUI controls with a coherent set of design tokens — color, typography, spacing,
radius, elevation, motion — and adds the components SwiftUI doesn't provide. Every component reads its tokens from
a ``SwiftForgeTheme`` in the environment, so one line restyles an entire app:

```swift
ContentView()
    .swiftForgeTheme(.midnight)
```

Eight built-in themes — Forge, Midnight, Aurora, Paper, Neo-Brutal, Mono, Ocean, and Sunset — differ in shape,
depth, density, typography, and motion, not only in color. Define your own in a few lines, scope a theme to part of a
screen, or let people choose one at runtime with ``SwiftForgeThemeManager``. See <doc:IntroducingThemes>.

Accessibility is part of each component's definition, not an option:

- Built-in themes meet WCAG 2.2 AA contrast in light, dark, and both Increase Contrast appearances —
  proven by ``SwiftForgeContrastAudit`` in every test run.
- Text scales with Dynamic Type through `accessibility5` and follows Bold Text; layouts wrap instead of truncating.
- Every interactive element keeps a 44 × 44 pt hit area.
- Meaning never relies on color alone, and the library's own strings are localized.
- Reduce Motion, Reduce Transparency, Differentiate Without Color, Button Shapes, and right-to-left layout are
  honored throughout.

SwiftForgeUI has no dependencies, performs no networking, and collects no data.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:DesignPrinciples>
- <doc:ComponentCatalog>
- <doc:IntroducingThemes>
- <doc:CreatingACustomTheme>
- <doc:TokenReference>
- <doc:WritingACustomComponentStyle>
- <doc:Accessibility>

### Theme

- ``SwiftForgeTheme``
- ``SwiftUICore/View/swiftForgeTheme(_:)-(SwiftForgeTheme)``
- ``SwiftUICore/EnvironmentValues/swiftForgeTheme``

### Runtime Theme Switching

- ``SwiftForgeThemeManager``
- ``SwiftUICore/View/swiftForgeTheme(_:)-(SwiftForgeThemeManager)``
- ``SwiftForgeThemeStore``
- ``SwiftForgeUserDefaultsThemeStore``
- ``SwiftForgeInMemoryThemeStore``

### Component Tokens

- ``SwiftForgeComponentTokens``
- ``SwiftForgeButtonTokens``
- ``SwiftForgeCardTokens``
- ``SwiftForgeSurfaceTokens``
- ``SwiftForgeFieldTokens``
- ``SwiftForgeToggleTokens``
- ``SwiftForgeBadgeTokens``
- ``SwiftForgeBannerTokens``
- ``SwiftForgeProgressTokens``
- ``SwiftForgeControlSizeValues``
- ``SwiftForgeLoadingOverlayTokens``
- ``SwiftForgeSelectionControlTokens``
- ``SwiftForgeChipTokens``
- ``SwiftForgeSegmentedControlTokens``
- ``SwiftForgeSliderTokens``
- ``SwiftForgeAvatarTokens``
- ``SwiftForgeEmptyStateTokens``
- ``SwiftForgeToastTokens``
- ``SwiftForgeDialogTokens``
- ``SwiftForgeTabBarTokens``
- ``SwiftForgeTooltipTokens``
- ``SwiftForgePressEffect``

### Shapes and Fills

- ``SwiftForgeShape``
- ``SwiftForgeCornerStyle``
- ``SwiftForgeFill``
- ``SwiftForgeMaterial``

### Color

- ``SwiftForgeColors``
- ``SwiftForgeColor``
- ``SwiftForgeToneColors``
- ``SwiftForgeTone``
- ``SwiftForgeContrastAudit``

### Typography

- ``SwiftForgeTypography``
- ``SwiftForgeTextStyle``
- ``SwiftForgeFontFamily``
- ``SwiftUICore/View/swiftForgeTextStyle(_:)``
- ``SwiftUICore/View/swiftForgeTextStyle(_:color:)``

### Layout, Elevation, and Motion

- ``SwiftForgeSpacing``
- ``SwiftForgeRadius``
- ``SwiftForgeSizes``
- ``SwiftForgeBorders``
- ``SwiftForgeOpacity``
- ``SwiftForgeElevation``
- ``SwiftForgeElevationLevel``
- ``SwiftForgeShadow``
- ``SwiftUICore/View/swiftForgeShadow(_:)``
- ``SwiftForgeMotion``
- ``SwiftForgeMotionToken``
- ``SwiftForgeHaptics``
- ``SwiftForgeHapticEvent``

### Building Blocks

- ``SwiftUICore/View/swiftForgeScreen()``
- ``SwiftForgeDensity``
- ``SwiftUICore/View/swiftForgeDensity(_:)``
- ``SwiftUICore/EnvironmentValues/swiftForgeDensity``
- ``SwiftForgeIcon``
- ``SwiftForgeIconPlacement``
- ``SwiftUICore/View/swiftForgeIconPlacement(_:)``
- ``SwiftUICore/EnvironmentValues/swiftForgeIconPlacement``
- ``SwiftUICore/View/swiftForgeFocusRing(_:cornerRadius:)``

### Buttons

- ``SwiftForgeButtonStyle``
- ``SwiftForgeButton``
- ``SwiftUICore/View/swiftForgeLoading(_:)``
- ``SwiftUICore/View/swiftForgeFullWidth(_:)``

### Toggles and Checkboxes

- ``SwiftForgeToggleStyle``
- ``SwiftForgeCheckboxToggleStyle``
- ``SwiftUICore/View/swiftForgeDescription(_:)-(Text?)``
- ``SwiftUICore/View/swiftForgeDescription(_:)-(LocalizedStringKey)``

### Choices

- ``SwiftForgeRadioGroup``
- ``SwiftForgeChip``
- ``SwiftForgeChipGroup``
- ``SwiftForgeChipStyle``
- ``SwiftForgeChipStyleConfiguration``
- ``SwiftForgeAutomaticChipStyle``
- ``SwiftUICore/View/swiftForgeChipStyle(_:)``
- ``SwiftForgeSegmentedControl``
- ``SwiftForgeSegmentedControlStyle``
- ``SwiftForgeSegmentConfiguration``
- ``SwiftForgeAutomaticSegmentedControlStyle``
- ``SwiftUICore/View/swiftForgeSegmentedControlStyle(_:)``
- ``SwiftForgeFlowLayout``

### Sliders and Steppers

- ``SwiftForgeSlider``
- ``SwiftForgeRangeSlider``
- ``SwiftForgeStepper``
- ``SwiftForgeRating``

### Text Input

- ``SwiftForgeTextField``
- ``SwiftForgeSecureField``
- ``SwiftForgeTextArea``
- ``SwiftForgeSearchField``
- ``SwiftForgePicker``
- ``SwiftForgeOTPField``
- ``SwiftForgePasswordStrength``
- ``SwiftUICore/View/swiftForgePasswordStrength(_:)``
- ``SwiftForgeFieldState``
- ``SwiftForgeClearButtonVisibility``
- ``SwiftUICore/View/swiftForgeClearButton(_:)``
- ``SwiftUICore/View/swiftForgeCharacterLimit(_:)``
- ``SwiftUICore/View/swiftForgeOptionalField(_:)``
- ``SwiftUICore/View/swiftForgeRevealButton(_:)``

### Building Your Own Fields

- ``SwiftForgeFieldContainer``
- ``SwiftForgeFieldStyle``
- ``SwiftForgeFieldStyleConfiguration``
- ``SwiftForgeAutomaticFieldStyle``
- ``SwiftUICore/View/swiftForgeFieldStyle(_:)``

### Toasts, Dialogs, Sheets, and Tooltips

- ``SwiftForgePresenter``
- ``SwiftUICore/View/swiftForgePresentationHost(_:toastEdge:)``
- ``SwiftForgeToast``
- ``SwiftForgeAlertDialog``
- ``SwiftUICore/View/swiftForgeBottomSheet(isPresented:detents:background:onDismiss:content:)``
- ``SwiftUICore/View/swiftForgeBottomSheet(item:detents:background:onDismiss:content:)``
- ``SwiftForgeSheetBackground``
- ``SwiftUICore/View/swiftForgeTooltip(isPresented:content:)``

### Navigation

- ``SwiftForgeTabBar``
- ``SwiftForgeTabItem``
- ``SwiftForgeTabBarStyle``
- ``SwiftForgeTabItemConfiguration``
- ``SwiftForgeAutomaticTabBarStyle``
- ``SwiftUICore/View/swiftForgeTabBarStyle(_:)``
- ``SwiftForgeNavigationHeader``

### Feedback

- ``SwiftForgeBanner``
- ``SwiftForgeBadge``
- ``SwiftUICore/View/swiftForgeBadge(count:tone:maxCount:)``
- ``SwiftForgeLinearProgressViewStyle``
- ``SwiftForgeCircularProgressViewStyle``
- ``SwiftUICore/View/swiftForgeSkeleton(isActive:label:)``
- ``SwiftForgeSkeletonShape``
- ``SwiftUICore/View/swiftForgeLoadingOverlay(isPresented:message:)``

### Lists

- ``SwiftUICore/View/swiftForgeListStyle()``
- ``SwiftUICore/View/swiftForgeListRowBackground()``
- ``SwiftForgeListRow``
- ``SwiftForgeRowButtonStyle``
- ``SwiftForgeLabeledContentStyle``
- ``SwiftForgeSectionHeader``

### People

- ``SwiftForgeAvatar``
- ``SwiftForgeAvatarGroup``

### Empty States

- ``SwiftForgeEmptyState``
- ``SwiftForgeEmptyStateSymbol``

### Containers

- ``SwiftForgeCard``
- ``SwiftForgeCardStyle``
- ``SwiftForgeCardGroupBoxStyle``
- ``SwiftForgeCardButtonStyle``
- ``SwiftForgeCardPadding``
- ``SwiftUICore/View/swiftForgeCardPadding(_:)``
- ``SwiftUICore/View/swiftForgeSurface(_:shape:outlined:)``
- ``SwiftForgeSurfaceLevel``
- ``SwiftForgeSurfaceShape``
- ``SwiftForgeDivider``
- ``SwiftForgeDisclosureGroupStyle``

### Accessibility Simulation

- ``SwiftForgeAccessibilityContext``
- ``SwiftForgeAccessibilityValues``
- ``SwiftForgeAccessibilitySimulation``
- ``SwiftUICore/View/swiftForgeAccessibilitySimulation(increasedContrast:reduceMotion:reduceTransparency:differentiateWithoutColor:)``
