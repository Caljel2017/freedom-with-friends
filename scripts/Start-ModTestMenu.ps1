# Freedom with Friends - external Test menu (Windows helper, OPTIONAL)
#
# INTENDED PATH (in-game):
#   Controller Minus (-) -> Test -> Status / Tips
#   (System_GameClose + TalkSys_USen). Prefer that over this script.
#
# WHY THIS STILL EXISTS:
#   Fallback checklist if EventFlow/Message overlays black-screen, or for
#   verifying the Yuzu mod folder from Windows without entering the game.
#
# USAGE:
#   .\scripts\Start-ModTestMenu.ps1 -ShowNow
#   .\scripts\Start-ModTestMenu.ps1 -Hotkey CtrlOemMinus
#   .\scripts\Start-ModTestMenu.ps1 -Hotkey F9
#   .\scripts\Start-ModTestMenu.ps1 -Console

param(
    [ValidateSet("OemMinus", "CtrlOemMinus", "F9", "F10")]
    [string]$Hotkey = "CtrlOemMinus",

    # Open the Test menu once and exit (no background listener)
    [switch]$ShowNow,

    # Text-only menus (useful over SSH / without STA GUI)
    [switch]$Console,

    [string]$TitleId = "01006F8002326000",
    [string]$ModName = "FreedomWithFriends",

    # Emulator process names that count as "focused"
    [string[]]$EmulatorProcessNames = @(
        "yuzu", "yuzu-cmd", "suyu", "sudachi", "citron", "ryujinx"
    )
)

$ErrorActionPreference = "Continue"
$RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$DocsRoot = Join-Path $RepoRoot "docs"

# --- Win32 helpers (focus + key state) ---------------------------------------

$Win32 = @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public static class FwfNative {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    public const int VK_OEM_MINUS = 0xBD;
    public const int VK_SUBTRACT  = 0x6D;
    public const int VK_CONTROL   = 0x11;
    public const int VK_F9        = 0x78;
    public const int VK_F10       = 0x79;
}
"@

try {
    Add-Type -TypeDefinition $Win32 -ErrorAction Stop | Out-Null
} catch {
    # Type already loaded in this session
}

function Get-YuzuModPath {
    $candidates = @(
        (Join-Path $env:APPDATA "yuzu\load\$TitleId\$ModName"),
        (Join-Path $env:APPDATA "suyu\load\$TitleId\$ModName"),
        (Join-Path $env:APPDATA "sudachi\load\$TitleId\$ModName"),
        (Join-Path $env:APPDATA "citron\load\$TitleId\$ModName")
    )
    foreach ($p in $candidates) {
        if (Test-Path $p) { return $p }
    }
    return $candidates[0]
}

function Test-EmulatorFocused {
    $hwnd = [FwfNative]::GetForegroundWindow()
    if ($hwnd -eq [IntPtr]::Zero) { return $false }
    $procId = 0
    [void][FwfNative]::GetWindowThreadProcessId($hwnd, [ref]$procId)
    if ($procId -eq 0) { return $false }
    try {
        $p = Get-Process -Id $procId -ErrorAction Stop
        $name = $p.ProcessName.ToLowerInvariant()
        return ($EmulatorProcessNames | ForEach-Object { $_.ToLowerInvariant() }) -contains $name
    } catch {
        return $false
    }
}

