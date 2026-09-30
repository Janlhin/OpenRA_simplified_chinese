"""检查 yaml 中引用的 Fluent 消息键是否都在 .ftl 目录里存在。

用法:
    python check_yaml_fluent_refs.py <mods 目录> [<对照的 mods 目录>]

参数 1 为待检查的 mods 目录;给出参数 2 时做差分对比,只报告"对照版本能解析、
待检查版本却解析不到"的键 —— 这对汉化补丁最有意义:英文原版能跑通的消息键,
打补丁后必须依然能解析,否则界面上会直接显示键名。

退出码 0 表示无问题。
"""
import os
import re
import sys

MODS = ["ra", "cnc", "d2k", "ra-content", "cnc-content", "d2k-content"]

# yaml 里被 [FluentReference] 标注、值为消息键的字段。
# 注意不要收录 installer yaml 里的 Name: —— 那是内容包标识符(如 movies-gdi),不是消息键。
REF_FIELD = re.compile(r"^\s*(?:Title|Text|TooltipText|Description|Header|Label|Prompt|ReplayMessage|ChatLine):\s*([a-z][a-z0-9]*(?:-[a-z0-9]+)+)\s*$")
KEY_LINE = re.compile(r"^(-?[A-Za-z][A-Za-z0-9_-]*)\s*=")


def catalog_keys(path):
    keys = set()
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            m = KEY_LINE.match(line)
            if m:
                keys.add(m.group(1))
    return keys


def mod_catalog_keys(mods_root, mod):
    """返回该 mod 加载的所有 .ftl 里的键集合。"""
    manifest = os.path.join(mods_root, mod, "mod.yaml")
    if not os.path.exists(manifest):
        return set(), []
    text = open(manifest, encoding="utf-8", errors="replace").read()
    lines = text.split("\n")

    # 包前缀 -> 目录名。两种绑定写法都要认:
    #   ^EngineDir|mods/common: common      (引擎目录下的公共包)
    #   $ra-content: racontent              ($ 前缀 = 该 mod 自身的目录)
    prefix_dir = {}
    for line in lines:
        m = re.search(r"\^EngineDir\|mods/([A-Za-z0-9_.-]+):\s*(\S+)", line)
        if m:
            prefix_dir[m.group(2)] = m.group(1)
            continue
        m = re.search(r"\$([A-Za-z0-9_.-]+):\s*(\S+)", line)
        if m:
            prefix_dir[m.group(2)] = m.group(1)
    prefix_dir.setdefault(mod, mod)
    for name in ("common", "ra", "cnc", "d2k"):
        prefix_dir.setdefault(name, name)

    files, missing_files = [], []
    in_section = False
    for line in lines:
        if line.startswith("FluentMessages:"):
            in_section = True
            continue
        if in_section:
            if re.match(r"^[A-Za-z]", line):
                break
            entry = line.strip()
            if "|" not in entry:
                continue
            prefix, rel = entry.split("|", 1)
            sub = prefix_dir.get(prefix)
            if not sub:
                continue
            p = os.path.join(mods_root, sub, rel.replace("/", os.sep))
            if os.path.exists(p):
                files.append(p)
            else:
                missing_files.append(entry)

    # 地图自带的 map.ftl 由地图自己加载,不在 FluentMessages 里
    maps_root = os.path.join(mods_root, mod, "maps")
    for dirpath, _dirnames, filenames in os.walk(maps_root):
        for f in filenames:
            if f.endswith(".ftl"):
                files.append(os.path.join(dirpath, f))

    # mod 自己 fluent 目录下未被 FluentMessages 列出的目录(如战役用的 campaign.ftl)
    # 由脚本在运行时加载,一并计入,避免误报
    for sub in {mod} | {v for v in prefix_dir.values()}:
        own = os.path.join(mods_root, sub, "fluent")
        if os.path.isdir(own):
            for f in os.listdir(own):
                if f.endswith(".ftl"):
                    p = os.path.join(own, f)
                    if p not in files:
                        files.append(p)

    keys = set()
    for p in files:
        keys |= catalog_keys(p)
    return keys, missing_files


def referenced_keys(mods_root, mod):
    """扫描该 mod 目录下所有 yaml,收集疑似消息键的取值。"""
    refs = {}
    root = os.path.join(mods_root, mod)
    for dirpath, _dirnames, filenames in os.walk(root):
        for f in filenames:
            if not f.endswith((".yaml", ".yml")):
                continue
            path = os.path.join(dirpath, f)
            for line in open(path, encoding="utf-8", errors="replace"):
                m = REF_FIELD.match(line.rstrip("\n"))
                if m:
                    refs.setdefault(m.group(1), os.path.relpath(path, root))
    return refs


def collect(mods_root):
    out = {}
    for mod in MODS:
        keys, missing_files = mod_catalog_keys(mods_root, mod)
        refs = referenced_keys(mods_root, mod)
        out[mod] = (keys, refs, missing_files)
    return out


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    target = collect(sys.argv[1])
    baseline = collect(sys.argv[2]) if len(sys.argv) > 2 else None

    bad = 0
    for mod in MODS:
        keys, refs, missing_files = target[mod]
        unresolved = sorted(k for k in refs if k not in keys)
        if baseline:
            base_keys, base_refs, _ = baseline[mod]
            unresolved = sorted(k for k in unresolved if k in base_refs and k in base_keys)
            label = "打补丁后新出现的未解析键"
        else:
            label = "未解析键"
        print(f"{mod}: 目录键 {len(keys)} 个, yaml 引用 {len(refs)} 个 -> {label} {len(unresolved)} 个")
        for k in unresolved:
            print(f"    {k}   (来自 {refs[k]})")
        for mf in missing_files:
            print(f"    [缺文件] {mf}")
            bad += 1
        bad += len(unresolved)
    print("全部通过" if bad == 0 else f"发现 {bad} 处问题")
    return 0 if bad == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
