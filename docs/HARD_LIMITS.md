# Limits — ACNH **2.0.6** (Yuzu / LayeredFS)

Things that **still cannot** be done with this mod style, even after updating past 1.0:

## 20 villagers

**Impossible.** Engine + save allocate **10** villager slots. No EventFlow / cheat / NHSE option expands that to 20.

## Visitor house on a friend’s island (Dodo / local visit)

**Not a real resident plot.** Houses belong to residents on the **host save**. Guests cannot get a permanent house via LayeredFS while visiting.

## Silent auto-join host island on boot

**Impossible** via LayeredFS alone. Still: Orville → Via local play (+ Hamachi / ldn_mitm). See `CONNECTIVITY.md`.

## Full Tutorial Skip EventFlow pack on this Yuzu install

**Off by choice.** The prologue EventFlow + OpeningMovie pack black-screened after the first load here. Freedom features are delivered through the Minus menu instead.

## Every reaction on day one

Emote **UI** + gymnastics set are granted from Minus / Test. Filling the entire reaction wheel still needs per-reaction IDs / NHSE after you have a real save.

---

## Now possible on 2.0.6 (this pack)

| Feature | How |
|---|---|
| 60 FPS | Cheats — enable **both** `60 FPS` + `Animation Speed x0.5` |
| Minus Save & End early | `System_GameClose` save unlock |
| Minus → **Test** Freedom hub | Profile (name + birthday) / Fly to airport |
| Orville / airport / designer / main UI flags | Set when you open Minus or Test |
| Emote UI + gymnastics reactions | `EnableEmoticonUI` + `GetGymnasticsEmoticon` |
