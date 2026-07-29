# Install Friends Freedom into Yuzu (or a fork that uses the same load layout).
param(
    [string]$ModSource = (Join-Path $PSScriptRoot "..\FriendsFreedom"),
    [string]$EmulatorName = "yuzu",
    [string]$TitleId = "01006F8002326000",
    [string]$ModName = "FriendsFreedom"
)

$ErrorActionPreference = "Stop"

$modSource = [System.IO.Path]::GetFullPath($ModSource)
if (-not (Test-Path $modSource)) {
    throw "Mod source not found: $modSource"
}

$candidates = @(
    (Join-Path $env:APPDATA $EmulatorName),
    (Join-Path $env:APPDATA "yuzu"),
    (Join-Path $env:APPDATA "suyu"),
    (Join-Path $env:APPDATA "sudachi"),
    (Join-Path $env:APPDATA "citron")
) | Select-Object -Unique

$root = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $root) {
    $root = Join-Path $env:APPDATA $EmulatorName
    New-Item -ItemType Directory -Force -Path $root | Out-Null
    Write-Host "Created emulator folder: $root"
}

$dest = Join-Path $root "load\$TitleId\$ModName"
New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null

if (Test-Path $dest) {
    Remove-Item -Recurse -Force $dest
}

Copy-Item -Recurse -Force $modSource $dest
Write-Host "Installed Friends Freedom to:"
Write-Host "  $dest"
Write-Host ""
Write-Host "Enable the mod for Animal Crossing: New Horizons in $([IO.Path]::GetFileName($root))."
Write-Host "Every friend needs the same game version and this same mod folder."
