# Compile + stage 1.0 save-unlock EventFlow + Minus→Test Message overlay.
# Do NOT mix airport / Tutorial Skip EventFlow packs. Requires: py -3.11, compiler, functions.csv, zstandard.

param(
    [switch]$InstallYuzu
)

$ErrorActionPreference = "Stop"
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
Set-Location $root

$out = Join-Path $root "build\eventflow_1.0_save_unlock"
New-Item -ItemType Directory -Force -Path $out | Out-Null

$src = Join-Path $root "source\eventflow_1.0_save_unlock\System_GameClose.evfl"
if (-not (Test-Path $src)) { throw "Missing $src" }

# Patch SYS_CloseMenu.msbt labels (Test / Status / Tips) and inject into TalkSys_USen.sarc.zs
py -3.11 (Join-Path $root "tools\patch_close_menu_test_msbt.py")
if ($LASTEXITCODE -ne 0) { throw "MSBT patch failed" }
py -3.11 (Join-Path $root "tools\inject_close_menu_talksys_sarc.py")
if ($LASTEXITCODE -ne 0) { throw "TalkSys sarc inject failed" }

py -3.11 (Join-Path $root "tools\acnh-eventflow-compiler\main.py") `
    --functions (Join-Path $root "tools\ACNH-Tutorial-Skip-ref\functions.csv") `
    -d $out $src
if ($LASTEXITCODE -ne 0) { throw "EventFlow compile failed" }

$modEf = Join-Path $root "FreedomWithFriends\romfs\EventFlow"
$rstbDir = Join-Path $root "FreedomWithFriends\romfs\System\Resource"
New-Item -ItemType Directory -Force -Path $modEf, $rstbDir | Out-Null

# Keep EventFlow install minimal: only this one bfevfl (+ empty RSTB). Strip any other EventFlows.
Get-ChildItem $modEf -Filter "*.bfevfl" -ErrorAction SilentlyContinue | Remove-Item -Force
Copy-Item -Force (Join-Path $out "System_GameClose.bfevfl") $modEf
New-Item -ItemType File -Force -Path (Join-Path $rstbDir "ResourceSizeTable.srsizetable") | Out-Null
$keep = Join-Path $root "FreedomWithFriends\romfs\.keep"
if (Test-Path $keep) { Remove-Item -Force $keep }

Write-Host "Staged System_GameClose.bfevfl + Message\TalkSys_USen.sarc.zs"
Write-Host "Rollback black screen: delete romfs\EventFlow\System_GameClose.bfevfl (and optional Message + RSTB)."

if ($InstallYuzu) {
    & (Join-Path $root "install\Install-Yuzu.ps1")
}
