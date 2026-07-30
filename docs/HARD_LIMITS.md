# Limits — ACNH **2.0.6** (Yuzu / LayeredFS)

## Visitor tent on a friend’s island

**Impossible** for Dodo / local-play **guests**. Tents and houses are resident plots on the **host save** (max **8** player characters). Visiting does not create a plot for you.

**Closest real tent:** host adds you as another **resident character** on their save (in-game / NHSE). You then play that character on that save — you are not a wireless visitor.

## Tom Nook / Isabelle “edit everything” + Nook Stop as a visitor

**Not available yet.** Those menus check island owner / resident in the game binary. That needs a verified **exefs** patch for Build ID `15765149DF53BA41`.

Stub (disabled on purpose): `FreedomWithFriends/exefs/FreedomWithFriends_2.0.6.pchtxt.disabled`  
Guessed offsets are **not** filled — enabling fakes risks crashes and save desync.

## 20 villagers

**Impossible.** Engine max is **10**.

## Silent auto-join host island on boot

**Impossible** via LayeredFS alone. Still Orville → Via local play (+ Hamachi). See `CONNECTIVITY.md`.

## Full Tutorial Skip EventFlow pack on this Yuzu install

**Off.** Prologue EventFlow + OpeningMovie black-screened after the first load here. Freedom features use the Minus menu instead.

## Every reaction on day one

Emote UI + gymnastics set from Minus / Test. Full reaction wheel still needs NHSE / mapped IDs after you have a save.

---

## What this pack **does** on 2.0.6

| Feature | How |
|---|---|
| 60 FPS | Cheats — enable **both** `60 FPS` + `Animation Speed x0.5` |
| Minus Save & End early | `System_GameClose` |
| Minus → Test → Profile / Fly | Name+birthday, warp to airport |
| Orville / airport / designer / main UI flags | Set when you open Minus or Test |
| Emote UI + gymnastics | From Minus / Test |
| Shared-owner visitor powers | **Stub only** until real 2.0.6 offsets exist |
