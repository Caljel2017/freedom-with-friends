# Live on a friend’s island (real resident — tent, Tom Nook, Isabelle, Nook Stop)

Dodo **visits** can never give you a resident tent. To **live** there with full rights, you must be a **second (or later) resident on that island’s save**.

ACNH allows up to **8** player residents on one island. Extra residents are other **user profiles** on the same emulator / console that share that save — not wireless guests.

## What you get as a resident

- Your own tent / house  
- Talk to Tom Nook & Isabelle and use full island menus  
- Nook Stop / ABD  
- Terraforming & placing (same rules as any resident)  
- You are **not** a visitor anymore

## What you do **not** get

- Two people on **two PCs** both acting as live residents on one save at once over Hamachi (the save lives on one machine)  
- A tent that appears when you only **visit** via Orville  

For hangouts on two PCs, still use Orville → Via local play (guest). For **living** there, use the resident setup below.

---

## Setup (recommended): second Yuzu profile on the **host** PC

Do this on the PC that owns the island save (your friend’s machine, or yours if you’re hosting).

1. **Quit ACNH / Yuzu completely.**
2. Backup the save (run `scripts\Backup-AcnhSave.ps1`).
3. In Yuzu: **Emulation → Configure → System → Profiles** (or Users) → **Add** a profile for the friend who will live there (e.g. `Emily`).
4. Select that new profile as the current user.
5. Launch **Animal Crossing: New Horizons**.
6. The game should see the existing island and offer to **move in** as a new resident (character creation → tent placement with Tom Nook).
7. Finish moving in, **Save & End**.
8. That profile now has a tent and full Resident Services access on that island.

### Playing afterward

- To play as the **island owner**: launch Yuzu with the original profile.  
- To play as the **new resident**: launch Yuzu with the friend profile.  
- Only one profile can play that save at a time on that PC.

### Friend lives far away

Options:

| Option | How |
|---|---|
| Play on host PC | Friend uses Remote Desktop / visits and picks their Yuzu profile |
| Shared save file | Host zips the save folder after adding the resident; friend loads it locally to play solo as that resident (not live multiplayer) |
| Hamachi visit | Still a **guest** — no personal tent |

Save folder (host):

`%APPDATA%\yuzu\nand\user\save\0000000000000000\<profileUUID>\01006F8002326000\`

Your current island is under the all-zeros profile UUID:

`...\00000000000000000000000000000000\01006F8002326000\`

---

## After you’re a resident

Minus menu (Save / Test / Keep) works on **your** island session. Tom Nook / Isabelle / Nook Stop work because you are a resident — no visitor patch needed.
