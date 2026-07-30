# Compile System_GameClose only — NO TalkSys Message overlay (blank Minus hang).
param(
    [switch]$InstallYuzu
)

$ErrorActionPreference = "Stop"
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
Set-Location $root

$out = Join-Path $root "build\eventflow_2.0.6"
New-Item -ItemType Directory -Force -Path $out | Out-Null

$src = Join-Path $root "source\eventflow_2.0.6\System_GameClose.evfl"
$funcs = Join-Path $root "tools\ACNH-Tutorial-Skip-ref\functions.csv"
if (-not (Test-Path $src)) { throw "Missing $src" }
if (-not (Test-Path $funcs)) { throw "Missing $funcs" }

Write-Host "Compiling System_GameClose (Choice2, no Message overlay)..."
py -3.11 (Join-Path $root "tools\acnh-eventflow-compiler\main.py") --functions $funcs -d $out $src
if ($LASTEXITCODE -ne 0) { throw "EventFlow compile failed" }

$modRoot = Join-Path $root "FreedomWithFriends"
$modEf = Join-Path $modRoot "romfs\EventFlow"
$modMsg = Join-Path $modRoot "romfs\Message"
New-Item -ItemType Directory -Force -Path $modEf | Out-Null

# Strip Message overlay — causes HUD-hide with no dialog on this 2.0.6 Yuzu install
if (Test-Path $modMsg) {
    Remove-Item -Recurse -Force $modMsg
    Write-Host "Removed romfs/Message (TalkSys overlay)"
}
foreach ($kill in @("Movie", "System")) {
    $p = Join-Path $modRoot "romfs\$kill"
    if (Test-Path $p) { Remove-Item -Recurse -Force $p }
}

Get-ChildItem $modEf -Filter "*.bfevfl" -ErrorAction SilentlyContinue | Remove-Item -Force
Copy-Item -Force (Join-Path $out "System_GameClose.bfevfl") $modEf

Write-Host "Staged: romfs/EventFlow/System_GameClose.bfevfl only"

if ($InstallYuzu) {
    & (Join-Path $root "install\Install-Yuzu.ps1")
}
