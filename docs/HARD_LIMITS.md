# Limits that LayeredFS cannot change (ACNH 1.0)

## 20 villagers

**Impossible.** New Horizons allocates **10** villager slots in the save and engine. There is no EventFlow, cheat, or NHSE toggle that expands that to 20 without rewriting the game binary and save format.

Max island villagers: **10**.

## 60 FPS on pure 1.0.0

**No verified BID-matched 60FPS patch** for build `7FC1BAFF976AECA4` in the usual FPSLocker / NX-60FPS databases (they track much newer versions).

Yuzu **Ctrl+U** (disable framerate limit) makes ACNH run at double **game speed**, not smooth 60 with normal pacing. Do not use that alone.

When/if you move to a newer update, use a **Build-ID-matched** 60FPS code + author half-speed animation fix.

## Visitor house on a friend’s island (Dodo visit)

**Not a real resident plot.** Houses belong to residents on the **host save** (up to 8 player houses). Wireless/local-play visitors are guests; Tom Nook cannot allocate you a permanent house on their island through LayeredFS.

Closest options:

- Add a **second resident character** on the host Switch/emulator save (same island, not a Dodo visit)
- Future `exefs` shared-owner experiments (still stub; see `SHARED_OWNER.md`)

## All reactions on day one

Emoticon **UI** is enabled when you open Minus (`EnableEmoticonUI`). Teaching every reaction wheel entry still needs per-reaction grants (villagers / NHSE after you have a save). Full auto-grant on 1.0 EventFlow is incomplete until reaction IDs are fully mapped for this build.
