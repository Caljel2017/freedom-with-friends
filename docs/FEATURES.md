# Features (ACNH **2.0.6** · BID `15765149DF53BA41`)

| Feature | Status |
|---|---|
| Minus → Save / Test / Keep + Profile / Fly | **Fixed** — lighter unlocks; own-island menu even with visitors |
| 60 FPS | Cheats — both codes |
| **Live on a friend’s island** (real tent + Nook/Isabelle/Nook Stop) | **Guide** — second Yuzu profile as co-resident on the **host save** (`docs/LIVE_ON_HOST_ISLAND.md`) |
| Dodo visit tent / visitor owner powers | Still impossible without exefs offsets |

## Minus fix (2026-07-29)

- Removed `GetGymnasticsEmoticon` from every Minus open (could hang the menu)
- Own island always opens Freedom menu even if friends are visiting
- Heavy unlocks run when you open **Test**

## Live on host island

```powershell
.\scripts\Prepare-SecondResident.ps1
```

See `LIVE_ON_HOST_ISLAND.md`.
