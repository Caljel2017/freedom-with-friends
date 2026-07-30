# Connectivity — ldn_mitm & Hamachi (ACNH 1.0)

Freedom with Friends multiplayer always uses in-game:

**Dodo Airlines → Orville → Via local play**

ACNH 1.0 has no separate LAN menu. These tools make that local-play path work over a real LAN or the internet.

## Pick a path

| Situation | Mode |
|---|---|
| Friends on the **same Wi‑Fi / Ethernet** (PCs and/or CFW Switch) | Emulator **ldn_mitm** (no VPN) |
| Friends on **different networks** | **Hamachi** (or Radmin / ZeroTier) + emulator **ldn_mitm** |
| Ryujinx public LDN rooms only (no Switch, no VPN) | Emulator **RyuLDN / Ryujinx LDN** (if your build has it) |

Everyone needs the **same ACNH 1.0** build and the **same Freedom with Friends** files.

---

## A. Ryujinx + ldn_mitm (LAN / VPN)

1. Use a Ryujinx build that has **Network / Multiplayer** settings (Ryubing / LDN-capable fork).
2. **Settings → System**
   - Guest Internet Access: **OFF** (unless you know you need LAN-mode games; ACNH uses local play, not game LAN mode)
   - VSync: **ON** (recommended)
3. **Settings → Network / Multiplayer**
   - Mode: **ldn_mitm**
4. Allow **Windows Firewall** prompts for Ryujinx when the host opens the gate.
5. In ACNH: airport → **Via local play** (invite or fly).

### Same room / same real LAN

ldn_mitm alone is enough. Host opens the gate; guests search local play.

### CFW Switch in the mix

The Switch needs the **ldn_mitm** sysmodule (Atmosphere). Same local network or same Hamachi network as the PCs. Still use **Via local play** in ACNH.

---

## B. Hamachi (virtual LAN over the internet)

1. Install [Hamachi](https://www.vpn.net/) (or Radmin VPN / ZeroTier — same idea) on **every** PC.
2. Create or join **one shared network**; everyone must show as online on that network.
3. Note each player’s Hamachi IPv4 (often `25.x.x.x`).
4. In Ryujinx, set multiplayer mode to **ldn_mitm** (local-wireless-over-LAN style).
5. Host: Orville → I want visitors → **Via local play**.
6. Guests: Orville → I wanna fly → **Via local play** → join the host island when it appears.

Helper script (launches Hamachi, polls peers, prints loud Orville steps):

```powershell
.\scripts\AutoJoin-HamachiHost.ps1 -Role Host
.\scripts\AutoJoin-HamachiHost.ps1 -Role Guest
# Optional: ping a known host VPN IP + open a Notepad checklist (not in-game input)
.\scripts\AutoJoin-HamachiHost.ps1 -Role Guest -HostIp 25.x.x.x -AutomateClicks
```

**Guest mode** waits until Hamachi peers (or `-HostIp`) look online, then prints
**“host gate ready — do this NOW”** Orville → Via local play steps. It can watch for an
emulator process and optionally open a checklist (`-AutomateClicks`). It does **not**
teleport you in-game or inject an LDN join.

### Why there is no true auto-teleport / auto-join

LayeredFS cannot silently move the player to Orville or start a local-play session.
True “open hosting session → guest auto-flies” would require either:

1. **Controller / UI automation** against the live emulator window (fragile; menus change), or  
2. **Reverse-engineered game/emulator hooks** (not shipping here)

We do **not** ship airport / OpeningMovie overlays for auto-join — those packs
**black-screen on this 1.0 install**. Default romFS is **one** file only:
`System_GameClose` (save during prologue). See [`WHY_NO_EVENTFLOW.md`](WHY_NO_EVENTFLOW.md).

Orville is always required for visits. Silent join from the title screen is not possible.
Do not mix in Tutorial Skip / OpeningMovie packs (black screen on 1.0).

**Tips**

- Hamachi must be connected **before** launching the emulator.
- If islands don’t show up: disable other VPNs, allow Hamachi + Ryujinx in firewall, try host reboot of the Hamachi network.
- Expect more lag than real LAN; keep player count low on 1.0.

### ZeroTier / Radmin instead of Hamachi

Same pattern: join one virtual LAN → ldn_mitm → Via local play.

---

## C. Yuzu / Suyu / Sudachi

Multiplayer support varies by fork and build. Prefer a fork that documents **LDN / ldn_mitm**. If yours has no LDN:

- Use **Ryujinx** for multiplayer sessions, or  
- Put all players on Hamachi and use whatever “local wireless” option that fork exposes

Mods still install under that emulator’s `load\01006F8002326000\FreedomWithFriends\` path.

---

## D. In-game checklist (every session)

1. Matching **1.0** + matching mod  
2. VPN connected (if used)  
3. Emulator mode **ldn_mitm** (or RyuLDN if that’s your agreed path)  
4. Firewall allowed for host  
5. **Via local play** only — do not use Nintendo Online / internet invite codes unless your setup explicitly supports them  

---

## E. Optional: rename the airport option to “LAN”

Once you have a 1.0 romFS dump, we can edit the Orville choice string (Message archives) so **Via local play** displays as **Via LAN / local play**. Behavior stays local-play + ldn_mitm/Hamachi; only the label changes. Track under `FreedomWithFriends/romfs/Message/`.
