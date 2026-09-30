# -*- coding: utf-8 -*-
"""仓库内容清点：逐项列出作用说明所需的原始信息（只读）。"""
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
ROOT = r'C:\Users\Janlhin\Desktop\openra-zh-cn'

print('==== 根目录文件 ====')
for f in sorted(os.listdir(ROOT)):
    p = os.path.join(ROOT, f)
    if os.path.isfile(p):
        print('  %-24s %8d B' % (f, os.path.getsize(p)))

print()
print('==== .github 内容 ====')
for dp, dn, fn in os.walk(os.path.join(ROOT, '.github')):
    for f in sorted(fn):
        print('  ', os.path.relpath(os.path.join(dp, f), ROOT).replace(os.sep, '/'))

print()
print('==== tools/ 各脚本 docstring 首行 ====')
td = os.path.join(ROOT, 'tools')
for f in sorted(os.listdir(td)):
    if not f.endswith('.py'):
        continue
    src = open(os.path.join(td, f), encoding='utf-8').read()
    m = re.search(r'"""(.*?)"""', src, re.S)
    lines = [l.strip() for l in (m.group(1).splitlines() if m else []) if l.strip()]
    first = lines[0] if lines else '(无 docstring)'
    print('  %-26s %6d B  %s' % (f, os.path.getsize(os.path.join(td, f)), first))

print()
print('==== files/mods 骨架（每个 mod 的文件名统计）====')
base = os.path.join(ROOT, 'files', 'mods')
for mod in sorted(os.listdir(base)):
    md = os.path.join(base, mod)
    if not os.path.isdir(md):
        continue
    names, subs, total = {}, set(), 0
    for dp, dn, fn in os.walk(md):
        for f in fn:
            total += 1
            names[f] = names.get(f, 0) + 1
            rel = os.path.relpath(dp, md)
            if rel != '.':
                subs.add(rel.split(os.sep)[0])
    print('  %-15s %3d 文件   子目录: %s' % (mod + '/', total, ' '.join(sorted(subs)) or '-'))
    for k in sorted(names, key=lambda k: (-names[k], k)):
        print('        %-24s x%d' % (k, names[k]))
