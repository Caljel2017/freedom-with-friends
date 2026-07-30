"""Patch SYS_CloseMenu.msbt labels for Freedom with Friends 2.0.6 Minus menu."""
from pathlib import Path
import struct
import shutil

ROOT = Path(__file__).resolve().parents[1]


def parse(path):
    data = bytearray(Path(path).read_bytes())
    lbl = data.find(b"LBL1")
    atr = data.find(b"ATR1")
    txt = data.find(b"TXT2")
    base = txt + 16
    labels = {}
    payload = data[lbl + 8 : atr]
    i = 0
    while i < len(payload) - 5:
        n = payload[i]
        if 1 <= n <= 20:
            name = bytes(payload[i + 1 : i + 1 + n])
            if name.isascii() and all(32 <= b < 127 for b in name):
                rest = i + 1 + n
                idx = struct.unpack_from("<I", payload, rest)[0]
                if idx < 200:
                    labels[name.decode()] = idx
                    i = rest + 4
                    continue
        i += 1
    count = struct.unpack_from("<I", data, base)[0]
    entries = []
    for i in range(count):
        off = struct.unpack_from("<I", data, base + 4 + i * 4)[0]
        start = base + off
        p = start
        while p + 1 < len(data):
            code = struct.unpack_from("<H", data, p)[0]
            if code == 0:
                break
            if code == 0x0E:
                p += 2
                if p + 1 >= len(data):
                    break
                ctrl_type = struct.unpack_from("<H", data, p)[0]
                p += 2
                if ctrl_type == 0x28:
                    p += 8
                    continue
                elif ctrl_type == 0x0A:
                    p += 4
                    continue
                else:
                    p += 4
                    continue
            p += 2
        end = p + 2
        raw = bytes(data[start:end])
        entries.append({"idx": i, "start": start, "end": end, "raw": raw})
    return data, labels, entries, base


def entry_text(raw: bytes) -> str:
    out = []
    p = 0
    while p + 1 < len(raw):
        code = struct.unpack_from("<H", raw, p)[0]
        if code == 0:
            break
        if code == 0x0E:
            p += 2
            if p + 1 >= len(raw):
                break
            ctrl_type = struct.unpack_from("<H", raw, p)[0]
            p += 2
            if ctrl_type == 0x28:
                p += 8
                continue
            elif ctrl_type == 0x0A:
                p += 4
                continue
            else:
                p += 4
                continue
        out.append(chr(code))
        p += 2
    return "".join(out)


def replace_visible_text(raw: bytes, new_text: str) -> bytes:
    if len(raw) >= 12 and struct.unpack_from("<H", raw, 0)[0] == 0x0E and struct.unpack_from("<H", raw, 2)[0] == 0x28:
        prefix = raw[:12]
    else:
        prefix = b""
    body_budget = len(raw) - len(prefix) - 2
    max_c = body_budget // 2
    if max_c < 1:
        raise ValueError(f"no room (old={entry_text(raw)!r})")
    if len(new_text) > max_c:
        raise ValueError(f"{new_text!r} too long ({len(new_text)}>{max_c}); old={entry_text(raw)!r}")
    padded = new_text + (" " * (max_c - len(new_text)))
    new_raw = prefix + padded.encode("utf-16-le") + b"\x00\x00"
    if len(new_raw) != len(raw):
        raise ValueError(f"length mismatch {len(new_raw)} vs {len(raw)}")
    return new_raw


def patch_by_name(data, labels, entries, name, new_text):
    idx = labels[name]
    e = entries[idx]
    old = entry_text(e["raw"])
    new_raw = replace_visible_text(e["raw"], new_text)
    data[e["start"] : e["end"]] = new_raw
    e["raw"] = new_raw
    print(f"  {name}: {old!r} -> {new_text!r}")
    return old


def main():
    src = ROOT / "tools/ACNH-Tutorial-Skip-ref/Message/TalkSys/SYS_CloseMenu.msbt"
    out = ROOT / "source/message_2.0.6_freedom/SYS_CloseMenu.msbt"
    out.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, out)

    data, labels, entries, base = parse(out)
    print("Patching Freedom labels...")
    # :020 budgets: 020_a=9, 020_b=13, 020_c=13
    # Order: Save and end / Test / Keep playing  (Test directly above Keep playing)
    patch_by_name(data, labels, entries, "020_a", "Save end.")  # 9-char slot (means Save and end)
    patch_by_name(data, labels, entries, "020_b", "Test.")
    # 020_c already "Keep playing." in TSkip
    print("  020_c: leave TSkip default (Keep playing.)")

    try:
        patch_by_name(data, labels, entries, "013", "Freedom with Friends OK.")
    except ValueError as ex:
        print("  013:", ex)

    out.write_bytes(data)
    (out.parent / "LABELS.txt").write_text(
        "020_a=Save end. (Save and end)  020_b=Test  020_c=Keep playing\n013=Freedom with Friends OK.\n",
        encoding="utf-8",
    )
    print("Wrote", out)


if __name__ == "__main__":
    main()
