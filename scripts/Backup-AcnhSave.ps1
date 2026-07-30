# Backup ACNH save (Yuzu) before adding a second resident or swapping islands.
param(
    [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"
$title = "01006F8002326000"
$saveRoot = Join-Path $env:APPDATA "yuzu\nand\user\save\0000000000000000"

$found = @()
Get-ChildItem $saveRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $p = Join-Path $_.FullName $title
    if (Test-Path (Join-Path $p "main.dat")) {
        $found += $p
    }
}

if ($found.Count -eq 0) {
    throw "No ACNH save with main.dat found under $saveRoot"
}

if (-not $OutDir) {
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $OutDir = Join-Path (Split-Path $PSScriptRoot -Parent) "backups\acnh_save_$stamp"
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

foreach ($src in $found) {
    $userId = Split-Path (Split-Path $src -Parent) -Leaf
    $dest = Join-Path $OutDir $userId
    Write-Host "Backing up $src -> $dest"
    Copy-Item -Recurse -Force $src $dest
}

Write-Host ""
Write-Host "Backup complete: $OutDir"
Write-Host "Next: docs\LIVE_ON_HOST_ISLAND.md (add a second Yuzu profile and move in)."
Write-Host "Open that doc now? (Y/N)"