function Test-HotkeyPressed {
    param([string]$Name)
    switch ($Name) {
        "OemMinus" {
            $oem = ([FwfNative]::GetAsyncKeyState([FwfNative]::VK_OEM_MINUS) -band 0x8000) -ne 0
            $num = ([FwfNative]::GetAsyncKeyState([FwfNative]::VK_SUBTRACT) -band 0x8000) -ne 0
            return ($oem -or $num)
        }
        "CtrlOemMinus" {
            $ctrl = ([FwfNative]::GetAsyncKeyState([FwfNative]::VK_CONTROL) -band 0x8000) -ne 0
            $oem = ([FwfNative]::GetAsyncKeyState([FwfNative]::VK_OEM_MINUS) -band 0x8000) -ne 0
            $num = ([FwfNative]::GetAsyncKeyState([FwfNative]::VK_SUBTRACT) -band 0x8000) -ne 0
            return ($ctrl -and ($oem -or $num))
        }
        "F9"  { return (([FwfNative]::GetAsyncKeyState([FwfNative]::VK_F9) -band 0x8000) -ne 0) }
        "F10" { return (([FwfNative]::GetAsyncKeyState([FwfNative]::VK_F10) -band 0x8000) -ne 0) }
        default { return $false }
    }
}

# --- Actions -----------------------------------------------------------------

function Invoke-CheckHamachi {
    Write-Host ""
    Write-Host "=== Hamachi / AutoJoin ===" -ForegroundColor Cyan
    $autoJoin = Join-Path $PSScriptRoot "AutoJoin-HamachiHost.ps1"
    if (-not (Test-Path $autoJoin)) {
        Write-Host "Missing: $autoJoin" -ForegroundColor Red
        return
    }

    Write-Host "1) Quick peer check (this window)"
    Write-Host "2) Launch AutoJoin as Guest"
    Write-Host "3) Launch AutoJoin as Host"
    Write-Host "4) Cancel"
    $c = Read-Host "Choice"
    switch ($c) {
        "1" {
            & $autoJoin -Role Guest -PollSeconds 3 -WatchEmulator:$false -SkipHamachiLaunch
        }
        "2" {
            Start-Process powershell -ArgumentList @(
                "-NoExit", "-ExecutionPolicy", "Bypass", "-File", $autoJoin, "-Role", "Guest"
            )
            Write-Host "Started AutoJoin Guest in a new window."
        }
        "3" {
            Start-Process powershell -ArgumentList @(
                "-NoExit", "-ExecutionPolicy", "Bypass", "-File", $autoJoin, "-Role", "Host"
            )
            Write-Host "Started AutoJoin Host in a new window."
        }
        default { Write-Host "Cancelled." }
    }
}

function Invoke-VerifyModFolder {
    Write-Host ""
    Write-Host "=== Verify Yuzu mod folder ===" -ForegroundColor Cyan
    $mod = Get-YuzuModPath
    Write-Host "Path: $mod"
    if (-not (Test-Path $mod)) {
        Write-Host "WARNING: Mod folder not found. Run install\Install-Yuzu.ps1 first." -ForegroundColor Yellow
        return
    }

    $eventFlowDir = Join-Path $mod "romfs\EventFlow"
    $bfevfl = @()
    if (Test-Path $eventFlowDir) {
        $bfevfl = @(Get-ChildItem -Path $eventFlowDir -Filter "*.bfevfl" -File -ErrorAction SilentlyContinue)
    }

    Write-Host "EventFlow .bfevfl count: $($bfevfl.Count)"
    if ($bfevfl.Count -gt 0) {
        Write-Host "WARNING: .bfevfl file(s) present. Extra EventFlow overlays have black-screened 1.0 before." -ForegroundColor Yellow
        $bfevfl | ForEach-Object { Write-Host "  - $($_.Name)" }
        $names = @($bfevfl | ForEach-Object { $_.Name })
        $onlySaveUnlock = ($bfevfl.Count -eq 1 -and $names -contains "System_GameClose.bfevfl")
        if ($onlySaveUnlock) {
            Write-Host "Note: System_GameClose alone is the documented save-unlock file (Minus -> Save)." -ForegroundColor DarkYellow
        } else {
            Write-Host "If you black-screen on boot, delete romfs\EventFlow (and optional RSTB)." -ForegroundColor Yellow
            Write-Host "Do not reinstall multi-file airport / Tutorial Skip packs." -ForegroundColor Yellow
        }
    } else {
        Write-Host "OK: no .bfevfl files (safe shell / no EventFlow pack)." -ForegroundColor Green
    }

    $rstb = Join-Path $mod "romfs\System\Resource\ResourceSizeTable.srsizetable"
    if (Test-Path $rstb) {
        $len = (Get-Item $rstb).Length
        Write-Host "RSTB present ($len bytes)."
    } else {
        Write-Host "RSTB: not present."
    }

    $exefs = Join-Path $mod "exefs"
    if (Test-Path $exefs) {
        Get-ChildItem $exefs -File -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "exefs: $($_.Name)"
        }
    }

    $readme = Join-Path $mod "README.txt"
    if (Test-Path $readme) {
        Write-Host ""
        Write-Host "--- mod README.txt (first 12 lines) ---"
        Get-Content $readme -TotalCount 12
    }
}

