# Features

## 1. Multiplayer terraforming for everyone with the mod

**Vanilla behavior:** Only the island resident can terraform; visitors cannot, and the host often cannot terraform while guests are present.

**Mod intent:** Patch client permission checks so any player running Friends Freedom can use Island Designer (paths, cliffs, waterscaping) during a local-wireless / LDN visit, as long as the host also runs the same patches.

**Why both sides need it:** Terrain edits are validated on each client. A guest-only patch still gets rejected if the host rejects the action; a host-only patch does not unlock the guest UI/tools.

**Related “do anything” locks (same class of patches):**

- Place / move outdoor furniture while visitors are present
- Dig / use axes / nets with fewer best-friend restrictions
- Open Island Designer while the gate is open

Exact hooks differ by game version. Track them in `TECHNICAL.md`.

## 2. Skip Dodo Airlines connecting cutscene

**Vanilla behavior:** When a visitor connects, everyone watches the plane arrival / airport connecting sequence (and a shorter one on leave). It is not skippable in stock UI.

**Mod intent:** Short-circuit or no-op the EventFlow / demo sequence that plays on connect so players return to gameplay immediately after the join load.

**Approach:** Edit the relevant `EventFlow` binaries (`.bfevfl` / `.bfevfl.zs`) in romFS — same technique as community tutorial-skip mods — then LayeredFS-replace them.

This is **not** the same as the Ryujinx “intro cutscene skip” crash workaround some ACNH setups need on first boot.

## 3. Emulator multiplayer reminder

Friends Freedom does not replace LDN. You still need:

- Matching ACNH version on every PC
- LDN enabled in the emulator
- Orville → local play (not Nintendo Online internet, unless your fork supports it)

## Realistic alternatives (no custom patches)

| Want | Option |
|---|---|
| Co-op terraform with friends on a real Switch (3.0+) | Slumber Islands (Nintendo Online) |
| Unlock Island Designer / permits on your save | NHSE save editor (single-player progression) |
| QoL / item tools on CFW Switch | Overlay toolkits (Tesla) — not LayeredFS, not shared guest terraform |
