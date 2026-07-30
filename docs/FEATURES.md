# Features (ACNH **2.0.6** · BID `15765149DF53BA41`)

| Feature | Status |
|---|---|
| Minus → **Test** / Save and end / Keep playing | **Installed** |
| Save unlock (early Minus save) | **Installed** via GameClose |
| 60 FPS | **Cheats** — enable both codes |
| Tutorial Skip prologue pack | **Off** — black-screened on this Yuzu install |

## Minus menu

`System_GameClose` + TalkSys label overlay only (no Tutorial Skip EventFlows, no empty RSTB).

**Test** shows a short “Freedom with Friends OK.” ping — expand later.

## Rollback

If the game black-screens after the first load again, delete:
- `romfs/EventFlow/System_GameClose.bfevfl`
- `romfs/Message/TalkSys_USen.sarc.zs`
