# Security Policy

## Scope

SwiftForgeUI is a UI-only SwiftUI component library. It performs no networking, collects no analytics or
telemetry, and stores nothing but the identifier of the theme a person chose (in `UserDefaults`, unless you supply
your own store). The realistic security surface is narrow: mainly the integrity of the source and of the build and
release tooling.

## Supported versions

| Version | Supported |
|---|---|
| 0.2.x (latest minor) | ✅ |
| Earlier | ❌ |

Until 1.0, only the latest minor version receives fixes. From 1.0, the latest minor of the current and the previous
major version will.

## Reporting a vulnerability

Please **don't open a public issue**. Report it privately through
[GitHub's private vulnerability reporting](https://github.com/HelloSamet/SwiftForgeUI/security/advisories/new)
for this repository.

Include a description of the issue and its impact, steps to reproduce or a minimal project, and the SwiftForgeUI,
Xcode, and OS versions. You can expect an acknowledgment within 5 business days and an assessment within 14 days.
Once a fix is released, the advisory is published with credit to you, unless you prefer otherwise.
