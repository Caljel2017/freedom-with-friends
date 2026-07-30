# See also: [LIVE_ON_HOST_ISLAND.md](LIVE_ON_HOST_ISLAND.md) for real co-resident tents.

# Shared-owner Hamachi / local-play sessions

Target: ACNH **2.0.6** Â· Build `15765149DF53BA41`

## What you asked for

| Ask | How ACNH works | What Freedom with Friends can do |
|---|---|---|
| Spawn **your own tent** when visiting a friendâ€™s island | Houses/tents are **resident plots on the host save** (up to 8 players). Dodo/local visitors are guests â€” the engine never allocates you a plot. | **Impossible** via LayeredFS / Minus menu. Closest real tent: add you as a **second resident** on the **host save** (same emulator save, not a visit). |
| Talk to Tom Nook / Isabelle and **edit everything** as a visitor | Dialogues + menus check `IsMyVillage` / resident / owner | Needs **exefs** patches (stub: `exefs/FreedomWithFriends_2.0.6.pchtxt.disabled`) â€” no safe public offsets for this BID yet |
| Use **Nook Stop** as a visitor | Resident/owner gated | Same exefs stub |
| Terraform / place / dig as visitor | Client-side owner + â€œhas visitorsâ€ locks | Same exefs stub â€” **host and all guests** need the identical pack |
| Silent auto-join on boot | Orville â†’ Via local play only | `scripts/AutoJoin-HamachiHost.ps1` checklist only |

## Why a tent cannot be modded onto a visit

When you fly in as a guest, you are not written into the hostâ€™s player-house table. LayeredFS can replace EventFlows and messages; it cannot invent a new resident slot on someone elseâ€™s live session. NHSE can add houses on a **save file**, but that only helps people who load that save as that character â€” not Dodo visitors.

## Autoconnect (Hamachi)

1. Same Hamachi network  
2. Emulator multiplayer = **ldn_mitm** / LDN-over-LAN  
3. Host: Orville â†’ visitors â†’ **Via local play**  
4. Guests: Orville â†’ fly â†’ **Via local play**  

## Checklist every session

1. Same ACNH **2.0.6** + same mod revision on every PC  
2. Hamachi connected  
3. Host gate open (local play)  
4. Guests join local play  
5. Shared-owner `exefs` only when real offsets exist and the file is **not** `.disabled`

