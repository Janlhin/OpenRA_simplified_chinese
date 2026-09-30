"""Print the glyph coverage of a TrueType font for a set of characters.

Usage:
    python check_font_glyphs.py <font.ttf> <characters>
    python check_font_glyphs.py SimHei.ttf 安装游戏内容快速退出

Parses the 'cmap' table directly (format 4 and 12), no dependencies.
Exits 1 when any requested character is missing.
"""
import struct
import sys


def cmap_chars(data):
    version, num_tables = struct.unpack(">IH", data[:6])
    tables = {}
    for i in range(num_tables):
        off = 12 + 16 * i
        tag = data[off:off + 4].decode("latin-1")
        o, _l = struct.unpack(">II", data[off + 8:off + 16])
        tables[tag] = o

    cmap = tables["cmap"]
    n = struct.unpack(">H", data[cmap + 2:cmap + 4])[0]
    sub = None
    for i in range(n):
        _pid, _eid, so = struct.unpack(">HHI", data[cmap + 4 + 8 * i:cmap + 12 + 8 * i])
        fmt = struct.unpack(">H", data[cmap + so:cmap + so + 2])[0]
        if fmt in (4, 12):
            sub = cmap + so
            break
    if sub is None:
        raise SystemExit("no usable cmap subtable (need format 4 or 12)")

    fmt = struct.unpack(">H", data[sub:sub + 2])[0]
    chars = set()
    if fmt == 4:
        seg_x2 = struct.unpack(">H", data[sub + 6:sub + 8])[0]
        seg = seg_x2 // 2
        ends = struct.unpack(">%dH" % seg, data[sub + 14:sub + 14 + seg_x2])
        starts = struct.unpack(">%dH" % seg, data[sub + 16 + seg_x2:sub + 16 + 2 * seg_x2])
        for s, e in zip(starts, ends):
            if s == 0xFFFF:
                continue
            chars.update(range(s, min(e, 0xFFFF) + 1))
    else:  # format 12
        groups = struct.unpack(">I", data[sub + 12:sub + 16])[0]
        for g in range(groups):
            o = sub + 16 + 12 * g
            start, end, _glyph = struct.unpack(">III", data[o:o + 12])
            chars.update(range(start, min(end + 1, start + 0x110000)))
    return fmt, chars


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    path, text = sys.argv[1], sys.argv[2]
    with open(path, "rb") as fh:
        data = fh.read()
    fmt, chars = cmap_chars(data)
    missing = sorted({c for c in text if ord(c) not in chars})
    print(f"字体 {path}: cmap 格式 {fmt}, 覆盖码位 {len(chars)}")
    print("缺失字形:", "".join(missing) if missing else "无")
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
