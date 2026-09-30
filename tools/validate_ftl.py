"""Validate a translated Fluent catalog against the original.

Usage:
    python validate_ftl.py <orig_mods_dir> <patched_mods_dir> <rel_path.ftl> [more.ftl ...]

Checks per key: existence, { $placeholders }, { -terms }, brace balance, plural selectors.
Exits non-zero when anything mismatches.
"""
import os
import re
import sys

PLACE = re.compile(r"\{\s*\$([A-Za-z0-9_-]+)")
TERM = re.compile(r"\{\s*-([A-Za-z0-9_-]+)")
KEY = re.compile(r"^([-a-zA-Z0-9_]+)\s*=")


def blocks(path):
    """Return {key: (raw_text, placeholders, terms)} for one .ftl file."""
    out, cur, buf = {}, None, []
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            m = KEY.match(line)
            if m:
                if cur:
                    out[cur] = "".join(buf)
                cur, buf = m.group(1), [line]
                continue
            if cur is not None and (line.startswith((" ", ".", "\t")) or line.strip() == ""):
                buf.append(line)
            else:
                if cur:
                    out[cur] = "".join(buf)
                cur, buf = None, []
        if cur:
            out[cur] = "".join(buf)
    return {k: (v, PLACE.findall(v), TERM.findall(v)) for k, v in out.items()}


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        return 2
    src_root, dst_root, files = sys.argv[1], sys.argv[2], sys.argv[3:]
    bad = 0
    for rel in files:
        a = blocks(os.path.join(src_root, rel))
        b_path = os.path.join(dst_root, rel)
        if not os.path.exists(b_path):
            print(f"[文件缺失] {rel}")
            bad += 1
            continue
        b = blocks(b_path)
        for key, (raw, ph, tm) in a.items():
            if key not in b:
                print(f"[缺键] {rel}: {key}")
                bad += 1
                continue
            raw2, ph2, tm2 = b[key]
            if set(ph) != set(ph2):
                print(f"[占位符不一致] {rel}: {key} 原文 {sorted(set(ph))} 译文 {sorted(set(ph2))}")
                bad += 1
            if set(tm) != set(tm2):
                print(f"[术语引用不一致] {rel}: {key} 原文 {sorted(set(tm))} 译文 {sorted(set(tm2))}")
                bad += 1
            if raw2.count("{") != raw2.count("}"):
                print(f"[花括号不平衡] {rel}: {key}")
                bad += 1
            if (raw.count("->") > 0) != (raw2.count("->") > 0):
                print(f"[复数选择器缺失] {rel}: {key}")
                bad += 1
        for key in b:
            if key not in a:
                print(f"[多余键] {rel}: {key}")
                bad += 1
        print(f"{rel}: 校验 {len(b)}/{len(a)} 个条目")
    print("全部通过" if bad == 0 else f"发现 {bad} 处问题")
    return 0 if bad == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
