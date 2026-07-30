# Assemble / refresh Freedom with Friends romFS EventFlow from a dump or Tutorial Skip release.
param(
    [string]$RomfsPath,
    [switch]$FromTutorialSkipRelease,
    [string]$OutRomfs = (Join-Path $PSScriptRoot "..\FreedomWithFriends\romfs")
)

$ErrorActionPreference = "Stop"
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$out = [IO.Path]::GetFullPath($OutRomfs)

if ($FromTutorialSkipRelease) {
    Write-Host "BLOCKED: Full Tutorial Skip black-screens ACNH 1.0.0 on this project."
    Write-Host "Use .\scripts\Build-AirportMinimal.ps1 instead (5 airport EventFlows from your dump)."
    throw "Refusing -FromTutorialSkipRelease for 1.0 safety. See docs\WHY_NO_EVENTFLOW.md"
}

if (-not $RomfsPath) {
    throw "Provide -RomfsPath <dumped 1.0 romfs> or use -FromTutorialSkipRelease"
}

$romfs = [IO.Path]::GetFullPath($RomfsPath)
if (-not (Test-Path (Join-Path $romfs "EventFlow"))) {
    throw "No EventFlow folder under $romfs"
}

Write-Host "Dump detected: $romfs"
Write-Host "For fly-anytime + short local cutscenes on 1.0, use:"
Write-Host "  .\scripts\Build-AirportMinimal.ps1 -InstallYuzu"
Write-Host "Editable sources: source\eventflow_1.0_airport_edit\"
Write-Host ""
Write-Host "Copying vanilla airport baselines from dump (no edits)..."
New-Item -ItemType Directory -Force -Path "$out\EventFlow" | Out-Null
$needed = @(
    "SNPC_dod_01_Airport_NormalSeq.bfevfl",
    "SNPC_dod_10_Airport_LocalHost.bfevfl",
    "SNPC_dod_11_Airport_LocalVisitor.bfevfl",
    "Demo_IdrAirPortArriveVisitor.bfevfl",
    "Demo_IdrAirPortRetireVisitor.bfevfl"
)
foreach ($f in $needed) {
    $p = Join-Path $romfs "EventFlow\$f"
    if (Test-Path $p) {
        Copy-Item -Force $p (Join-Path $out "EventFlow\$f")
        Write-Host "  + $f"
    } else {
        Write-Host "  missing $f (ok if 1.0 naming differs)"
    }
}

# Ensure RSTB disable exists for emulator LayeredFS comfort
$rstbDir = Join-Path $out "System\Resource"
New-Item -ItemType Directory -Force -Path $rstbDir | Out-Null
$rstb = Join-Path $rstbDir "ResourceSizeTable.srsizetable"
if (-not (Test-Path $rstb)) {
    New-Item -ItemType File -Force -Path $rstb | Out-Null
}
Write-Host "Done. Compile edited EVFL before relying on dump copies as final."
