#!/bin/bash
# Regenerates patches/*.patch from the working trees of the repositories.
#
# Each patch is the difference between the upstream revision the customizations are based on
# and the current working tree (committed or not). After rebasing onto a new upstream version,
# update the *_BASE revisions below.
#
# Patches are written by git itself (UTF-8, LF line endings): never redirect git output through
# PowerShell, which would produce UTF-16 files that `git apply` rejects.
set -euo pipefail
cd "$(dirname "$0")/.."

ROOT_BASE=eacf19d        # aos-AVP: core.mk
MEDIALIB_BASE=10ad7fba   # MediaLib: upstream v6.4-lint (v6.5.2)
VIDEO_BASE=64f3c33e      # Video: upstream v6.4-lint (v6.5.2)
FILECORE_BASE=8b27f02    # FileCoreLibrary: upstream v6.4-lint
AVOS_BASE=8e3172b        # native/avos

# export_patch <repository> <base> <patch file> <pathspec>...
export_patch() {
    local repo=$1 base=$2 out=$3
    shift 3
    # New files must be known to the index to appear in `git diff` (intent-to-add only: the
    # content is not staged).
    git -C "$repo" ls-files -z --others --exclude-standard -- "$@" | xargs -0 -r git -c core.safecrlf=false -C "$repo" add --intent-to-add --
    git -c core.safecrlf=false -C "$repo" diff --no-color --no-ext-diff --output="$PWD/$out" "$base" -- "$@"
    echo "$out: $(grep -c '^diff --git' "$out") files"
}

export_patch MediaLib        "$MEDIALIB_BASE" patches/01_medialib.patch        build.gradle src test
export_patch Video           "$VIDEO_BASE"    patches/02_video.patch           . ':(exclude).gradle' ':(exclude)build'
export_patch .               "$ROOT_BASE"     patches/03_root_core_mk.patch    core.mk
export_patch FileCoreLibrary "$FILECORE_BASE" patches/04_filecorelibrary.patch src test
export_patch native/avos     "$AVOS_BASE"     patches/05_native_avos.patch     Source
