# Shared-owner Hamachi sessions (design)

Target: ACNH **1.0.0** · Build `7FC1BAFF976AECA4`

## What you asked for

| Ask | How ACNH actually works | Freedom with Friends approach |
|---|---|---|
| Autoconnect to Hamachi host on boot | Game only joins via Orville → **Via local play** | `scripts/AutoJoin-HamachiHost.ps1` prepares Hamachi + checklist; cannot silently inject a join without input automation / reverse hooks |
| Everyone treated as island owner while visiting | Visitors are not residents; many systems check owner/resident | `exefs` permission patches (stub until 1.0 offsets found) — host + all guests need the same pack |
| Nook Miles ticket machine / Nook Stop | Resident/owner gated | Same owner-permission patches |
| House + mailbox for every visitor | Houses exist only for **residents on that save** (up to 8), not for Dodo visitors | Cannot spawn real visitor houses over wireless visit without rewriting multiplayer/save architecture. Closest: treat visitors as owners for **facility use**; houses stay host-save residents only |
| Mail from villagers on the island you’re on | Mail is tied to resident mailbox / island save | Needs owner/resident mail permission patches + possibly EventFlow; visitors normally cannot use a full mailbox |

## Autoconnect (Hamachi)

ACNH will never “see Hamachi” by itself. Flow:

1. Everyone online on the **same Hamachi network**
2. Emulator multiplayer mode = **ldn_mitm** (Ryujinx) or your fork’s LDN-over-LAN
3. **Host** opens gate: Orville → visitors → Via local play
4. **Guests** join: Orville → fly → Via local play

`AutoJoin-HamachiHost.ps1` will:

- Launch / verify Hamachi
- Print who’s on the network
- Remind host vs guest steps
- Optionally open the connectivity doc

True “on title screen already in host island” needs either:

- Controller automation through airport menus (fragile), or
- Code/memory hooks inside the emulator process (not in this LayeredFS pack yet)

## Shared owner permissions (`exefs`)

Patch targets (all clients):

1. `IsIslandOwner` / resident checks → force true for local player while in multiplayer visit  
2. Nook Stop / ABD / Miles redemption allow  
3. Outdoor place / dig / design locks  
4. Mailbox open / send/receive against **host island** villager mail tables  
5. Terraforming / construction if present on that game version  

Until real ARM offsets for 1.0 are filled in `exefs/FreedomWithFriends_1.0.pchtxt`, these stay **documented stubs** (enabling guessed offsets risks saves).

## Houses & mailboxes (honest limit)

- **Same Switch save, multiple resident characters** = each can have a house/mailbox (not Hamachi visiting).  
- **Dodo / local-play visit** = you are a guest on the host save; the engine does not allocate you a plot.  

Freedom with Friends aims for **owner-level access to host facilities** while visiting, not cloning eight player houses onto the host island for every guest.

## Checklist every session

1. Same ACNH **1.0** build + same mod revision  
2. Hamachi connected  
3. Host gate open (local play)  
4. Guests join local play  
5. When exefs owner patches exist: enable them on **every** PC  
