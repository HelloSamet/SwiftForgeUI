#!/usr/bin/env bash
#
# Builds the DocC documentation as a static website.
#
#   scripts/build-docs.sh [output-directory] [hosting-base-path]
#
# Defaults: .build/docs, hosted at the site root. For GitHub Pages, pass the
# repository name as the base path, e.g. `scripts/build-docs.sh site SwiftForgeUI`.
#
# Xcode's docbuild documents every SwiftUI modifier each public view inherits
# (about 31,000 pages); extracting the symbol graph with
# -skip-synthesized-members keeps the site to SwiftForgeUI's own API.
# Warnings are errors.

set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
output=${1:-"$root/.build/docs"}
base_path=${2:-}
work="$root/.build/docs-work"

rm -rf "$work" "$output"
mkdir -p "$work/symbol-graphs"

xcodebuild build -quiet -scheme SwiftForgeUI -destination "generic/platform=iOS Simulator" \
    -derivedDataPath "$work/DerivedData" ARCHS=arm64 ONLY_ACTIVE_ARCH=NO

xcrun swift-symbolgraph-extract \
    -module-name SwiftForgeUI \
    -target arm64-apple-ios17.0-simulator \
    -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
    -I "$work/DerivedData/Build/Products/Debug-iphonesimulator" \
    -minimum-access-level public \
    -skip-synthesized-members \
    -emit-extension-block-symbols \
    -output-dir "$work/symbol-graphs"

arguments=(
    "$root/Sources/SwiftForgeUI/SwiftForgeUI.docc"
    --additional-symbol-graph-dir "$work/symbol-graphs"
    --fallback-display-name SwiftForgeUI
    --fallback-bundle-identifier SwiftForgeUI
    --transform-for-static-hosting
    --warnings-as-errors
    --output-path "$output"
)
if [[ -n "$base_path" ]]; then
    arguments+=(--hosting-base-path "$base_path")
fi
xcrun docc convert "${arguments[@]}"

# The site's root has no page of its own; send visitors to the package's documentation.
echo '<!doctype html><meta http-equiv="refresh" content="0; url=documentation/swiftforgeui/">' >"$output/index.html"
echo "Documentation: $output"
