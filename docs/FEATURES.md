# Features (ACNH **2.0.6** · BID `15765149DF53BA41`)

| Feature | Status |
|---|---|
| Boot with mod enabled | **Fixed** — all romfs overlays removed |
| 60 FPS | **Cheats** — enable `60 FPS` + `Animation Speed x0.5` |
| Tutorial Skip / Minus Freedom menu | **Off** — EventFlow + Movie black-screened after first load |

## Black-screen fix (confirmed)

With **FreedomWithFriends** enabled, the game hung after the first loading screen.
With the mod disabled, it booted.

Removed from `romfs/`:
- All Tutorial Skip `EventFlow/*.bfevfl`
- `Movie/OpeningMovie.webm`
- Empty `ResourceSizeTable` (already removed earlier)

Safe pack = **cheats only** (+ disabled exefs stub). Mod can stay enabled.

## How to use

1. Leave **FreedomWithFriends** enabled
2. Optional: turn on both 60 FPS cheat codes in Yuzu
3. Play normally (full tutorial until a real save exists)
