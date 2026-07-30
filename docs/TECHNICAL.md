# Technical plan — Freedom with Friends

Title ID: `01006F8002326000`  
1.0.0 Build ID: `7FC1BAFF976AECA4`

## Shipped romFS

From ACNH Tutorial Skip v0.2 into `FreedomWithFriends/romfs/`:

- `EventFlow/*.bfevfl` — prologue fast-start + unlock flags  
- `Movie/OpeningMovie.webm` — short intro  
- `System/Resource/ResourceSizeTable.srsizetable`

Sources: `source/eventflow/` (includes `Mod_FreedomWithFriends.evfl`).

Rebuild: `scripts/Build-FromRomfs.ps1`

## A. Visitor terraform / creative (`exefs`)

`FreedomWithFriends/exefs/FreedomWithFriends_1.0.pchtxt` — Build ID filled; instruction offsets still TODO.

## B. Visitor connecting cutscene skip

Not in Tutorial Skip. Need airport visitor arrival/departure EventFlows from dump → skip demos → compile into `romfs/EventFlow/`.

## C. LAN at Dodo

Use **Via local play** + ldn_mitm/Hamachi (`docs/CONNECTIVITY.md`). Optional Message rename later under `romfs/Message/`.

## D. Fly anytime / random-ish start

Covered by Tutorial Skip EventFlow + `AirportOpen` / designer flags. Map layout still uses `UIMapSelectHandling()` (no public random-layout actor found).

## E. Pure 1.0.0 caveat

Day-one **1.0.0 has no Island Designer / terraforming** (added in a later free update). On 1.0.0, designer flags do nothing until that systems exists. EventFlow binaries may also crash on 1.0.0 — rebuild from dump or remove `romfs/EventFlow` + `Movie`.

## Version matrix

| Version | Build ID | EventFlow pack | Cheats file | Visitor exefs |
|---|---|---|---|---|
| 1.0.0 | 7FC1BAFF976AECA4 | rebuild recommended | yes | stub |
| ~2.0.x | (your ID) | shipped Tutorial Skip binaries OK | rename cheat file | stub |
