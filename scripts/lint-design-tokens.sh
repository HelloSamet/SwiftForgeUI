#!/usr/bin/env bash
#
# Enforces SwiftForgeUI's design-token and performance rules (ADR-0007,
# ADR-0009) on component code. Token definitions (Tokens/, Themes/) and
# previews (everything after the first #Preview in a file) are exempt.
# A line ending in `// swiftforge-lint: allow` is exempt; say why next to it.
#
# Usage: scripts/lint-design-tokens.sh [source-root]

set -euo pipefail

root="${1:-Sources/SwiftForgeUI}"
status=0

rules=(
  'padding\([^)]*[1-9][0-9]*(\.[0-9]+)?\)::Hardcoded padding: use theme.spacing'
  '\.opacity\(0?\.[0-9]+\)::Hardcoded opacity: use theme.opacity'
  'cornerRadius: [1-9]::Hardcoded corner radius: use theme.radius'
  'lineWidth: [1-9]::Hardcoded line width: use theme.borders'
  'frame\([^)]*(width|height|minWidth|minHeight|maxWidth|maxHeight): [1-9][0-9]*::Hardcoded size: use theme.sizes or @ScaledMetric'
  'Color\.(white|black|red|green|blue|orange|yellow|gray|purple|pink)\b::System color literal: use a theme color token'
  '\\\.accessibilityReduceMotion::Read Reduce Motion through @SwiftForgeAccessibilityContext'
  '\\\.accessibilityReduceTransparency::Read Reduce Transparency through @SwiftForgeAccessibilityContext'
  '\\\.colorSchemeContrast::Read Increase Contrast through @SwiftForgeAccessibilityContext'
  'GeometryReader::GeometryReader in a component: use Layout, visualEffect, or alignment guides (ADR-0009 P2)'
  'AnyView::AnyView: use @ViewBuilder and some View (ADR-0009 P10)'
  '@Environment\(\\\.self\)::@Environment(\.self) invalidates on every change (ADR-0009 P1)'
  'drawingGroup\(::drawingGroup rasterizes text (ADR-0009 P6)'
  'RoundedRectangle\(|Capsule\(::Fixed corner shape: use theme.radius.shape(_:) so themes control corners (ADR-0011)'
  'style: \.continuous::Fixed corner style: use theme.radius.shape(_:), which follows theme.radius.cornerStyle (ADR-0011)'
)

# Files where the rule's subject is defined rather than used.
exempt_paths='/(Tokens|Themes|Internal)/|/Theming/(SwiftForgeAccessibility|SwiftForgeContrastAudit)\.swift$'

while IFS= read -r file; do
  [[ "$file" =~ $exempt_paths ]] && continue
  # Only lint code before the first #Preview.
  body="$(awk '/^#Preview/ { exit } { printf "%d:%s\n", NR, $0 }' "$file")"
  for rule in "${rules[@]}"; do
    pattern="${rule%%::*}"
    message="${rule#*::}"
    while IFS= read -r match; do
      [[ -z "$match" ]] && continue
      [[ "$match" == *"swiftforge-lint: allow"* ]] && continue
      line="${match%%:*}"
      echo "$file:$line: error: $message"
      status=1
    done < <(grep -E -- "$pattern" <<< "$body" | grep -vE '^[0-9]+:\s*///' || true)
  done
done < <(find "$root" -name '*.swift' | sort)

if [[ $status -eq 0 ]]; then
  echo "Design-token lint passed."
fi
exit $status
