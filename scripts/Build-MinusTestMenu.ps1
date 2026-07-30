# Compile + stage 2.0.6 Minus menu: Save / Keep playing / Test
# ONLY System_GameClose + TalkSys label overlay. No Tutorial Skip EventFlows. No empty RSTB.

param(
    [switch]$InstallYuzu
)

$ErrorActionPreference = "Stop"
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
Set-Location $root

$out = Join-Path $root "build\eventflow_2.0.6"
New-Item -ItemType Directory -Force -Path $out | Out-Null

$src = Join-Path $root "source\eventflow_2.0.6\System_GameClose.evfl"
if (-not (Test-Path $src)) { throw "Missing $src" }

$funcs = Join-Path $root "tools\ACNH-Tutorial-Skip-ref\functions.csv"
if (-not (Test-Path $funcs)) { throw "Missing $funcs" }

Write-Host "Patching SYS_CloseMenu labels..."
py -3.11 (Join-Path $root "tools\patch_close_menu_freedom_msbt.py")
if ($LASTEXITCODE -ne 0) { throw "MSBT patch failed" }

Write-Host "Injecting TalkSys_USen.sarc.zs..."
py -3.11 (Join-Path $root "tools\inject_close_menu_talksys_sarc.py")
if ($LASTEXITCODE -ne 0) { throw "TalkSys sarc inject failed" }

Write-Host "Compiling System_GameClose..."
py -3.11 (Join-Path $root "tools\acnh-eventflow-compiler\main.py") `
    --functions $funcs `
    -d $out $src
if ($LASTEXITCODE -ne 0) { throw "EventFlow compile failed" }

$modRoot = Join-Path $root "FreedomWithFriends"
$modEf = Join-Path $modRoot "romfs\EventFlow"
$modMsg = Join-Path $modRoot "romfs\Message"
New-Item -ItemType Directory -Force -Path $modEf, $modMsg | Out-Null

# Strip any leftover Tutorial Skip / Movie / RSTB overlays
$romfs = Join-Path $modRoot "romfs"
foreach ($kill in @("Movie", "System")) {
    $p = Join-Path $romfs $kill
    if (Test-Path $p) { Remove-Item -Recurse -Force $p }
}
Get-ChildItem $modEf -Filter "*.bfevfl" -ErrorAction SilentlyContinue | Remove-Item -Force
Copy-Item -Force (Join-Path $out "System_GameClose.bfevfl") $modEf

# Message overlay already written by inject script into FreedomWithFriends/romfs/Message
if (-not (Test-Path (Join-Path $modMsg "TalkSys_USen.sarc.zs"))) {
    throw "Missing TalkSys_USen.sarc.zs after inject"
}

# Remove romfs README that said empty-only (replaced by real overlays)
$readme = Join-Path $romfs "README.txt"
if (Test-Path $readme) { Remove-Item -Force $readme }

Write-Host "Staged:"
Write-Host "  romfs/EventFlow/System_GameClose.bfevfl"
Write-Host "  romfs/Message/TalkSys_USen.sarc.zs"
Write-Host "Rollback black screen: delete those two files (keep cheats)."

if ($InstallYuzu) {
    & (Join-Path $root "install\Install-Yuzu.ps1")
}
