# Applies the custom patches (patches/*.patch) to aos-AVP and its submodules.
# Idempotent: a patch which is already applied is skipped. Each patch is checked before being
# applied, so a failure never leaves a half-patched repository behind.
# "Continue": with "Stop", Windows PowerShell 5.1 turns git's stderr output into exceptions;
# failures are detected through $LASTEXITCODE instead.
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot

$failed = $false

function Apply-Patch([string]$Repo, [string]$Patch) {
    $path = Join-Path $PSScriptRoot $Patch
    git -C $Repo apply --check --reverse $path 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "= ${Patch}: already applied" -ForegroundColor DarkGray
        return
    }
    git -C $Repo apply --check $path 2>$null
    if ($LASTEXITCODE -eq 0) {
        git -C $Repo apply $path
        Write-Host "+ ${Patch}: applied" -ForegroundColor Green
        return
    }
    git -C $Repo apply --3way $path
    if ($LASTEXITCODE -eq 0) {
        Write-Host "~ ${Patch}: applied with 3-way merge, check the result" -ForegroundColor Yellow
        return
    }
    Write-Host "! ${Patch}: FAILED (resolve conflicts in $Repo, then run patches/export_patches.sh)" -ForegroundColor Red
    $script:failed = $true
}

Apply-Patch "MediaLib"        "patches/01_medialib.patch"
Apply-Patch "Video"           "patches/02_video.patch"
Apply-Patch "."               "patches/03_root_core_mk.patch"
Apply-Patch "FileCoreLibrary" "patches/04_filecorelibrary.patch"
Apply-Patch "native/avos"     "patches/05_native_avos.patch"

if ($failed) { exit 1 }
Write-Host "All custom patches applied successfully!" -ForegroundColor Green
