# Connecting with friends (LDN / ldn_mitm / Hamachi)

Freedom with Friends is a **game** mod. Networking is handled by the emulator + (optional) VPN.

ACNH visits for this pack use **Via local play** at Dodo Airlines — not Nintendo Switch Online internet flights.

## Pick a path

| Situation | Mode to use |
|---|---|
| Everyone on **Ryujinx** over the internet (no VPN) | **RyuLDN** / **Ryujinx LDN** |
| Same house Wi‑Fi / Ethernet, or CFW Switch with **ldn_mitm** | **ldn_mitm** (+ LAN where your build asks for it) |
| Friends over the internet via **Hamachi** (or Radmin / ZeroTier) | Join the same VPN network, then **ldn_mitm** as if on one LAN |
| Mix of Ryujinx + CFW Switch | Switch runs **ldn_mitm** sysmodule; emulator mode **ldn_mitm**; same LAN or same VPN |

Everyone must share: **same ACNH version**, **same Freedom with Friends files** (when using the mod), and **matching LDN mode**.

---

## A. Ryujinx / Ryubing — RyuLDN (internet, no Hamachi)

1. Use an LDN-capable Ryujinx / Ryubing build (current releases include network modes; older “LDN preview” builds also work).
2. **Options → Settings → System**
   - Guest Internet Access: **OFF**
   - VSync: **ON** (recommended)
3. **Options → Settings → Network / Multiplayer**
   - Mode: **RyuLDN** / **Ryujinx LDN**
4. Allow Windows Firewall when prompted (host especially needs inbound).
5. In ACNH: Orville → invite or fly → **Via local play**.

---

## B. ldn_mitm (LAN or CFW Switch)

Use this for real LAN, Hamachi-style VPN LAN, or CFW Switch peers.

### Emulator

1. Network / Multiplayer mode: **ldn_mitm**
2. If your build has a separate **LAN / Guest Internet** toggle for local-network LDN:
   - Same physical LAN or same VPN: follow your fork’s LDN guide (often ldn_mitm + LAN enabled for local)
   - If rooms never appear, try the opposite LAN toggle once — forks differ
3. Firewall: allow the emulator for private networks (and the Hamachi adapter if used).

### CFW Switch (Atmosphere)

1. Install **ldn_mitm** (sysmodule) on the Switch.
2. Switch and PCs must be on the **same** subnet (home LAN or same Hamachi network).
3. Same game version as emulator players.
4. In-game: **Via local play** only.

---

## C. Hamachi (virtual LAN over the internet)

Hamachi (LogMeIn Hamachi) creates a VPN so `ldn_mitm` thinks everyone is on one LAN. Radmin VPN or ZeroTier work the same idea.

### Host

1. Install Hamachi; create a network; note network name + password.
2. Go **online** in Hamachi; confirm you get a `25.x.x.x` (or similar) VPN IP.
3. Windows Firewall: allow **Hamachi** and **Ryujinx** / your emulator on Private networks.
4. Emulator mode: **ldn_mitm** (not RyuLDN).
5. Launch ACNH → Orville → **I want visitors** → **Via local play**.

### Guests

1. Install Hamachi; join the host’s network; go online.
2. Ping the host’s Hamachi IP (`ping 25.x.x.x`) — fix firewall/VPN if that fails before blaming the game.
3. Emulator: **ldn_mitm**, same ACNH version + mod pack.
4. Orville → **I wanna fly!** → **Via local play** → join the host island.

Optional assistant (polls Hamachi peers, prints loud Orville steps; does **not** teleport in-game):

```powershell
.\scripts\AutoJoin-HamachiHost.ps1 -Role Guest
.\scripts\AutoJoin-HamachiHost.ps1 -Role Guest -HostIp 25.x.x.x -AutomateClicks
```

True auto-teleport / auto LDN join is **not** possible via LayeredFS. It would need fragile
controller automation or reverse-engineered hooks — we do not ship EventFlow for that
(black screen on this 1.0 install). See [`CONNECTIVITY.md`](CONNECTIVITY.md).

### Hamachi tips

- Everyone must show as online in the same Hamachi network before opening the gate.
- Disable conflicting VPNs.
- If discovery fails: restart Hamachi → restart emulator → reopen local play.
- Hamachi free tier is enough for a small friend group; paid plans raise peer limits.

---

## In-game checklist (all modes)

1. Back up saves.
2. Enable Freedom with Friends on every client.
3. Confirm network mode (RyuLDN **or** ldn_mitm + Hamachi).
4. Orville → **Via local play** (never NSO online for this flow).
5. Host opens the gate first; guests search/join after the island appears.

---

## Yuzu / forks

Yuzu’s multiplayer story varies by fork (Sudachi, Suyu, Citron, etc.). Prefer a fork that documents **LDN** or **ldn_mitm**-style local wireless. If your fork has no LDN, use **Ryujinx/Ryubing** for visits, or a VPN + whatever local-wireless option that fork exposes.

Install the game mod with `install\Install-Yuzu.ps1` either way; connection mode is separate from LayeredFS.

---

## Quick troubleshooting

| Problem | Try |
|---|---|
| Nobody sees the island | Same game version? Same mode (all RyuLDN or all ldn_mitm)? Firewall allow? |
| Hamachi connected, game isn’t | Ping Hamachi IPs; mode must be **ldn_mitm**; reopen local play |
| Works on Wi‑Fi, not Hamachi | Allow emulator on the Hamachi network profile; disable other VPNs |
| Switch + PC won’t link | ldn_mitm on Switch; emulator **ldn_mitm**; same subnet |
| Desync / softlock after join | Matching mods; matching update; host reopen gate |

More emulator detail: [Ryubing LDN guide](https://docs.ryujinx.app/guides/ldn-guide/).
