#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把 openra-zh-cn 的 ra/cnc 单位显示名,对齐到汉化组(RASC/TDSC)的全称。

- 按 actor 块隔离解析,避免跨块污染(如 orca 的占位名 补给箱 误覆盖 mh60)。
- 汉化组词条优先取本体 actor 的 Tooltip.Name(忽略 .Husk/.Husk1 等残骸条目)。
- 诱饵建筑(我方名以"伪装"开头)不强制改,保留更清晰的"伪装"语义。
干跑(--dry,默认): 只打印计划; --apply: 实际改写并打印改动报告。
"""
import os, re, sys

BASE = r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05"
REF_DIRS = {
    'ra':  [os.path.join(BASE, r"rasc-ref\OpenRA_rasc\mods\rasc\rules"),
            os.path.join(BASE, r"rasc-ref\OpenRA_rasc\mods\modcontent")],
    'cnc': [os.path.join(BASE, r"rasc-ref\OpenRA_tdsc\mods\tdsc\rules")],
}
OUR_FTL = {
    'ra':  os.path.join(BASE, r"openra-zh-cn\files\mods\ra\fluent\rules.ftl"),
    'cnc': os.path.join(BASE, r"openra-zh-cn\files\mods\cnc\fluent\rules.ftl"),
}

cjk = re.compile(r'[\u4e00-\u9fff]')
field_line = re.compile(r'^(\s*)([A-Za-z0-9_@.\-]+):\s*(.*)$')

def normalize_aid(aid):
    if not aid:
        return None
    aid = aid.split('.')[0].lower()      # 去掉 .Husk / .Bomber 等后缀
    if '@' in aid or ':' in aid:
        return None
    return aid

def build_ref_map(dirs):
    ref = {}
    for d in dirs:
        if not os.path.isdir(d):
            print(f"[warn] ref dir missing: {d}")
            continue
        for fn in os.listdir(d):
            if not fn.endswith('.yaml'):
                continue
            p = os.path.join(d, fn)
            try:
                lines = open(p, encoding='utf-8').read().split('\n')
            except UnicodeDecodeError:
                try:
                    lines = open(p, encoding='gbk').read().split('\n')
                except Exception:
                    continue
            cur_actor = None
            stack = []
            for raw in lines:
                if not raw.strip():
                    continue
                m = field_line.match(raw)
                if not m:
                    continue
                indent = len(m.group(1))
                key = m.group(2)
                val = m.group(3).strip()
                if indent == 0:
                    cur_actor = key
                while stack and stack[-1][0] >= indent:
                    stack.pop()
                stack.append((indent, key))
                if key == 'Name' and val and cjk.search(val):
                    under_tooltip = any(k == 'Tooltip' for _, k in stack[:-1])
                    aid = normalize_aid(cur_actor)
                    if not aid:
                        continue
                    # 只取本体 actor 的显示名;带 .Husk 等后缀的残骸条目忽略
                    # 只取本体 actor(无 .Husk/.Bomber 等后缀)的显示名,
                    # 残骸/变体条目一律忽略,避免把"残骸"或误标名当成本体名。
                    if under_tooltip and '.' not in cur_actor:
                        ref.setdefault(aid, val)
    return ref

msg_start = re.compile(r'^(actor-[A-Za-z0-9_.-]+)\s*=')
flat_key  = re.compile(r'^actor-(.+?)-(husk-name|name)\s*=\s*(.*)$')
name_attr = re.compile(r'^(\s*)\.name\s*=\s*(.*)$')

def parse_our(path):
    with open(path, encoding='utf-8') as f:
        lines = f.readlines()
    block_edits = []   # {uid, idx, old}
    flat_edits = []    # {uid, kind, idx, old, raw}
    cur = None
    for i, raw in enumerate(lines):
        s = raw.rstrip('\n')
        fm = flat_key.match(s)
        if fm:
            flat_edits.append({'uid': fm.group(1).lower(), 'kind': fm.group(2),
                               'idx': i, 'old': fm.group(3).strip(), 'raw': raw})
            cur = None
            continue
        ms = msg_start.match(s)
        if ms:
            cur = {'uid': ms.group(1)[len('actor-'):].lower(), 'idx': None, 'old': None}
            block_edits.append(cur)
            continue
        if cur is not None:
            nm = name_attr.match(s)
            if nm:
                cur['idx'] = i
                cur['old'] = nm.group(2).strip()
    return lines, block_edits, flat_edits

def run(mod, apply):
    ref = build_ref_map(REF_DIRS[mod])
    lines, block_edits, flat_edits = parse_our(OUR_FTL[mod])

    # 每个 uid 的本体 .name(取第一个块)
    block_old = {}
    for b in block_edits:
        if b['uid'] not in block_old and b['old']:
            block_old[b['uid']] = b['old']

    changes = []
    # 本体 .name
    for b in block_edits:
        uid, old = b['uid'], b['old']
        if uid in ref and old and ref[uid] != old and 1 <= len(ref[uid]) <= 14:
            if old.startswith('伪装'):          # 诱饵建筑保留"伪装"语义,不强改
                continue
            new = ref[uid]
            new_line = lines[b['idx']].replace(f'.name = {old}', f'.name = {new}', 1)
            changes.append((b['idx'], lines[b['idx']], new_line,
                            f"[{mod}] actor-{uid} .name: {old} -> {new}"))
    # 残骸/已摧毁等 wrapper 里的旧名统一换成汉化组全称。
    # 做法: 只要 husk 词条里含有本体的旧显示名(short),就把该子串替换为全称,
    # 这样 纯名(支努干)、残骸（X）、X（已摧毁） 三种形式都能统一处理。
    # 若旧名与全称相同(无需改) 或 husk 内不含旧名(如 残骸（抽油机）与本体名无关),则跳过。
    for fe in flat_edits:
        if fe['kind'] != 'husk-name':
            continue
        uid, old = fe['uid'], fe['old']
        if uid not in ref:
            continue
        short = block_old.get(uid)
        if not short:
            continue
        full = ref[uid]
        if full == short or short not in old:
            continue
        new = old.replace(short, full, 1)
        if new != old:
            new_line = fe['raw'].replace(old, new, 1)
            changes.append((fe['idx'], fe['raw'], new_line,
                            f"[{mod}] actor-{uid}-husk-name: {old} -> {new}"))

    seen = {}
    for i, o, n, d in changes:
        seen[i] = (o, n, d)
    changes = [(i,) + v for i, v in seen.items()]

    print(f"\n===== MOD {mod} =====")
    print(f"ref 汉化组词条: {len(ref)} | 计划对齐改行: {len(changes)}")
    for _, _, _, desc in sorted(changes, key=lambda x: x[0]):
        print("  " + desc)

    if not apply:
        print("(dry-run, 未写入)")
        return

    for i, o, n, d in sorted(changes, key=lambda x: -x[0]):
        lines[i] = n if n.endswith('\n') else n + '\n'
    # newline='\n' 关闭 Windows 文本模式下的 \n->\r\n 转换,保留原文件的 LF 行尾
    with open(OUR_FTL[mod], 'w', encoding='utf-8', newline='\n') as f:
        f.writelines(lines)
    print(f"已写入 {OUR_FTL[mod]}")

if __name__ == '__main__':
    mods = [m for m in sys.argv[1:] if m in ('ra', 'cnc')]
    apply = '--apply' in sys.argv
    if not mods:
        mods = ['ra', 'cnc']
    for m in mods:
        run(m, apply)
