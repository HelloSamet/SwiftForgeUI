#!/usr/bin/env bash
#
# Manages the snapshot reference images. They live in the separate
# SwiftForgeUI-Snapshots repository, so apps that add SwiftForgeUI as a
# package never download them.
#
#   scripts/snapshots.sh fetch   Clone the references into Examples/SwiftForgeShowcase/__Snapshots__
#                                and check out the revision pinned in snapshots.revision.
#   scripts/snapshots.sh pin     Pin the checkout's current commit, after pushing it.
#
# The repository URL is this repository's `upstream` (or `origin`) remote with
# "-Snapshots" appended to its name. Set SWIFTFORGE_SNAPSHOTS_URL to override it.

set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
checkout="$root/Examples/SwiftForgeShowcase/__Snapshots__"
revision_file="$root/Examples/SwiftForgeShowcase/snapshots.revision"

die() {
    echo "error: $*" >&2
    exit 1
}

snapshots_url() {
    if [[ -n "${SWIFTFORGE_SNAPSHOTS_URL:-}" ]]; then
        echo "$SWIFTFORGE_SNAPSHOTS_URL"
        return
    fi
    local remote url
    for remote in upstream origin; do
        if url=$(git -C "$root" remote get-url "$remote" 2>/dev/null); then
            echo "${url%.git}-Snapshots.git"
            return
        fi
    done
    die "no upstream or origin remote; set SWIFTFORGE_SNAPSHOTS_URL"
}

fetch() {
    local revision
    revision=$(tr -d '[:space:]' <"$revision_file")
    [[ -n "$revision" ]] || die "$revision_file is empty"

    if [[ ! -d "$checkout/.git" ]]; then
        if [[ -d "$checkout" && -n "$(ls -A "$checkout")" ]]; then
            die "$checkout exists but isn't a checkout; move it away and run again"
        fi
        git clone --quiet "$(snapshots_url)" "$checkout"
    elif [[ -n "$(git -C "$checkout" status --porcelain --untracked-files=no)" ]]; then
        die "the snapshot checkout has uncommitted changes; commit or discard them first"
    fi

    if ! git -C "$checkout" cat-file -e "$revision^{commit}" 2>/dev/null; then
        git -C "$checkout" fetch --quiet origin
    fi
    git -C "$checkout" checkout --quiet --detach "$revision"
    echo "Snapshot references at $revision"
}

pin() {
    [[ -d "$checkout/.git" ]] || die "no snapshot checkout; run '$0 fetch' first"
    [[ -z "$(git -C "$checkout" status --porcelain)" ]] || die "commit the changed references first"
    local head
    head=$(git -C "$checkout" rev-parse HEAD)
    if [[ -z "$(git -C "$checkout" branch --remotes --contains "$head")" ]]; then
        die "push $head to the snapshot repository before pinning it; CI fetches it from there"
    fi
    echo "$head" >"$revision_file"
    echo "Pinned $head in ${revision_file#"$root/"}"
}

case "${1:-fetch}" in
fetch) fetch ;;
pin) pin ;;
*) die "usage: $0 [fetch|pin]" ;;
esac
