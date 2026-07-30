# Setup checklist: ldn_mitm + optional Hamachi for Freedom with Friends
param(
    [ValidateSet("SameLAN", "Hamachi", "RyuLDN")]
    [string]$Mode = "Hamachi"
)

Write-Host ""
Write-Host "=== Freedom with Friends — multiplayer connectivity ==="
Write-Host "In-game path is always: Dodo Airlines -> Via local play"
Write-Host "ACNH has no separate LAN menu; ldn_mitm/Hamachi carry local play."
Write-Host ""

switch ($Mode) {
    "SameLAN" {
        Write-Host "Mode: Same Wi-Fi / Ethernet"
        Write-Host "1. Ryujinx -> Settings -> Network/Multiplayer -> Mode = ldn_mitm"
        Write-Host "2. Guest Internet Access = OFF"
        Write-Host "3. Host: Orville -> I want visitors -> Via local play"
        Write-Host "4. Guests: Orville -> I wanna fly -> Via local play"
        Write-Host "5. Allow Windows Firewall for Ryujinx when prompted"
    }
    "Hamachi" {
        Write-Host "Mode: Hamachi (or Radmin / ZeroTier) virtual LAN"
        Write-Host "1. Install Hamachi on every PC; join the SAME network; all Online"
        Write-Host "2. Connect Hamachi BEFORE starting the emulator"
        Write-Host "3. Ryujinx -> Network/Multiplayer -> Mode = ldn_mitm"
        Write-Host "4. Guest Internet Access = OFF"
        Write-Host "5. Host opens Via local play; guests join Via local play"
        Write-Host "6. Firewall: allow Hamachi + Ryujinx"
        $hamachi = @(
            "${env:ProgramFiles(x86)}\LogMeIn Hamachi\hamachi-2.exe",
            "$env:ProgramFiles\LogMeIn Hamachi\hamachi-2.exe"
        ) | Where-Object { Test-Path $_ } | Select-Object -First 1
        if ($hamachi) {
            Write-Host ""
            Write-Host "Hamachi found: $hamachi"
            Write-Host "Launching Hamachi..."
            Start-Process $hamachi
        } else {
            Write-Host ""
            Write-Host "Hamachi not detected. Install from https://www.vpn.net/ then re-run."
        }
    }
    "RyuLDN" {
        Write-Host "Mode: Ryujinx public LDN (RyuLDN)"
        Write-Host "1. Use an LDN-capable Ryujinx build"
        Write-Host "2. Network mode = RyuLDN / Ryujinx LDN (not ldn_mitm)"
        Write-Host "3. Still use Via local play inside ACNH"
        Write-Host "4. Same game version + same Freedom with Friends pack for all"
    }
}

Write-Host ""
Write-Host "Everyone needs matching ACNH version + this mod."
Write-Host "Full write-up: docs\CONNECTIVITY.md"
Write-Host ""
