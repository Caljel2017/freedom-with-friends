# Create a versioned .pchtxt stub under FriendsFreedom/exefs.
param(
    [Parameter(Mandatory = $true)]
    [string]$BuildId,

    [Parameter(Mandatory = $true)]
    [string]$GameVersion,

    [string]$OutDir = (Join-Path $PSScriptRoot "..\FriendsFreedom\exefs")
)

$ErrorActionPreference = "Stop"

$build = ($BuildId -replace "[^0-9A-Fa-f]", "").ToUpperInvariant()
if ($build.Length -lt 16) {
    throw "Build ID looks too short. Paste the full main build ID from the emulator."
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$safeVersion = ($GameVersion -replace "[^\w\.\-]", "_")
$outFile = Join-Path $OutDir "FriendsFreedom_$safeVersion.pchtxt"

@"
@nsobid-$build
# Friends Freedom — ACNH multiplayer creative / terraform unlocks
# Game version: $GameVersion
# Build ID: $build
#
# STATUS: STUB ONLY — replace the example lines with real patched instructions
# discovered against this exact build. Do not enable guessed offsets.

@flag print_values
@flag offset_shift 0x100

# @enabled Force island designer / terraform permission (REPLACE offsets)
# 00000000 mov w0, #1
# 00000004 ret

# @enabled Allow host terraform while visitors present (REPLACE offsets)
# 00000000 nop
# 00000004 nop

# @enabled Relax outdoor place/furniture visitor lock (REPLACE offsets)
# 00000000 nop
"@ | Set-Content -Path $outFile -Encoding UTF8

Write-Host "Wrote stub: $outFile"
Write-Host "Fill in real offsets before enabling the mod in-game."