function Invoke-OpenDocs {
    Write-Host ""
    Write-Host "=== Open docs ===" -ForegroundColor Cyan
    $docs = @(
        @{ Key = "1"; Name = "CONNECTIVITY.md"; Path = (Join-Path $DocsRoot "CONNECTIVITY.md") },
        @{ Key = "2"; Name = "WHY_NO_EVENTFLOW.md"; Path = (Join-Path $DocsRoot "WHY_NO_EVENTFLOW.md") },
        @{ Key = "3"; Name = "SHARED_OWNER.md"; Path = (Join-Path $DocsRoot "SHARED_OWNER.md") },
        @{ Key = "4"; Name = "All three"; Path = $null }
    )
    foreach ($d in $docs) {
        Write-Host "$($d.Key)) $($d.Name)"
    }
    Write-Host "5) Cancel"
    $c = Read-Host "Choice"
    $toOpen = @()
    switch ($c) {
        "1" { $toOpen = @($docs[0].Path) }
        "2" { $toOpen = @($docs[1].Path) }
        "3" { $toOpen = @($docs[2].Path) }
        "4" { $toOpen = @($docs[0].Path, $docs[1].Path, $docs[2].Path) }
        default { Write-Host "Cancelled."; return }
    }
    foreach ($p in $toOpen) {
        if (Test-Path $p) {
            Start-Process $p
            Write-Host "Opened: $p"
        } else {
            Write-Host "Missing: $p" -ForegroundColor Yellow
        }
    }
}

function Invoke-ClearRebuildReminders {
    Write-Host ""
    Write-Host "=== Clear / rebuild reminders ===" -ForegroundColor Cyan
    Write-Host @"
If ACNH black-screens on load:
  1. Delete: %APPDATA%\yuzu\load\$TitleId\$ModName\romfs\EventFlow
  2. Optional: delete romfs\System\Resource\ResourceSizeTable.srsizetable
  3. Leave cheats / disabled exefs stub alone
  4. Do NOT reinstall multi-file airport packs or full Tutorial Skip

Safe shell rebuild / reinstall:
  .\install\Install-Yuzu.ps1

Connectivity setup:
  .\scripts\Setup-Connectivity.ps1 -Mode Hamachi

Hamachi join assistant:
  .\scripts\AutoJoin-HamachiHost.ps1 -Role Guest

In-game native Minus menu with a "Test" entry:
  Would need Layout + EventFlow overlays - not installed by default (1.0 black screens).
  Use this Windows helper instead.
"@
    $mod = Get-YuzuModPath
    Write-Host "Current mod path: $mod"
    if (Test-Path $mod) {
        $open = Read-Host "Open mod folder in Explorer? (y/N)"
        if ($open -match '^[Yy]') {
            Start-Process explorer.exe $mod
        }
    }
}

function Invoke-FutureStub {
    param([string]$Name)
    Write-Host ""
    Write-Host "Stub: $Name" -ForegroundColor DarkGray
    Write-Host "Not implemented yet - reserved for future Freedom with Friends tests."
}

