# Features (ACNH **2.0.6**)

## Minus menu fix (blank GUI)

Cause: custom `TalkSys` Message overlay + `Choice3` hid the HUD then never drew a dialog.

Fix: **removed Message overlay**; Minus uses vanilla **Save and end / Keep playing** (`Choice2`).

| Choice (on screen) | What it does |
|---|---|
| Save and end | Save & quit |
| Keep playing | Opens Freedom hub (unlocks + name/birthday, then Save= Fly / Keep= stay) |
| B cancel | Dismiss |

Only `romfs/EventFlow/System_GameClose.bfevfl` is installed (no Message).

Live on host island: `docs/LIVE_ON_HOST_ISLAND.md`
