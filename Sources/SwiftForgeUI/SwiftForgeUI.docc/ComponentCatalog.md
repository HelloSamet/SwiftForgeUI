# Component Catalog

Every component, what it's for, and how it behaves with assistive technologies.

## Overview

Components are grouped as in the Showcase app. Each takes its look from the current theme, scales with Dynamic Type
through `accessibility5`, and keeps a 44-pt hit area. The *Accessibility* column notes what VoiceOver or the keyboard
does beyond the defaults.

### Actions

| Component | Use it for | Accessibility |
|---|---|---|
| ``SwiftForgeButtonStyle`` | Filled, tinted, outlined, plain, and destructive buttons; loading and full-width options | Loading reads as the button's value; press feedback follows Reduce Motion |
| ``SwiftForgeButton`` | A button that runs an async action and shows its progress | Disabled while running; errors go to a handler |
| Icon buttons (`.swiftForgeIcon`) | Symbol-only buttons | The title is the VoiceOver label |
| ``SwiftForgeToggleStyle`` | Switches with an optional description | A standard switch |
| ``SwiftForgeCheckboxToggleStyle`` | Checkboxes, including the mixed state | A standard toggle with values off, on, and mixed |
| ``SwiftForgeChip``, ``SwiftForgeChipGroup`` | Filters, tags, and removable tokens | Selected chips have the selected trait; remove buttons are named |
| ``SwiftForgeSegmentedControl`` | Two to five exclusive choices, with icons | Each segment reads "*n* of *count*" |

### Inputs and forms

| Component | Use it for | Accessibility |
|---|---|---|
| ``SwiftForgeTextField``, ``SwiftForgeSecureField`` | Labeled fields with helper, error, and success messages | The label isn't the prompt; the message is read with the field |
| ``SwiftForgeTextArea`` | Multi-line input with a character count | The count is read with the field |
| ``SwiftForgeSearchField`` | Search with a clear and cancel button | A search field |
| ``SwiftForgePicker`` | A choice from a menu, in a field's frame | The selection is the value |
| ``SwiftForgeRadioGroup`` | One choice from two to five visible options | Each option reads "*n* of *count*" |
| ``SwiftForgeSlider``, ``SwiftForgeRangeSlider`` | A value or a range within bounds | Standard adjustable sliders; each range thumb is its own element |
| ``SwiftForgeStepper`` | A small count, faster while held | A standard adjustable stepper |
| ``SwiftForgeOTPField`` | One-time codes, filled from a text message | One element: "4 of 6 digits entered" |
| ``SwiftForgePasswordStrength`` | A strength meter you compute | Read with the field |

### Display

| Component | Use it for | Accessibility |
|---|---|---|
| ``SwiftForgeCard`` | Grouped content with a header and footer; tappable cards | A tappable card is one button |
| ``SwiftForgeListRow`` | Rows with leading and trailing content, values, and accessories | The leading content is decorative; values stack at accessibility sizes |
| ``SwiftForgeSectionHeader`` | Section titles with an action | A header |
| ``SwiftUICore/View/swiftForgeListStyle()`` | `List` and `Form` in theme colors | Theme text keeps its contrast |
| ``SwiftForgeAvatar``, ``SwiftForgeAvatarGroup`` | People, with presence | Reads the name and status, or "and *n* others" |
| ``SwiftForgeBadge`` | Counts, dots, and labels | Counts read in full ("120 new items") |
| ``SwiftForgeRating`` | Read-only and interactive star ratings | "4.5 of 5 stars"; interactive ratings are adjustable |
| ``SwiftForgeDivider`` | Separators, optionally labeled | Labeled dividers read their label |
| ``SwiftForgeDisclosureGroupStyle`` | Accordions | The header is a button with "Expanded" or "Collapsed" |
| Progress views (``SwiftForgeLinearProgressViewStyle``, ``SwiftForgeCircularProgressViewStyle``) | Determinate and indeterminate progress | Standard progress values |
| ``SwiftUICore/View/swiftForgeSkeleton(isActive:label:)`` | Placeholders while loading | Each placeholder reads "Loading" instead of the content it hides |
| ``SwiftForgeEmptyState`` | Empty and no-results screens | The title is a header |

### Feedback and overlays

| Component | Use it for | Accessibility |
|---|---|---|
| ``SwiftForgeBanner`` | Inline messages in a tone | Reads the tone, title, and message together |
| ``SwiftForgeToast`` | Brief confirmations, with an optional action | Announced without moving focus; time doubles with VoiceOver; toasts with an action stay |
| ``SwiftForgeAlertDialog`` | Confirmations with one to three actions | Modal: the content behind is hidden; Escape cancels |
| ``SwiftUICore/View/swiftForgeBottomSheet(isPresented:detents:background:onDismiss:content:)`` | Sheets with detents | SwiftUI's own sheet |
| ``SwiftUICore/View/swiftForgeTooltip(isPresented:content:)`` | A sentence of extra detail next to a control, on iPhone too | A popover: VoiceOver moves in and leaves with the escape gesture; text tooltips are also the pointer `help` |
| ``SwiftUICore/View/swiftForgeLoadingOverlay(isPresented:message:)`` | Blocking progress | Announces the message |

### Navigation

| Component | Use it for | Accessibility |
|---|---|---|
| ``SwiftForgeTabBar`` | A themed tab bar, when the system's isn't enough | Tabs read "*n* of *count*" with badges; Large Content Viewer for the fixed-size labels |
| ``SwiftForgeNavigationHeader`` | A large title in the content that hands off to the navigation bar | A header |

### Screens

| API | Use it for |
|---|---|
| ``SwiftUICore/View/swiftForgeScreen()`` | A scrolling screen on the theme's canvas, with the theme's margins |
| ``SwiftUICore/View/swiftForgeTextStyle(_:color:)`` | Text in a type role and a theme color |