function Show-TestSubmenuConsole {
    while ($true) {
        Write-Host ""
        Write-Host "Freedom with Friends - Test" -ForegroundColor Green
        Write-Host "  1) Check Hamachi peers / run AutoJoin helper"
        Write-Host "  2) Verify Yuzu mod folder (EventFlow count)"
        Write-Host "  3) Open docs (CONNECTIVITY / WHY_NO_EVENTFLOW / SHARED_OWNER)"
        Write-Host "  4) Clear / rebuild reminders"
        Write-Host "  5) [Future] Fly / gate smoke test stub"
        Write-Host "  6) [Future] Save-slot sanity stub"
        Write-Host "  0) Back"
        $c = Read-Host "Choice"
        switch ($c) {
            "1" { Invoke-CheckHamachi }
            "2" { Invoke-VerifyModFolder }
            "3" { Invoke-OpenDocs }
            "4" { Invoke-ClearRebuildReminders }
            "5" { Invoke-FutureStub "Fly / gate smoke test" }
            "6" { Invoke-FutureStub "Save-slot sanity" }
            "0" { return }
            default { Write-Host "Unknown choice." }
        }
    }
}

function Show-RootMenuConsole {
    while ($true) {
        Write-Host ""
        Write-Host "Freedom with Friends" -ForegroundColor Green
        Write-Host "  1) Test"
        Write-Host "  0) Exit"
        $c = Read-Host "Choice"
        switch ($c) {
            "1" { Show-TestSubmenuConsole }
            "0" { return }
            default { Write-Host "Unknown choice." }
        }
    }
}

function Show-GuiMenus {
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    Add-Type -AssemblyName System.Drawing | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()

    function Show-TestForm {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Freedom with Friends - Test"
        $form.Size = New-Object System.Drawing.Size(460, 340)
        $form.StartPosition = "CenterScreen"
        $form.TopMost = $true
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false

        $label = New-Object System.Windows.Forms.Label
        $label.Text = "Choose a test / helper action:"
        $label.Location = New-Object System.Drawing.Point(16, 14)
        $label.Size = New-Object System.Drawing.Size(410, 22)
        $form.Controls.Add($label)

        $list = New-Object System.Windows.Forms.ListBox
        $list.Location = New-Object System.Drawing.Point(16, 42)
        $list.Size = New-Object System.Drawing.Size(410, 200)
        $list.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        [void]$list.Items.Add("Check Hamachi peers / run AutoJoin helper")
        [void]$list.Items.Add("Verify Yuzu mod folder (EventFlow count)")
        [void]$list.Items.Add("Open docs (CONNECTIVITY / WHY_NO_EVENTFLOW / SHARED_OWNER)")
        [void]$list.Items.Add("Clear / rebuild reminders")
        [void]$list.Items.Add("[Future] Fly / gate smoke test stub")
        [void]$list.Items.Add("[Future] Save-slot sanity stub")
        $list.SelectedIndex = 0
        $form.Controls.Add($list)

        $ok = New-Object System.Windows.Forms.Button
        $ok.Text = "Run"
        $ok.Location = New-Object System.Drawing.Point(230, 255)
        $ok.Size = New-Object System.Drawing.Size(90, 30)
        $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $ok
        $form.Controls.Add($ok)

        $cancel = New-Object System.Windows.Forms.Button
        $cancel.Text = "Back"
        $cancel.Location = New-Object System.Drawing.Point(336, 255)
        $cancel.Size = New-Object System.Drawing.Size(90, 30)
        $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.CancelButton = $cancel
        $form.Controls.Add($cancel)

        $result = $form.ShowDialog()
        $idx = $list.SelectedIndex
        $form.Dispose()
        if ($result -ne [System.Windows.Forms.DialogResult]::OK) { return }

        switch ($idx) {
            0 { Invoke-CheckHamachi }
            1 { Invoke-VerifyModFolder }
            2 { Invoke-OpenDocs }
            3 { Invoke-ClearRebuildReminders }
            4 { Invoke-FutureStub "Fly / gate smoke test" }
            5 { Invoke-FutureStub "Save-slot sanity" }
        }
        Write-Host ""
        Write-Host "Press Enter to return to the menu..." -ForegroundColor DarkGray
        [void](Read-Host)
    }

    function Show-RootForm {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Freedom with Friends"
        $form.Size = New-Object System.Drawing.Size(420, 220)
        $form.StartPosition = "CenterScreen"
        $form.TopMost = $true
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false

        $label = New-Object System.Windows.Forms.Label
        $label.Text = "Minus helper menu (external - not in-game EventFlow UI)"
        $label.Location = New-Object System.Drawing.Point(16, 16)
        $label.Size = New-Object System.Drawing.Size(370, 40)
        $form.Controls.Add($label)

        $list = New-Object System.Windows.Forms.ListBox
        $list.Location = New-Object System.Drawing.Point(16, 60)
        $list.Size = New-Object System.Drawing.Size(370, 60)
        $list.Font = New-Object System.Drawing.Font("Segoe UI", 11)
        [void]$list.Items.Add("Test")
        $list.SelectedIndex = 0
        $form.Controls.Add($list)

        $ok = New-Object System.Windows.Forms.Button
        $ok.Text = "Open"
        $ok.Location = New-Object System.Drawing.Point(196, 135)
        $ok.Size = New-Object System.Drawing.Size(90, 30)
        $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $ok
        $form.Controls.Add($ok)

        $cancel = New-Object System.Windows.Forms.Button
        $cancel.Text = "Close"
        $cancel.Location = New-Object System.Drawing.Point(296, 135)
        $cancel.Size = New-Object System.Drawing.Size(90, 30)
        $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.CancelButton = $cancel
        $form.Controls.Add($cancel)

        $result = $form.ShowDialog()
        $form.Dispose()
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            Show-TestForm
        }
    }

    Show-RootForm
}

