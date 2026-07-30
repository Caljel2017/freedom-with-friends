# Why EventFlow on ACNH 1.0 must stay minimal

## Black screen lesson

Installing the **full Tutorial Skip / prologue EventFlow pack** or the **5-file airport pack** on this 1.0.0 install caused: black screen (+ grass flash). Those packs must never be the default.

## What is installed now

Rebuilt from **your** `tools/romfs_dump_1.0` dump:

| File | Change |
|---|---|
| `System_GameClose` | Save-unlock in prologue + Minus → **Test** submenu |
| `TalkSys_USen.sarc.zs` | English labels: Test / Mod status / Hamachi tip (+ tip sheet text) |

Sources: `source/eventflow_1.0_save_unlock/`, message patch in `tools/_decompile_tmp/patch_closemenu_msbt.py`  
Built binaries: `build/eventflow_1.0_save_unlock/`, `build/message_1.0_testmenu/`  
Vanilla EventFlow backup: `tools/save_unlock_vanilla_backup/`

## Ready next (not installed)

| File | Change |
|---|---|
| `SNPC_dod_01_Airport_NormalSeq` | Unlock Orville fly/invite immediately + set save flags on talk |

Path: `tools/ready_not_installed_eventflow/`  
Only add after the GameClose boot test passes. Do **not** re-add LocalHost / LocalVisitor / Demo arrive-leave as a pack.

## What works vs impossible

| Request | Status |
|---|---|
| Save & End during tutorial (minus menu) | Intended — installed |
| Minus → Test submenu (message stubs) | Intended — installed |
| Walk to Orville and fly / invite anytime | Ready file exists; not installed yet |
| Silent auto-join host island on boot (no Orville) | **Impossible** via LayeredFS alone |
| Hamachi peer poll + loud Orville checklist | Supported by `scripts/AutoJoin-HamachiHost.ps1` |
| Full shared-owner / visitor houses on host save | Still not possible from these files |

## If black screen returns

1. Delete `%APPDATA%\yuzu\load\01006F8002326000\FreedomWithFriends\romfs\EventFlow\System_GameClose.bfevfl`
2. Delete `%APPDATA%\yuzu\load\01006F8002326000\FreedomWithFriends\romfs\Message` (TalkSys)
3. Or delete the whole `romfs\EventFlow` / `romfs\Message` folders
4. Leave cheats / disabled exefs stub
5. Only after a clean boot, consider adding NormalSeq alone from `tools/ready_not_installed_eventflow/`

Do **not** re-run Tutorial Skip / `Build-FromRomfs.ps1 -FromTutorialSkipRelease` on this machine.

Controller **Minus (−) → Test** is the intended test path. `scripts/Start-ModTestMenu.ps1` remains an optional Windows fallback only.
