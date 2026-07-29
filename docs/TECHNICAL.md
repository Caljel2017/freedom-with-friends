# Technical plan

Animal Crossing: New Horizons  
Title ID: `01006F8002326000`

Patches are **build-specific**. Always record:

- Game version string (e.g. `2.0.6`, `3.0.1`)
- main NSO **Build ID** (emulator Properties / cheat folder name)
- Whether DLC / Happy Home Paradise is present

## Emulator mod roots

| Emulator | Path |
|---|---|
| Yuzu | `%APPDATA%\yuzu\load\01006F8002326000\<ModName>\` |
| Ryujinx | `%APPDATA%\Ryujinx\mods\contents\01006F8002326000\<ModName>\` |
| Atmosphere (Switch CFW) | `atmosphere/contents/01006F8002326000/` (note ACNH often requires `romFs` capitalization + RSTB) |

Inside the mod name folder:

```
exefs/   ← IPSwitch-style .pchtxt or .ips
romfs/   ← LayeredFS file replacements
cheats/  ← optional <BUILDID>.txt
```

## A. Multiplayer terraform / creative permissions (`exefs`)

### What to find

In the main executable (or relevant NSO), locate checks roughly equivalent to:

1. `IsIslandOwner` / resident slot checks before Island Designer actions
2. `HasVisitors` / gate-open locks that disable terraforming for the host
3. Tool permission flags (best-friend shovel/axe, place furniture outdoors)

Typical patch styles:

- Force a comparison to succeed (`CMP`/`B.EQ` → NOP or invert branch)
- Force a function to `return true` (`MOV W0, #1; RET`)

### Deliverable format (Ryujinx / Yuzu `.pchtxt`)

```text
@nsobid-<BUILDID_WITHOUT_DASHES>
# Friends Freedom — visitor terraform / creative locks
# Version: <game version>
# Author: <you>
# Compatible with Friends Freedom romfs EventFlow pack

@flag print_values
@flag offset_shift 0x100

// Example stubs — REPLACE with real offsets for your build
// @enabled Visitor terraform allow
// 00ABCDEF Nop
// 00ABCDF0 mov w0, #1
```

Save as:

`FriendsFreedom/exefs/FriendsFreedom_<version>.pchtxt`

Yuzu/Ryujinx expect patch files under `exefs/`. Only enable **one** patch set matching the installed build.

### Verification

1. Host opens gate via local play (LDN).
2. Guest joins with the same mod + version.
3. Guest opens Island Designer — paths/cliffs/water should apply and persist for the host.
4. Host can still terraform with guests present (if that patch is included).
5. Disable mod → restrictions return (confirms patch, not save corruption).

**Save backup before every test.**

## B. Skip Dodo connecting cutscene (`romfs` EventFlow)

### What to find

From a dumped romFS, search EventFlow names / strings related to:

- Airport arrival / departure demos
- Visitor connect / disconnect sequences
- Orville / Dodo Airlines flight transitions

Community tutorial-skip work (e.g. EventFlow decompile → edit → recompile with `acnh-eventflow-compiler`) is the same pipeline.

### Pipeline

1. Extract romFS for your version.
2. Decompress `.zs` (ZSTD) EventFlow archives as needed.
3. Decompile `.bfevfl` → edit graph to skip demo nodes / jump to end.
4. Recompile and place under:

```
FriendsFreedom/romfs/EventFlow/<original relative paths>
```

5. For Atmosphere on hardware, also handle `ResourceSizeTable.srsizetable` (empty RSTB disable file under `romFs/System/Resource/`). Many emulator setups load replacements without it; test both ways.

### Verification

1. Host opens gate; guest connects.
2. Plane / connecting sequence should be absent or near-instant.
3. Both players should be controllable on the island without softlock.
4. Leaving should not softlock the airport.

## C. Optional cheats folder

Cheats are **not** a substitute for permission patches in multiplayer (they are usually local and anti-cheat sensitive). If you still want single-player QoL while developing:

```
FriendsFreedom/cheats/<BUILDID>.txt
```

Prefer finishing the `exefs` permission patches for the multiplayer goal.

## D. Version matrix (fill in as you dump)

| Version | Build ID | Terraform pchtxt | Cutscene EventFlow | Notes |
|---|---|---|---|---|
| 2.0.6 | | | | Common emulator baseline |
| 2.0.8 | | | | |
| 3.0.x | | | | Slumber Islands exist on console; LDN still needs classic visit patches |

## Safety

- Never share illegally obtained dumps in this repo.
- Do not guess ARM offsets; crashes mid-save are painful.
- Keep JKSV / emulator save backups before enabling patches.
- All friends must match **version + mod revision**.
