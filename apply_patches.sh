#!/bin/bash
# Applies the custom patches (patches/*.patch) to aos-AVP and its submodules.
# Idempotent: a patch which is already applied is skipped. Each patch is checked before being
# applied, so a failure never leaves a half-patched repository behind.
set -euo pipefail
cd "$(dirname "$0")"

failed=0

# apply_patch <repository> <patch file relative to the repository root>
apply_patch() {
    local repo=$1 patch=$2
    local path
    path="$(pwd)/$patch"
    if git -C "$repo" apply --check --reverse "$path" 2>/dev/null; then
        echo "= $patch: already applied"
    elif git -C "$repo" apply --check "$path" 2>/dev/null; then
        git -C "$repo" apply "$path"
        echo "+ $patch: applied"
    elif git -C "$repo" apply --3way "$path"; then
        echo "~ $patch: applied with 3-way merge, check the result"
    else
        echo "! $patch: FAILED (resolve conflicts in $repo, then run patches/export_patches.sh)" >&2
        failed=1
    fi
}

apply_patch MediaLib        patches/01_medialib.patch
apply_patch Video           patches/02_video.patch
apply_patch .               patches/03_root_core_mk.patch
apply_patch FileCoreLibrary patches/04_filecorelibrary.patch
apply_patch native/avos     patches/05_native_avos.patch

if [ "$failed" -ne 0 ]; then
    exit 1
fi
echo "All custom patches applied successfully!"
