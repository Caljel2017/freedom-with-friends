# Freedom with Friends

Yuzu / Ryujinx mod pack for **Animal Crossing: New Horizons**.

**Title ID:** `01006F8002326000`  
**1.0.0 Build ID:** `7FC1BAFF976AECA4`  
**Default mode:** **save-unlock 1.0** + in-game Minus **Test** menu (`System_GameClose` + `TalkSys_USen` — not Tutorial Skip / not airport pack)

## Status

| Feature | Status |
|---|---|
| Boot-safe on 1.0.0 | Test after install; if black screen, remove `romfs/EventFlow` and `romfs/Message` (see docs) |
| Save anytime (tutorial/prologue) | **On** — Minus → **Save and end** |
| Minus → **Test** submenu | **On** — Status / Tips (TalkSys overlay) |
| Prologue / getaway skip | **Off forever** (full Tutorial Skip black-screens 1.0) |
| Fly anytime via Orville | **Off** — airport pack black-screened; backup only |
| Silent auto-join on boot | **Impossible** (LayeredFS cannot skip Orville) |
| Auto-teleport to Orville / auto LDN join | **Impossible** via LayeredFS; use Hamachi guest assistant instead |
| Visitor terraform / shared owner | Disabled exefs stub only |
| Cheats slot 1.0.0 | Slot only — no verified save-unlock cheat |
| LAN / ldn_mitm / Hamachi | `docs/CONNECTIVITY.md`, `scripts/Setup-Connectivity.ps1` |

## Install

```powershell
.\scripts\Build-SaveUnlock.ps1 -InstallYuzu
# or if already built:
.\install\Install-Yuzu.ps1
```

## In-game: controller Minus → Test

1. Enable the **FreedomWithFriends** mod in Yuzu for ACNH 1.0.
2. Load the game until you can move the player.
3. Press the **Nintendo Switch controller Minus (−)** button (not Windows Ctrl+-).
4. Choose **Test**.
5. Submenu: **Status** or **Tips**
6. From the same Minus menu, **Save and end.** still works during prologue.

Exact path (normal stages): **Minus (−)** → **Ready to wrap things up for now?** → **Test.** → **FwF test menu** → **Status** | **Tips**

On mystery tour / photo studio: **Minus (−)** → … → **Test.** (first) | **Save and end.**

## Rollback (black screen)

1. Delete `%APPDATA%\yuzu\load\01006F8002326000\FreedomWithFriends\romfs\EventFlow\System_GameClose.bfevfl`
2. Delete `%APPDATA%\yuzu\load\01006F8002326000\FreedomWithFriends\romfs\Message` (TalkSys overlay)
3. Or delete the whole `romfs\EventFlow` / `romfs\Message` folders under that mod
4. Restart Yuzu / reload the game

## Hamachi join

1. For friends: Hamachi + ldn_mitm, then Orville → **Via local play** (vanilla Orville gates still apply until a safe fly unlock exists).

```powershell
.\scripts\AutoJoin-HamachiHost.ps1 -Role Host
.\scripts\AutoJoin-HamachiHost.ps1 -Role Guest
```

Details: [`docs/WHY_NO_EVENTFLOW.md`](docs/WHY_NO_EVENTFLOW.md), [`docs/CONNECTIVITY.md`](docs/CONNECTIVITY.md).

## Optional Windows fallback

If you need an external checklist without touching romFS UI:

```powershell
.\scripts\Start-ModTestMenu.ps1 -ShowNow
```

Controller Minus → Test is the intended path; the PowerShell helper is optional only.

## Do not install full Tutorial Skip

```powershell
# AVOID on pure 1.0 — black screen + grass flash:
# .\scripts\Build-FromRomfs.ps1 -FromTutorialSkipRelease
```

## Credits

Prologue EventFlow patterns adapted from ShrineFox **ACNH Tutorial Skip** v0.2 (not shipped as that pack).