function Show-Menus {
    if ($Console) {
        Show-RootMenuConsole
    } else {
        try {
            Show-GuiMenus
        } catch {
            Write-Host "GUI unavailable ($($_.Exception.Message)); falling back to console." -ForegroundColor Yellow
            Show-RootMenuConsole
        }
    }
}

# --- Entry -------------------------------------------------------------------

Write-Host ""
Write-Host "Freedom with Friends - Test menu helper" -ForegroundColor Green
Write-Host "Repo: $RepoRoot"
Write-Host "Mod:  $(Get-YuzuModPath)"
Write-Host ""
Write-Host "NOTE: An in-game Minus -> Test entry would need Layout/EventFlow and is" -ForegroundColor DarkYellow
Write-Host "      NOT installed (black-screens 1.0). This is the safe external menu." -ForegroundColor DarkYellow
Write-Host ""

if ($ShowNow) {
    Show-Menus
    return
}

Write-Host "Listening for hotkey [$Hotkey] while Yuzu/emulator is focused."
Write-Host "  OemMinus      = - key (may also open in-game Save if that pack is installed)"
Write-Host "  CtrlOemMinus  = Ctrl + - (recommended if Minus is used for Save)"
Write-Host "  F9 / F10      = function keys"
Write-Host "Press Ctrl+C in this window to stop."
Write-Host ""

$wasDown = $false
try {
    while ($true) {
        $down = Test-HotkeyPressed -Name $Hotkey
        if ($down -and -not $wasDown) {
            if (Test-EmulatorFocused) {
                Write-Host ("[{0}] Hotkey - opening menu..." -f (Get-Date -Format "HH:mm:ss"))
                Show-Menus
                Write-Host "Listening again for [$Hotkey]..."
            }
        }
        $wasDown = $down
        Start-Sleep -Milliseconds 80
    }
} finally {
    Write-Host "Stopped."
}
