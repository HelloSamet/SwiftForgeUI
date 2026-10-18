# Releasing

## Versioning

SwiftForgeUI follows [Semantic Versioning 2.0](https://semver.org). The public API is every `public` symbol plus the
documented visual and accessibility guarantees, such as 44 pt hit areas and AA contrast in the built-in themes.

| Change | Before 1.0 | From 1.0 |
|---|---|---|
| Breaking API change (removed or renamed symbol, changed signature or behavior) | Minor (`0.x.0`) | Major, after at least one minor release of deprecation |
| New API, component, or token | Minor | Minor |
| Bug fix | Patch | Patch |
| Token value change (a color, radius, or spacing) | Minor, under **Visual** in the changelog | Minor, under **Visual** |
| New case in an enum documented as gaining cases only in major releases | Minor | Major |
| New case in any other enum | Minor | Minor |

Every breaking change is listed under **Breaking** in [CHANGELOG.md](CHANGELOG.md) with a migration path. Tags are
`vX.Y.Z` (Swift Package Manager accepts the `v` prefix).

## Every release

1. CI is green on `main`: lint, both toolchains, iOS 17, documentation.
2. If references changed, the snapshot revision in `Examples/SwiftForgeShowcase/snapshots.revision` is pushed to
   SwiftForgeUI-Snapshots (`scripts/snapshots.sh pin` refuses an unpushed one).
3. In `CHANGELOG.md`, rename **Unreleased** to `## [X.Y.Z] - YYYY-MM-DD`, add a new empty **Unreleased** section, and
   update the comparison links at the bottom.
4. Update the version in the README's installation snippet if the minor or major version changed.
5. Commit (`chore(release): X.Y.Z`), then tag and push:

   ```bash
   git tag -a vX.Y.Z -m "SwiftForgeUI X.Y.Z"
   git push origin main vX.Y.Z
   ```

6. Create a GitHub release from the tag with the changelog section as its notes.
7. Check that the documentation workflow published the site.

## 1.0.0

Release 1.0.0 only when all of these hold:

- [ ] 0.9.0 has been out for two weeks without a breaking change.
- [ ] Every new public enum's documentation says whether it may gain cases in minor releases (see
      [ADR-0010](docs/ARCHITECTURE.md#adr-0010-versioning)).
- [ ] A manual tour with VoiceOver, Voice Control, Switch Control, and Full Keyboard Access found nothing open.
- [ ] iPad layouts are covered by snapshot tests, and custom controls show pointer hover effects.
- [ ] An Instruments pass on a device met the scrolling budget.
- [ ] CI is green on the oldest supported toolchain and OS (Xcode 16.4, iOS 17) and on the newest.
- [ ] No compiler warnings, lint findings, or DocC warnings.
- [ ] README, DocC, CONTRIBUTING, and this file describe the released behavior.
