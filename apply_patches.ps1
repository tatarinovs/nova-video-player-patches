# Script to apply custom patches to aos-AVP (MediaLib, Video, core.mk)
$ErrorActionPreference = "Stop"

Write-Host "Applying patches to MediaLib..." -ForegroundColor Cyan
git -C MediaLib apply --3way ../patches/01_medialib.patch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to apply 01_medialib.patch." -ForegroundColor Red
    exit 1
}

Write-Host "Applying patches to Video..." -ForegroundColor Cyan
git -C Video apply --3way ../patches/02_video.patch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to apply 02_video.patch." -ForegroundColor Red
    exit 1
}

Write-Host "Applying root core.mk patch..." -ForegroundColor Cyan
git apply --3way patches/03_root_core_mk.patch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Notice: 03_root_core_mk.patch not applied (may already be up-to-date)." -ForegroundColor Yellow
}
Write-Host "Applying patches to FileCoreLibrary..." -ForegroundColor Cyan
git -C FileCoreLibrary apply --3way ../patches/04_filecorelibrary.patch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to apply 04_filecorelibrary.patch." -ForegroundColor Red
    exit 1
}

Write-Host "Applying patches to native/avos..." -ForegroundColor Cyan
git -C native/avos apply --3way ../../patches/05_native_avos.patch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to apply 05_native_avos.patch." -ForegroundColor Red
    exit 1
}

Write-Host "All custom patches applied successfully!" -ForegroundColor Green

