# Prepare co-resident workflow: backup save + open the live-on-island guide.
$ErrorActionPreference = "Stop"
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))

Write-Host "=== Freedom with Friends: live on a host island ===" -ForegroundColor Cyan
Write-Host "Quit Yuzu/ACNH first if it is running."
Write-Host ""

& (Join-Path $PSScriptRoot "Backup-AcnhSave.ps1")

$doc = Join-Path $root "docs\LIVE_ON_HOST_ISLAND.md"
Write-Host ""
Write-Host "Guide: $doc"
if (Test-Path $doc) {
    Start-Process notepad.exe $doc
}

Write-Host ""
Write-Host "In Yuzu: add a new user profile, select it, launch ACNH, and move in as a new resident."
Write-Host "That gives a real tent + Tom Nook / Isabelle / Nook Stop on that island."
