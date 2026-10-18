# Contributing to SwiftForgeUI

Thanks for considering a contribution. SwiftForgeUI is a design system that apps build on, so changes to public API,
visuals, or accessibility behavior are held to a high bar.

## Before you start

- **New component or API change:** open an issue describing the use case first. API in a design system is hard to
  walk back. Check the [roadmap](README.md#roadmap) and open issues — it may already be planned.
- **Bug fix:** a pull request without an issue is fine.
- **Design decisions** that affect the architecture are recorded in the
  [decision log](docs/ARCHITECTURE.md#decision-log); propose a new entry in the issue.

## Setup

Requires Xcode 16.4 or later.

```bash
git clone https://github.com/HelloSamet/SwiftForgeUI.git
cd SwiftForgeUI
scripts/snapshots.sh fetch                                          # snapshot references (see Testing)
open Package.swift                                                  # the library
open Examples/SwiftForgeShowcase/SwiftForgeShowcase.xcodeproj       # catalog and test host
```

## Rules

These are enforced in review and, where possible, by CI.

1. **Tokens, never literals.** Colors, spacing, radii, sizes, opacities, and animations come from the theme.
   `scripts/lint-design-tokens.sh` rejects literals in component code; if one is genuinely necessary, end the line
   with `// swiftforge-lint: allow (reason)`.
2. **Native first.** Style SwiftUI controls with their style protocols, `controlSize`, `role`, and `disabled`.
   Write a custom view only when SwiftUI offers no styling hook ([ADR-0002](docs/ARCHITECTURE.md#adr-0002-style-based-api)).
3. **Accessibility is the definition of done**, not a follow-up: contrast via theme tokens, 44 pt hit areas,
   Dynamic Type without clipping, VoiceOver labels matching visible text, Reduce Motion through
   `@SwiftForgeAccessibilityContext`, right-to-left layouts.
4. **Enums for mutually exclusive state**, modifiers for independent options.
5. **No dependencies, no business logic.** No networking, analytics, persistence, or validation rules.
6. **Every public symbol has a DocC comment**; `swift format lint` enforces it.
7. **Swift 6 strict concurrency with zero warnings.**
8. **Performance:** no `GeometryReader`, `AnyView`, or `@Environment(\.self)` in components
   ([ADR-0009](docs/ARCHITECTURE.md#adr-0009-performance)).

## Component definition of done

A component is done when all of these hold (also in the pull-request template):

- [ ] The issue or pull request describes its anatomy, sizes, variants, and every state that applies (default,
      pressed, focused, disabled, loading, error)
- [ ] Public API is documented with DocC and examples
- [ ] Previews cover light/dark, AX5 Dynamic Type, right-to-left, disabled/loading, and every theme (`SwiftForgeThemeMatrix`)
- [ ] It appears in the Showcase catalog and in `Specimens.swift`
- [ ] Unit tests cover its logic; snapshot tests cover the variant matrix
- [ ] The accessibility audit and VoiceOver UI tests pass
- [ ] No strict-concurrency warnings
- [ ] Reviewed for performance in the Showcase stress test

## Testing

```bash
# Unit tests: tokens, themes, contrast, state, localization, rendering contracts
xcodebuild test -scheme SwiftForgeUI -destination 'platform=iOS Simulator,name=iPhone 16'

# Snapshot, accessibility-audit, and UI tests
xcodebuild test -project Examples/SwiftForgeShowcase/SwiftForgeShowcase.xcodeproj -scheme SwiftForgeShowcase \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max'
```

On pull requests, CI runs lint, the unit tests, and the snapshot tests. The UI and accessibility-audit tests take about
half an hour, so they run on every push to `main` and nightly instead: if your change affects interaction or
accessibility, run them locally (`-only-testing:UITests`) before opening the pull request.

### Snapshots

Reference images live in the separate
[SwiftForgeUI-Snapshots](https://github.com/HelloSamet/SwiftForgeUI-Snapshots) repository, so apps that add
SwiftForgeUI as a package don't download them. Fetch them once after cloning, and again whenever
`Examples/SwiftForgeShowcase/snapshots.revision` changes:

```bash
scripts/snapshots.sh fetch
```

Snapshots are compared only on iOS 18 simulators, because font rendering changes between major OS versions; on
other versions the suite is skipped. The Showcase scheme runs tests in English (US) whatever the simulator's language,
because line breaking and hyphenation follow the system language, not the SwiftUI locale; when running tests from
another scheme or a test plan, pass `-testLanguage en -testRegion US`.
Run the suite on an iPhone Pro Max simulator: the accessibility audits inspect whole fixture screens, and on shorter
screens they misreport content cut off at the bottom edge and layouts that change structure at large text sizes. To record or update references:

```bash
TEST_RUNNER_SWIFTFORGE_RECORD_SNAPSHOTS=1 xcodebuild test \
  -project Examples/SwiftForgeShowcase/SwiftForgeShowcase.xcodeproj -scheme SwiftForgeShowcase \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' -only-testing:SnapshotTests
```

Recording fails each test on purpose so a recording run is never mistaken for a passing one. **Look at every new or
changed image** in `Examples/SwiftForgeShowcase/__Snapshots__` before committing; include before/after images in the
pull request for visual changes. Failed comparisons write the actual image to `__Snapshots__/.failures/`.

To submit changed references:

1. In `Examples/SwiftForgeShowcase/__Snapshots__` (a checkout of the snapshot repository), create a branch, commit
   the images, push, and open a pull request there.
2. Here, run `scripts/snapshots.sh pin` and commit the updated `snapshots.revision` with your change. CI tests
   against exactly that revision.

CI can also record references in its own environment: run the CI workflow manually with **record-snapshots** and
download the `snapshot-references` artifact.

## Linting

```bash
swift format format --in-place --recursive Sources Tests Examples
swift format lint --strict --recursive Sources Tests Examples
scripts/lint-design-tokens.sh
```

## Localization

Library strings live in `Sources/SwiftForgeUI/Resources/Localizable.xcstrings`, with keys prefixed `swiftforge.`.
Add every new string in English and Turkish; translations into other languages are very welcome.

## Pull requests

- One component or fix per pull request.
- Update `CHANGELOG.md` under **Unreleased**; list breaking changes under **Breaking** with a migration path.
- Mark visual changes and include snapshot diffs.

## Code of Conduct

Participation is governed by our [Code of Conduct](CODE_OF_CONDUCT.md).
