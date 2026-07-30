# Compile + stage minimal 1.0 airport EventFlows (NOT Tutorial Skip).
# Requires: py -3.11, tools/acnh-eventflow-compiler, tools/ACNH-Tutorial-Skip-ref/functions.csv
# Sources: source/eventflow_1.0_airport_edit/*.evfl (from romfs_dump_1.0 decompile + edits)

param(
    [switch]$InstallYuzu
)

$ErrorActionPreference = "Stop"
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
Set-Location $root

$out = Join-Path $root "build\eventflow_1.0_airport_minimal"
New-Item -ItemType Directory -Force -Path $out | Out-Null

$files = @(
    "Demo_IdrAirPortArriveVisitor.evfl",
    "Demo_IdrAirPortRetireVisitor.evfl",
    "SNPC_dod_01_Airport_NormalSeq.evfl",
    "SNPC_dod_10_Airport_LocalHost.evfl",
    "SNPC_dod_11_Airport_LocalVisitor.evfl"
) | ForEach-Object { Join-Path $root "source\eventflow_1.0_airport_edit\$_" }

py -3.11 (Join-Path $root "tools\acnh-eventflow-compiler\main.py") `
    --functions (Join-Path $root "tools\ACNH-Tutorial-Skip-ref\functions.csv") `
    -d $out @files
if ($LASTEXITCODE -ne 0) { throw "EventFlow compile failed" }

$modEf = Join-Path $root "FreedomWithFriends\romfs\EventFlow"
$rstbDir = Join-Path $root "FreedomWithFriends\romfs\System\Resource"
New-Item -ItemType Directory -Force -Path $modEf, $rstbDir | Out-Null
Copy-Item -Force (Join-Path $out "*.bfevfl") $modEf
New-Item -ItemType File -Force -Path (Join-Path $rstbDir "ResourceSizeTable.srsizetable") | Out-Null

Write-Host "Staged $($files.Count) EventFlows into FreedomWithFriends\romfs"
Write-Host "WARNING: Do not mix in Tutorial Skip prologue EventFlows."

if ($InstallYuzu) {
    & (Join-Path $root "install\Install-Yuzu.ps1")
}
