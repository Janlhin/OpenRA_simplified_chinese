# -*- coding: utf-8 -*-
"""汉化覆盖率审计:对比"英文原版安装目录"与"汉化后的安装目录",列出还没翻的地方。

用法:
    python tools/audit_coverage.py --original "<英文原版安装目录>" --patched "<汉化安装目录>" \
                                   [--examples 3]

输出四部分:
  A. 残留英文的 Fluent 条目(key 仍在、取值里没有汉字)
  B. .ftl 之外、可能上屏的硬编码英文(按字段归类)
  C. .lua 脚本里直接上屏的英文字面量
  D. 已知且"故意不改"的部分(地图元数据等,附原因)

注意:判断"是否已翻译"用的是"取值里有没有汉字",因此品牌名、缩写（GDI / APL / ID）
这类本就该保留的英文会被列出来,需要人工确认。
"""
import argparse
import hashlib
import os
import re
import sys

CJK = re.compile(r'[\u4e00-\u9fff\u3000-\u303f\uff00-\uffef]')
KEYLINE = re.compile(r'^(-?[A-Za-z][A-Za-z0-9_-]*)\s*=(.*)$')
ATTRLINE = re.compile(r'^\s+\.([A-Za-z0-9_-]+)\s*=(.*)$')
FLUENT_KEY = re.compile(r'^[a-z][a-z0-9]*([-.][a-z0-9]+)+$')
# 可能上屏的 yaml 字段
UI_FIELDS = ('Title', 'Text', 'TooltipText', 'Tooltip', 'Label', 'CountdownText',
             'DisplayName', 'ShortName', 'Briefing')
# 地图元数据:改了会改变地图 UID(SHA1 覆盖 map.yaml / *.bin / *.lua / map.png),
# 会导致与未打补丁的玩家不兼容、旧录像找不到地图,因此默认不动。
MAP_META = ('Title', 'Author', 'Categories')
LUA_SCREEN = re.compile(r'SetMissionText\(\s*(["\'])(.+?)\1')


def walk(root):
    out = {}
    for dirpath, dirnames, filenames in os.walk(os.path.join(root, 'mods')):
        dirnames[:] = [d for d in dirnames if d != '.git']
        for name in filenames:
            path = os.path.join(dirpath, name)
            out[os.path.relpath(path, root).replace(os.sep, '/')] = path
    return out


def md5(path):
    with open(path, 'rb') as fh:
        return hashlib.md5(fh.read()).hexdigest()


def ftl_values(path):
    """把每个消息(含缩进续行)拼成完整取值,返回 [(key, 取值)]。"""
    out, cur, buf = [], None, []
    with open(path, encoding='utf-8', errors='replace') as fh:
        for line in fh:
            m = KEYLINE.match(line)
            if m:
                if cur:
                    out.append((cur, ' '.join(buf).strip()))
                cur, buf = m.group(1), [m.group(2)]
                continue
            m = ATTRLINE.match(line)
            if m and cur:
                out.append((cur, ' '.join(buf).strip()))
                cur, buf = f'{cur}.{m.group(1)}', [m.group(2)]
                continue
            if line.startswith(' ') and cur and line.strip():
                buf.append(line.strip())
            elif cur:
                out.append((cur, ' '.join(buf).strip()))
                cur, buf = None, []
    if cur:
        out.append((cur, ' '.join(buf).strip()))
    return out


