# Create a versioned .pchtxt stub under FreedomWithFriends/exefs.
param(
    [Parameter(Mandatory = $true)]
    [string]$BuildId,

    [Parameter(Mandatory = $true)]
    [string]$GameVersion,

    [string]$OutDir = (Join-Path $PSScriptRoot "..\FreedomWithFriends\exefs")
)

$ErrorActionPreference = "Stop"

$build = ($BuildId -replace "[^0-9A-Fa-f]", "").ToUpperInvariant()
if ($build.Length -lt 16) {
    throw "Build ID looks too short. Paste the full main build ID from the emulator."
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$safeVersion = ($GameVersion -replace "[^\w\.\-]", "_")
$outFile = Join-Path $OutDir "FreedomWithFriends_$safeVersion.pchtxt"

@"
@nsobid-$build
# Freedom with Friends — ACNH $GameVersion
# Build ID: $build
# Scope: friend terraform / creative permission patches
# Related romfs features (fly anytime, random island, cutscene skip): see docs/
#
# STATUS: STUB ONLY — replace with real offsets for this build. No guessing.

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
