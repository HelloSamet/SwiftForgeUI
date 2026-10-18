# Theme design tool

Designs the colors of the Midnight, Aurora, Paper, Neo-Brutal, Mono, Ocean, and Sunset themes. Python 3 standard library only.

- `colorlib.py` — WCAG 2.x math identical to `Sources/SwiftForgeUI/Internal/ColorMath.swift`, and OKLab ramps:
  every ramp step sits at a fixed perceptual lightness, so `Cyan.700` and `Rose.700` contrast alike.
- `themes.py` — the design source: ramp anchors, named colors, and each semantic role's light, dark, and Increase
  Contrast values.
- `audit.py` — the checks of `SwiftForgeContrastAudit`, run on the design source.
- `gen.py` — writes the primitive palettes (`Tokens/Primitives/SwiftForgePalette+*.swift`), the per-theme docs in
  `docs/design/themes/`, and the color blocks to paste into `Themes/SwiftForgeTheme+*.swift`.

```bash
python3 scripts/theme-design/audit.py
python3 scripts/theme-design/gen.py
swift format format -i Sources/SwiftForgeUI/Tokens/Primitives/*.swift
```

The Swift files are the source of truth at runtime, and `SwiftForgeContrastAudit` re-verifies them in every test run.
Non-color tokens (shape, depth, type, density, motion, component tokens) are written by hand in each theme's Swift file.
