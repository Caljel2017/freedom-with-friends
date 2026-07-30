# Features (ACNH **2.0.6** · BID `15765149DF53BA41`)

| Feature | Status |
|---|---|
| Fast tutorial / new-island start | **Installed** — Tutorial Skip EventFlows + short OpeningMovie |
| 60 FPS | **Cheats** — enable `60 FPS` + `Animation Speed x0.5` |
| Minus Freedom menu | Parked — prior Message/GameClose overlays black-screened |
| Empty RSTB | **Removed** — 0-byte `ResourceSizeTable` hangs Yuzu after first load |

## Black-screen fix (2026-07-29)

1. Removed Message + custom `System_GameClose`
2. Removed empty `romfs/System/Resource/ResourceSizeTable.srsizetable` (size 0). Atmosphere Tutorial Skip ships this; Yuzu LayeredFS replaces the real RSTB with nothing → hang after the first loading screen.

**Quit Yuzu / relaunch ACNH.** You should get past the first load now.

## How to use

1. Enable **FreedomWithFriends**
2. Prefer a **New game** for Tutorial Skip
3. Optional 60 FPS cheats (both codes)
