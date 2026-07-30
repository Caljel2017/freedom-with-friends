# Hamachi join assistant for Freedom with Friends (ACNH 1.0)
#
# WHAT THIS DOES:
#   - Ensures Hamachi is running and the Hamachi adapter has a VPN IP
#   - Polls until other 25.x peers appear (and optionally pings -HostIp)
#   - Prints loud "host gate open - do this NOW" Orville steps for Guest/Host
#   - Optionally watches for an emulator window and re-prints the checklist
#   - With -AutomateClicks: opens a Notepad checklist (opt-in UI only)
#
# WHAT THIS CANNOT DO:
#   LayeredFS cannot teleport you to Orville or inject an LDN join.
#   True auto-teleport / auto-join would need fragile controller automation
#   against the live game, or reverse-engineered hooks - not EventFlow packs
#   (full EventFlow / OpeningMovie overlays black-screen on this 1.0 install).
#
# Default mode is assistant-only. -AutomateClicks never claims in-game control.
param(
    [ValidateSet("Host", "Guest")]
    [string]$Role = "Guest",

    [int]$PollSeconds = 5,

    [switch]$SkipHamachiLaunch,

    # Optional known peer to ping (e.g. host's Hamachi 25.x.x.x)
    [string]$HostIp = "",

    # Opt-in: open a Notepad checklist when peers look ready.
    # Does NOT send controller input into ACNH. May miss menus if you extend it.
    [switch]$AutomateClicks,

    # Re-print join steps when an emulator process appears
    [bool]$WatchEmulator = $true
)

$ErrorActionPreference = "Continue"
$script:AnnouncedPeers = $false
$script:AnnouncedEmulator = $false
$script:ChecklistPath = Join-Path $env:TEMP "fwf-orville-join-checklist.txt"

function Get-HamachiExe {
    @(
        "${env:ProgramFiles(x86)}\LogMeIn Hamachi\hamachi-2-ui.exe",
        "$env:ProgramFiles\LogMeIn Hamachi\hamachi-2-ui.exe",
        "${env:ProgramFiles(x86)}\LogMeIn Hamachi\x64\hamachi-2.exe",
        "$env:ProgramFiles\LogMeIn Hamachi\x64\hamachi-2.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
}

function Test-HamachiProcess {
    [bool](Get-Process -Name "hamachi-2","hamachi-2-ui" -ErrorAction SilentlyContinue)
}

function Get-HamachiAdapter {
    Get-NetAdapter -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match 'Hamachi|LogMeIn' } |
        Select-Object -First 1
}

function Get-HamachiLocalIp {
    Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.InterfaceAlias -match 'Hamachi|LogMeIn' -and $_.IPAddress -like '25.*' } |
        Select-Object -ExpandProperty IPAddress -First 1
}

function Get-HamachiPeerIps {
    $local = Get-HamachiLocalIp
    Get-NetNeighbor -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -like '25.*' -and
            $_.IPAddress -notlike '25.255.*' -and
            $_.IPAddress -ne '25.0.0.1' -and
            ($null -eq $local -or $_.IPAddress -ne $local) -and
            $_.State -in @('Reachable', 'Stale', 'Delay', 'Probe', 'Permanent')
        } |
        Select-Object -ExpandProperty IPAddress -Unique
}

