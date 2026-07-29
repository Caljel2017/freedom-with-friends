# Install Friends Freedom into Ryujinx (or a fork that uses mods\contents).
param(
    [string]$ModSource = (Join-Path $PSScriptRoot "..\FriendsFreedom"),
    [string]$EmulatorName = "Ryujinx",
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
    (Join-Path $env:APPDATA "Ryujinx"),
    (Join-Path $env:APPDATA "Ryujinx-LDN"),
    (Join-Path $env:APPDATA "ryujinx")
) | Select-Object -Unique

$root = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $root) {
    $root = Join-Path $env:APPDATA $EmulatorName
    New-Item -ItemType Directory -Force -Path $root | Out-Null
    Write-Host "Created emulator folder: $root"
}

$dest = Join-Path $root "mods\contents\$TitleId\$ModName"
New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null

if (Test-Path $dest) {
    Remove-Item -Recurse -Force $dest
}

Copy-Item -Recurse -Force $modSource $dest
Write-Host "Installed Friends Freedom to:"
Write-Host "  $dest"
Write-Host ""
Write-Host "Right-click ACNH in Ryujinx → manage mods / open mods directory and confirm FriendsFreedom is present."
Write-Host "Use an LDN-capable build for multiplayer. Matching game version required for all players."
