"""Inject patched SYS_CloseMenu.msbt into TalkSys_USen.sarc.zs (same-size replace)."""
from pathlib import Path
import zstandard as zstd

ROOT = Path(__file__).resolve().parents[1]


def main():
    msbt_candidates = [
        ROOT / "source/message_2.0.6_freedom/SYS_CloseMenu.msbt",
        ROOT / "source/message_1.0_test_menu/SYS_CloseMenu.msbt",
    ]
    msbt_path = next(p for p in msbt_candidates if p.exists())
    print("msbt", msbt_path)
    # Prefer rebuilding from Tutorial Skip sarc (already contains expanded CloseMenu / 020_c).
    zs_candidates = [
        ROOT / "tools/ACNH-Tutorial-Skip-ref/Message/TalkSys_USen.sarc.zs",
        ROOT / "tools/romfs_dump_1.0/romfs/Message/TalkSys_USen.sarc.zs",
    ]
    zs_in = next(p for p in zs_candidates if p.exists())
    print("base zs", zs_in)

    msbt = msbt_path.read_bytes()
    raw_zs = zs_in.read_bytes()
    sarc = zstd.ZstdDecompressor().decompress(raw_zs)
    print("sarc", len(sarc), "msbt", len(msbt))

    # Find original CloseMenu inside sarc by magic + size uniqueness
    # Look for MsgStdBn near filename
    name = b"SYS_CloseMenu.msbt"
    name_at = sarc.find(name)
    print("name at", name_at)

    # Find all MsgStdBn occurrences
    positions = []
    start = 0
    while True:
        i = sarc.find(b"MsgStdBn", start)
        if i < 0:
            break
        positions.append(i)
        start = i + 1
    print("MsgStdBn count", len(positions), positions[:5])

    # Match by exact old file size from TSkip source msbt length before patch
    # Our patched file is same length as TSkip SYS_CloseMenu.msbt
    old_ts = (ROOT / "tools/ACNH-Tutorial-Skip-ref/Message/TalkSys/SYS_CloseMenu.msbt").read_bytes()
    assert len(old_ts) == len(msbt), f"size changed {len(old_ts)} vs {len(msbt)} — cannot same-size inject"

    idx = sarc.find(old_ts)
    if idx < 0:
        # maybe already different; try find by length at MsgStdBn with matching size
        target = None
        for p in positions:
            # read size from header @0x10 LE? file size field
            # Compare length by checking next file boundary — use exact search of first 64 bytes + size
            chunk = sarc[p : p + len(msbt)]
            if len(chunk) == len(msbt) and chunk[:8] == b"MsgStdBn":
                # Heuristic: CloseMenu is the one containing b'Ready to wrap'
                if "Ready to wrap".encode("utf-16-le") in chunk or b"Ready to wrap" in chunk:
                    # utf16
                    if "Ready to wrap".encode("utf-16-le") in chunk:
                        target = p
                        break
        if target is None:
            raise SystemExit("could not locate SYS_CloseMenu.msbt blob in sarc")
        idx = target
        old_blob = sarc[idx : idx + len(msbt)]
        print("located via Ready-to-wrap at", idx, "old_len", len(old_blob))
    else:
        print("located exact TSkip MSBT at", idx)

    new_sarc = bytearray(sarc)
    new_sarc[idx : idx + len(msbt)] = msbt
    assert bytes(new_sarc[idx : idx + len(msbt)]) == msbt

    out_dir = ROOT / "FreedomWithFriends/romfs/Message"
    out_dir.mkdir(parents=True, exist_ok=True)
    compressed = zstd.ZstdCompressor(level=10).compress(bytes(new_sarc))
    out_zs = out_dir / "TalkSys_USen.sarc.zs"
    out_zs.write_bytes(compressed)
    print("wrote", out_zs, "zs", len(compressed), "(was", len(raw_zs), ")")


if __name__ == "__main__":
    main()