function Test-PeerReachable {
    param([string]$Ip)
    if (-not $Ip) { return $false }
    try {
        # ping.exe for Windows PowerShell 5.1 compatibility
        $null = & ping.exe -n 1 -w 1500 $Ip 2>$null
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function Get-EmulatorProcess {
    $names = @('yuzu', 'yuzu-cmd', 'sudachi', 'suyu', 'citron', 'ryujinx', 'Ryujinx')
    Get-Process -ErrorAction SilentlyContinue |
        Where-Object {
            $n = $_.ProcessName
            ($names -contains $n) -or ($n -match '^(yuzu|sudachi|suyu|citron|ryujinx)')
        } |
        Select-Object -First 1
}

function Write-HonestLimits {
    Write-Host ""
    Write-Host "HONEST LIMITS (read once):" -ForegroundColor Yellow
    Write-Host "  - This script cannot teleport you to Orville or auto-join LDN."
    Write-Host "  - LayeredFS / EventFlow cannot silently inject joins on ACNH 1.0."
    Write-Host "  - Full EventFlow / OpeningMovie packs black-screen this 1.0 install - do not reinstall them."
    Write-Host "  - True auto-path would need controller automation (fragile) or RE hooks (not shipping)."
    Write-Host "  - Default is assistant-only. -AutomateClicks only opens a checklist window."
    Write-Host ""
}

function Show-GuestOrvilleSteps {
    param([switch]$Loud)
    $color = if ($Loud) { "Green" } else { "Cyan" }
    Write-Host ""
    Write-Host "========================================" -ForegroundColor $color
    Write-Host " HOST GATE LOOKS READY - DO THIS NOW" -ForegroundColor $color
    Write-Host "========================================" -ForegroundColor $color
    Write-Host "  1. Focus the emulator (ACNH must already be in-game, not title-only)."
    Write-Host "  2. Walk to the airport / talk to Orville."
    Write-Host "  3. Choose fly / visit -> Via local play."
    Write-Host "  4. Pick the host island when the list appears."
    Write-Host ""
    Write-Host "  Emulator: Multiplayer = ldn_mitm | Guest Internet = OFF"
    Write-Host "  Same ACNH 1.0 + FreedomWithFriends on every PC."
    Write-Host "========================================" -ForegroundColor $color
    Write-Host ""
}

function Show-HostOrvilleSteps {
    Write-Host ""
    Write-Host "HOST - in-game:" -ForegroundColor Cyan
    Write-Host "  1. Airport -> talk to Orville"
    Write-Host "  2. Invite / I want visitors -> Via local play"
    Write-Host "  3. Tell guests the gate is open (they run Guest mode of this script)"
    Write-Host ""
}

function Write-ChecklistFile {
    param([string]$RoleName)
    $lines = @(
        "Freedom with Friends - Orville join checklist ($RoleName)",
        "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
        "",
        "THIS IS NOT AN IN-GAME TELEPORT.",
        "LayeredFS cannot auto-send you to Orville or inject LDN joins.",
        "",
        "Guest steps when Hamachi peers are online / host says gate is open:",
        "  1. Focus emulator (ACNH already loaded into the island).",
        "  2. Walk to airport -> talk to Orville.",
        "  3. Fly / visit -> Via local play.",
        "  4. Select the host island.",
        "",
        "Emulator: ldn_mitm, Guest Internet OFF, matching 1.0 + mod.",
        "Do NOT install full Tutorial Skip / OpeningMovie EventFlow packs (black screen)."
    )
    Set-Content -Path $script:ChecklistPath -Value $lines -Encoding UTF8
    return $script:ChecklistPath
}

function Invoke-OptionalChecklistUi {
    param([string]$RoleName)
    if (-not $AutomateClicks) { return }

    Write-Host ""
    Write-Host "WARNING: -AutomateClicks is opt-in UI only." -ForegroundColor Yellow
    Write-Host "  It opens Notepad with the checklist. It does NOT press in-game buttons."
    Write-Host "  Any future click automation may miss menus - do not trust it blindly."
    Write-Host ""

    $path = Write-ChecklistFile -RoleName $RoleName
    try {
        Start-Process notepad.exe -ArgumentList $path | Out-Null
        Start-Sleep -Milliseconds 800
        $np = Get-Process notepad -ErrorAction SilentlyContinue |
            Sort-Object StartTime -Descending |
            Select-Object -First 1
        if ($np -and $np.MainWindowHandle -ne [IntPtr]::Zero) {
            if (-not ("FwfNative" -as [type])) {
                Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class FwfNative {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
}
'@
            }
            [void][FwfNative]::SetForegroundWindow($np.MainWindowHandle)
        }
    } catch {
        Write-Host ("Could not open checklist UI: {0}" -f $_.Exception.Message)
        Write-Host ("Checklist file: {0}" -f $path)
    }
}

function Initialize-HamachiReady {
    if ($SkipHamachiLaunch) {
        if (-not (Test-HamachiProcess)) {
            Write-Host "Hamachi is not running and -SkipHamachiLaunch was set." -ForegroundColor Red
            exit 1
        }
        return
    }

    $hamachi = Get-HamachiExe
    if (-not $hamachi) {
        Write-Host "Hamachi not installed. Get it from https://www.vpn.net/" -ForegroundColor Red
        exit 1
    }

    if (-not (Test-HamachiProcess)) {
        Write-Host "Starting Hamachi..."
        Start-Process $hamachi
        Start-Sleep -Seconds 4
    } else {
        Write-Host "Hamachi process is running."
    }

    $adapter = Get-HamachiAdapter
    if (-not $adapter) {
        Write-Host "Hamachi adapter not found. Open Hamachi UI and go Online." -ForegroundColor Yellow
    } elseif ($adapter.Status -ne 'Up') {
        Write-Host ("Hamachi adapter status: {0}. Power it On in Hamachi." -f $adapter.Status) -ForegroundColor Yellow
    } else {
        Write-Host "Hamachi adapter is Up."
    }

    $ip = Get-HamachiLocalIp
    if ($ip) {
        Write-Host ("Your Hamachi IPv4: {0}" -f $ip)
    } else {
        Write-Host "No 25.x Hamachi IP yet - join/create the shared network and go Online." -ForegroundColor Yellow
    }
}

# --- main ---
Write-Host ""
Write-Host "=== Freedom with Friends - Hamachi join helper ==="
Write-Host ("Role: {0} | Poll: {1}s | AutomateClicks: {2}" -f $Role, $PollSeconds, $AutomateClicks)
Write-HonestLimits
Initialize-HamachiReady

Write-Host ""
Write-Host "Emulator checklist:"
Write-Host "  - Multiplayer / LDN mode = ldn_mitm (or your fork's LAN LDN)"
Write-Host "  - Guest Internet Access = OFF"
Write-Host "  - Same ACNH 1.0 + FreedomWithFriends on every PC"
Write-Host "  - Do NOT mix full Tutorial Skip / OpeningMovie EventFlow packs"
Write-Host ""

if ($HostIp) {
    Write-Host ("Will ping -HostIp {0} each poll." -f $HostIp)
}

if ($Role -eq "Host") {
    Show-HostOrvilleSteps
    if ($AutomateClicks) { Invoke-OptionalChecklistUi -RoleName "Host" }

    Write-Host "Watching Hamachi (Ctrl+C to stop)..."
    while ($true) {
        $procOk = Test-HamachiProcess
        $ip = Get-HamachiLocalIp
        $peers = @(Get-HamachiPeerIps)
        $stamp = Get-Date -Format "HH:mm:ss"

        if (-not $procOk) {
            Write-Host ("[{0}] Hamachi not running - restart it." -f $stamp) -ForegroundColor Red
        } elseif (-not $ip) {
            Write-Host ("[{0}] Hamachi up but no 25.x IP - go Online / join network." -f $stamp) -ForegroundColor Yellow
        } else {
            if ($peers.Count) {
                $peerText = $peers -join ", "
            } else {
                $peerText = "(none seen yet - guests joining will appear here)"
            }
            Write-Host ("[{0}] Online as {1} - peers: {2} - keep local-play gate open." -f $stamp, $ip, $peerText)
        }

        if ($WatchEmulator) {
            $emu = Get-EmulatorProcess
            if ($emu -and -not $script:AnnouncedEmulator) {
                Write-Host ("[{0}] Emulator detected: {1} - open Orville invite -> Via local play." -f $stamp, $emu.ProcessName) -ForegroundColor Cyan
                $script:AnnouncedEmulator = $true
            } elseif (-not $emu) {
                $script:AnnouncedEmulator = $false
            }
        }

        Start-Sleep -Seconds $PollSeconds
    }
}
else {
    Write-Host "GUEST - waiting for Hamachi peers (host on same network)..." -ForegroundColor Cyan
    Write-Host "When peers appear (or -HostIp responds), you will get loud Orville steps."
    Write-Host "You still must walk to Orville yourself."
    Write-Host ""

    while ($true) {
        $procOk = Test-HamachiProcess
        $ip = Get-HamachiLocalIp
        $peers = @(Get-HamachiPeerIps)
        if ($HostIp) {
            $hostOk = Test-PeerReachable -Ip $HostIp
        } else {
            $hostOk = $false
        }
        $ready = ($peers.Count -gt 0) -or $hostOk
        $stamp = Get-Date -Format "HH:mm:ss"

        if (-not $procOk) {
            Write-Host ("[{0}] Hamachi not running - restart it." -f $stamp) -ForegroundColor Red
            $script:AnnouncedPeers = $false
        } elseif (-not $ip) {
            Write-Host ("[{0}] No Hamachi 25.x IP - join the same network as the host and go Online." -f $stamp) -ForegroundColor Yellow
            $script:AnnouncedPeers = $false
        } elseif (-not $ready) {
            Write-Host ("[{0}] Connected as {1} - waiting for peers on the Hamachi network..." -f $stamp, $ip)
            $script:AnnouncedPeers = $false
        } else {
            $detailParts = @()
            if ($peers.Count) {
                $detailParts += ("peers: {0}" -f ($peers -join ", "))
            }
            if ($HostIp) {
                $detailParts += ("HostIp {0} reachable={1}" -f $HostIp, $hostOk)
            }
            $detailText = $detailParts -join "; "
            Write-Host ("[{0}] Hamachi peers online ({1})." -f $stamp, $detailText) -ForegroundColor Green

            if (-not $script:AnnouncedPeers) {
                Show-GuestOrvilleSteps -Loud
                if ($AutomateClicks) { Invoke-OptionalChecklistUi -RoleName "Guest" }
                $script:AnnouncedPeers = $true
            } else {
                Write-Host ("[{0}] Reminder: Orville -> Via local play -> pick host island." -f $stamp)
            }
        }

        if ($WatchEmulator) {
            $emu = Get-EmulatorProcess
            if ($emu -and -not $script:AnnouncedEmulator) {
                Write-Host ("[{0}] Emulator window/process detected: {1}" -f $stamp, $emu.ProcessName) -ForegroundColor Cyan
                if ($ready) {
                    Write-Host "         Host peers look online - go to Orville NOW (script cannot teleport you)." -ForegroundColor Cyan
                    Show-GuestOrvilleSteps
                } else {
                    Write-Host "         Keep ACNH loaded; waiting for Hamachi peers before join reminder."
                }
                $script:AnnouncedEmulator = $true
            } elseif (-not $emu) {
                $script:AnnouncedEmulator = $false
            }
        }

        Start-Sleep -Seconds $PollSeconds
    }
}
