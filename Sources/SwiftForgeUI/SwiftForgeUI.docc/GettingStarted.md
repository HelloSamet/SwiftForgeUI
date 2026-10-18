# Getting Started with SwiftForgeUI

Add the package, apply a theme, and build a screen from styled native controls.

## Overview

SwiftForgeUI requires iOS 17 or visionOS 1, and Xcode 16 or later.

### Add the package

In Xcode, choose **File > Add Package Dependencies…** and enter the repository URL. Or add it to your
`Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/HelloSamet/SwiftForgeUI.git", from: "0.2.0")
],
targets: [
    .target(name: "MyApp", dependencies: ["SwiftForgeUI"])
]
```

### Apply a theme

Components work without setup, using ``SwiftForgeTheme/forge``. Apply a theme at the root of your app to choose
another one, or your own:

```swift
import SwiftForgeUI
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .swiftForgeTheme(.forge)
        }
    }
}
```

The theme's accent also becomes the view's tint, so native `Toggle`, `Slider`, and `ProgressView` match.

### Build a screen

SwiftForgeUI styles SwiftUI's own controls wherever SwiftUI allows it. Buttons are native `Button`s with
``SwiftForgeButtonStyle``; size comes from `controlSize(_:)` and destructive styling from `role:`:

```swift
struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.component) {
            SwiftForgeTextField("Email", text: $email, prompt: Text("you@example.com")) {
                Image(systemName: "envelope")
            }
            .textContentType(.username)
            .keyboardType(.emailAddress)

            SwiftForgeSecureField("Password", text: $password)
                .textContentType(.password)

            SwiftForgeButton("Sign In") {
                try await session.signIn(email: email, password: password)
            }
            .controlSize(.large)

            Button("Forgot password?") { showReset() }
                .buttonStyle(.swiftForge(.plain))
        }
        .swiftForgeFullWidth()
        .padding(theme.spacing.screenHorizontal)
    }
}
```

``SwiftForgeButton`` runs its `async` action, shows a loading indicator while it's in flight, and ignores further
taps until it finishes.

### Use tokens in your own views

Read the theme from the environment instead of hard-coding values, so your views follow theme changes too:

```swift
struct OrderSummary: View {
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Text("Order #1042").swiftForgeTextStyle(\.headline)
            Text("Arrives Thursday")
                .swiftForgeTextStyle(\.subheadline)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(theme.spacing.cardPadding)
        .swiftForgeSurface(.raised)
    }
}
```

### Style lists and forms

`List` and `Form` draw in the system's grouped colors. SwiftForgeUI's text colors are checked for contrast against
the theme's canvas and surfaces, so put themed lists on them:

```swift
List {
    Section {
        Toggle("Notifications", isOn: $notifications)
    }
    .swiftForgeListRowBackground()
}
.swiftForgeListStyle()
.toggleStyle(.swiftForge)
```

### Avoid common pitfalls

- **Email addresses and URLs in `Text("…")` turn into links.** A string literal is a `LocalizedStringKey`, which
  SwiftUI reads as Markdown, so `Text("ada@example.com")` draws in the link color. Use `Text(verbatim:)` for
  prompts, subtitles, and values that aren't meant to be localized or tapped.
- **Apply the theme once.** Sheets and other presentations inherit it through the environment; calling
  `swiftForgeTheme(_:)` again inside them adjusts the theme for Bold Text a second time.

### Explore the catalog

The `Examples/SwiftForgeShowcase` Xcode project in the repository shows every component with live controls for the
theme, appearance, Dynamic Type, layout direction, language, and accessibility settings, along with three example
screens built only from SwiftForgeUI: sign-in and sign-up, settings, and an inbox with a detail screen.