def is_english(text):
    return bool(text) and not CJK.search(text) and re.search(r'[A-Za-z]{2,}', text)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--original', required=True)
    ap.add_argument('--patched', required=True)
    ap.add_argument('--examples', type=int, default=3)
    args = ap.parse_args()

    a, b = walk(args.original), walk(args.patched)

    left_ftl, hardcoded, lua_hits, known = {}, {}, {}, {}
    for rel in sorted(b):
        src = a.get(rel)
        if src is None:
            continue
        if rel.endswith('.ftl'):
            if md5(src) == md5(b[rel]):
                continue
            bad = [(k, v) for k, v in ftl_values(b[rel]) if is_english(v)]
            if bad:
                left_ftl[rel] = bad
            continue
        if rel.endswith(('.yaml', '.yml')):
            hits = []
            with open(b[rel], encoding='utf-8', errors='replace') as fh:
                for lineno, line in enumerate(fh, 1):
                    m = re.match(r'^\s*([-A-Za-z0-9_]+):\s*(.+)$', line.rstrip())
                    if not m:
                        continue
                    key, val = m.group(1), m.group(2).strip().strip('"\'')
                    if key not in UI_FIELDS or not is_english(val):
                        continue
                    if FLUENT_KEY.match(val) or val in ('True', 'False', 'true', 'false'):
                        continue
                    if len(val.split()) < 2:
                        continue
                    if key in MAP_META and '/maps/' in rel:
                        known.setdefault(f'{key}(地图元数据)', []).append((rel, lineno, val[:60]))
                        continue
                    hits.append((lineno, key, val[:70]))
            if hits:
                hardcoded[rel] = hits
            continue
        if rel.endswith('.lua') and md5(src) != md5(b[rel]):
            hits = []
            with open(b[rel], encoding='utf-8', errors='replace') as fh:
                for lineno, line in enumerate(fh, 1):
                    if line.strip().startswith('--'):
                        continue
                    for m in LUA_SCREEN.finditer(line):
                        if is_english(m.group(2)):
                            hits.append((lineno, m.group(2)[:70]))
            if hits:
                lua_hits[rel] = hits

    n = args.examples
    print('A. Fluent 条目里仍无汉字的')
    if not left_ftl:
        print('   (无)')
    for rel, bad in sorted(left_ftl.items()):
        print(f'   {rel}  —— {len(bad)} 条')
        for k, v in bad[:n]:
            print(f'       {k} = {v[:60]}')

    print('\nB. .ftl 之外、可能上屏的硬编码英文')
    if not hardcoded:
        print('   (无)')
    for rel, hits in sorted(hardcoded.items(), key=lambda kv: -len(kv[1])):
        print(f'   {rel}  —— {len(hits)} 处')
        for lineno, key, val in hits[:n]:
            print(f'       第 {lineno} 行 {key}: {val}')

    print('\nC. .lua 脚本里直接上屏的英文字面量')
    if not lua_hits:
        print('   (无)')
    for rel, hits in sorted(lua_hits.items()):
        print(f'   {rel}  —— {len(hits)} 处')
        for lineno, val in hits[:n]:
            print(f'       第 {lineno} 行: {val}')

    print('\nD. 已知且故意不改(附原因)')
    print('   地图元数据(每张地图 map.yaml 的 Title / Author / Categories):')
    total = sum(len(v) for v in known.values())
    if total:
        for label, items in sorted(known.items()):
            print(f'     {label}: {len(items)} 处,例:{items[0][2]}')
        print('     原因:地图 UID = SHA1(map.yaml + *.bin + *.lua + map.png),'
              '改这些字段会让打了补丁的玩家')
        print('           与未打补丁的玩家地图哈希不一致,旧录像也会找不到地图;'
              '任务列表里的英文标题即来自这里。')
    print('   其它:单位/玩家的内部标识(如 Ordos Main Base)、作者名(如 Westwood Studios)、'
          '品牌与缩写(GDI/Nod/APM/ID)。')

    print('\n汇总')
    print(f'   A 类残留条目:{sum(len(v) for v in left_ftl.values())} 条,'
          f'涉及 {len(left_ftl)} 个 .ftl')
    print(f'   B 类硬编码:{sum(len(v) for v in hardcoded.values())} 处,'
          f'涉及 {len(hardcoded)} 个文件')
    print(f'   C 类脚本字面量:{sum(len(v) for v in lua_hits.values())} 处')
    print(f'   D 类(不改):{total} 处')
    return 0


if __name__ == '__main__':
    sys.exit(main())
