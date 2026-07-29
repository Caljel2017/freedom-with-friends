# ACNH Friends Freedom

Yuzu / Ryujinx (LayeredFS + exefs) mod pack for **Animal Crossing: New Horizons**.

**Title ID:** `01006F8002326000`

## Goals

| Feature | Status |
|---|---|
| Visitors can terraform / redesign with friends in multiplayer | **Scaffolded** — needs version-specific `exefs` code patches (see `docs/TECHNICAL.md`) |
| Creative “do anything” session with friends | **Scaffolded** — permission / lock checks are host+guest client-side |
| Skip Dodo Airlines connecting cutscene | **Scaffolded** — needs `romFs` EventFlow edits for your game version |

Working ARM64 / EventFlow binaries are **not invented here**. Fake offsets crash the game or corrupt saves. This repo ships the correct emulator layout, installers, and a clear patch plan so real patches can be dropped in once reverse-engineered against your dump.

> **Console note (3.0+):** Nintendo’s free **Slumber Islands** feature already allows collaborative terraforming with friends online. That uses Nintendo Switch Online and usually does **not** work the same way over Ryujinx LDN. This mod targets classic island visit / local-wireless sessions on emulators.

## Quick install

### Yuzu / forks (Suyu, Sudachi, etc.)

```powershell
.\install\Install-Yuzu.ps1
```

Or copy `FriendsFreedom` into:

`%APPDATA%\yuzu\load\01006F8002326000\FriendsFreedom\`

(Use your fork’s `load` folder if the app name differs.)

### Ryujinx / forks

```powershell
.\install\Install-Ryujinx.ps1
```

Or copy `FriendsFreedom` into:

`%APPDATA%\Ryujinx\mods\contents\01006F8002326000\FriendsFreedom\`

Then enable the mod on the game (Right-click game → Manage / Open mods directory).

### Multiplayer on emulator

1. Same **game version** for every player (mixing updates breaks joins).
2. Same **mod pack** on every client (host + guests).
3. Use **local wireless / LDN** (Ryujinx LDN builds, or your fork’s LDN). Talk to Orville → fly / invite → **Via local play**.
4. Back up saves before enabling any exefs / EventFlow patches.

## Repo layout

```
FriendsFreedom/          ← drop-in mod folder for emulators
  exefs/                 ← .pchtxt / .ips code patches go here
  romfs/                 ← EventFlow / romFS overrides (ACNH often wants romFs on Atmosphere)
  cheats/                ← optional per-build cheat texts
  README.txt
docs/
  FEATURES.md
  TECHNICAL.md
install/
  Install-Yuzu.ps1
  Install-Ryujinx.ps1
scripts/
  New-PatchStub.ps1
```

## Requirements

- A legally obtained ACNH dump of a known version (e.g. 2.0.6 / 3.0.x)
- Yuzu or Ryujinx (or a maintained fork) with LayeredFS mods enabled
- For multiplayer: LDN-capable build + matching versions across friends

## Next step to make features live

See `docs/TECHNICAL.md`. In short:

1. Dump your exact build ID from the emulator.
2. Reverse the visitor permission / terraform lock checks → write `exefs/*.pchtxt`.
3. Decompile airport arrival EventFlows → skip or shorten the connecting demo → compile back into `romfs/EventFlow/`.
4. Re-run the install script and test with two LDN clients.

If you have a dumped game folder and tell me the **exact version + build ID**, we can work the EventFlow / patch stubs against that next.
