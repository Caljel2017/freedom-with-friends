# Install Freedom with Friends into Yuzu (or a fork that uses the same load layout).
param(
    [string]$ModSource = (Join-Path $PSScriptRoot "..\FreedomWithFriends"),
    [string]$EmulatorName = "yuzu",
    [string]$TitleId = "01006F8002326000",
    [string]$ModName = "FreedomWithFriends"
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

# Yuzu also reads cheats from load/<title>/cheats when present beside mods;
# copy build-id cheat next to the title load root for easier toggles.
$cheatSrc = Join-Path $modSource "cheats"
$cheatDest = Join-Path $root "load\$TitleId\cheats"
if (Test-Path $cheatSrc) {
    New-Item -ItemType Directory -Force -Path $cheatDest | Out-Null
    Copy-Item -Force (Join-Path $cheatSrc "*") $cheatDest
}

Write-Host "Installed Freedom with Friends to:"
Write-Host "  $dest"
Write-Host "Cheats (if any): $cheatDest"
Write-Host ""
Write-Host "Enable the mod for Animal Crossing: New Horizons in $([IO.Path]::GetFileName($root))."
Write-Host "Multiplayer: .\scripts\Setup-Connectivity.ps1 -Mode Hamachi"
Write-Host "Every friend needs the same game version and this same mod folder."
