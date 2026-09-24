#!/bin/bash
set -e

echo "Applying patches to MediaLib..."
git -C MediaLib apply --3way ../patches/01_medialib.patch

echo "Applying patches to Video..."
git -C Video apply --3way ../patches/02_video.patch

echo "Applying root core.mk patch..."
git apply --3way patches/03_root_core_mk.patch || true

echo "Applying patches to FileCoreLibrary..."
git -C FileCoreLibrary apply --3way ../patches/04_filecorelibrary.patch

echo "Applying patches to native/avos..."
git -C native/avos apply --3way ../../patches/05_native_avos.patch

echo "All custom patches applied successfully!"

