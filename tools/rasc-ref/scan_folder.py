# -*- coding: utf-8 -*-
"""只读扫描 openra-zh-cn 文件夹，输出结构/体积/垃圾候选/双副本差异报告。
绝不修改任何文件。"""
import os, sys, hashlib
from collections import defaultdict

sys.stdout.reconfigure(encoding='utf-8')

ROOTS = {
    'DESKTOP ': r'C:\Users\Janlhin\Desktop\openra-zh-cn',
    'WORKAREA': r'C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\openra-zh-cn',
}

JUNK_NAMES = {'Thumbs.db', 'Desktop.ini', '.DS_Store'}
JUNK_DIRS  = {'__pycache__', '.vscode', '.idea', 'node_modules', '_zhcn-backup'}
JUNK_EXTS  = {'.pyc', '.pyo', '.bak', '.orig', '.tmp', '.temp', '.log', '.swp', '.zip'}


def human(n):
    x = float(n)
    for u in ('B', 'KB', 'MB', 'GB'):
        if x < 1024:
            return f'{x:.0f}{u}' if u == 'B' else f'{x:.1f}{u}'
        x /= 1024
    return f'{x:.1f}TB'


def scan(root):
    files, dirs, total = [], [], 0
    junk = defaultdict(list)
    for dp, dn, fn in os.walk(root):
        rel = os.path.relpath(dp, root)
        if rel != '.':
            dirs.append(rel)
        # 标记垃圾目录
        for d in list(dn):
            if d in JUNK_DIRS:
                junk['dir:' + d].append(os.path.join(rel, d) if rel != '.' else d)
        for f in fn:
            p = os.path.join(dp, f)
            try:
                sz = os.path.getsize(p)
            except OSError:
                continue
            r = os.path.relpath(p, root)
            files.append((r, sz))
            total += sz
            if f in JUNK_NAMES:
                junk['name:' + f].append(r)
            if os.path.splitext(f)[1].lower() in JUNK_EXTS:
                junk['ext:' + os.path.splitext(f)[1].lower()].append(r)
    return files, dirs, total, junk


def sha(p):
    try:
        with open(p, 'rb') as fh:
            return hashlib.sha256(fh.read()).hexdigest()
    except OSError:
        return None


results = {}
for tag, root in ROOTS.items():
    if not os.path.isdir(root):
        print(f'!! {tag} 不存在: {root}')
        continue
    files, dirs, total, junk = scan(root)
    results[tag] = (root, files, dirs, total, junk)

for tag in ROOTS:
    if tag not in results:
        continue
    root, files, dirs, total, junk = results[tag]
    print('=' * 78)
    print(f'{tag} {root}')
    print('=' * 78)
    print(f'是否 git 仓库: {"是 (有 .git)" if os.path.isdir(os.path.join(root, ".git")) else "否"}')
    print(f'文件总数: {len(files)}   目录总数: {len(dirs)}   总大小: {human(total)}')
    print()

    # 顶层条目
    tops = defaultdict(lambda: [0, 0])
    for r, s in files:
        top = r.split(os.sep)[0]
        tops[top][0] += 1
        tops[top][1] += s
    print('-- 顶层条目（文件数 / 大小）--')
    for k in sorted(tops, key=lambda k: -tops[k][1]):
        kind = 'DIR ' if k in dirs else 'FILE'
        print(f'   {kind} {k:<34} {tops[k][0]:>4} 个  {human(tops[k][1]):>9}')
    print()

    # 各二级目录
    subs = defaultdict(lambda: [0, 0])
    for r, s in files:
        parts = r.split(os.sep)
        key = os.sep.join(parts[:2]) if len(parts) > 1 else '(root)'
        subs[key][0] += 1
        subs[key][1] += s
    print('-- 二级目录明细（文件数 / 大小）--')
    for k in sorted(subs, key=lambda k: -subs[k][1])[:40]:
        print(f'   {k:<44} {subs[k][0]:>4} 个  {human(subs[k][1]):>9}')
    print()

    # 扩展名统计
    ext = defaultdict(lambda: [0, 0])
    for r, s in files:
        e = os.path.splitext(r)[1].lower() or '(无扩展名)'
        ext[e][0] += 1
        ext[e][1] += s
    print('-- 扩展名分布 --')
    for e in sorted(ext, key=lambda e: -ext[e][0]):
        print(f'   {e:<16} {ext[e][0]:>4} 个  {human(ext[e][1]):>9}')
    print()

    # 最大文件
    print('-- 最大文件 TOP 15 --')
    for r, s in sorted(files, key=lambda x: -x[1])[:15]:
        print(f'   {human(s):>9}  {r}')
    print()

    # 垃圾候选
    print('-- 垃圾/冗余候选（仅列出，未删除）--')
    if not junk:
        print('   (无)')
    for k in sorted(junk):
        lst = junk[k]
        print(f'   [{k}] {len(lst)} 项')
        for x in lst[:12]:
            print(f'        {x}')
        if len(lst) > 12:
            print(f'        ... 其余 {len(lst)-12} 项')
    print()

    # 空目录
    empties = []
    for d in dirs:
        fp = os.path.join(root, d)
        if not os.listdir(fp):
            empties.append(d)
    print(f'-- 空目录: {len(empties)} 个 --')
    for d in empties[:20]:
        print(f'   {d}')
    print()

# 双副本差异
if 'DESKTOP ' in results and 'WORKAREA' in results:
    print('=' * 78)
    print('双副本差异（桌面 vs 工作区）')
    print('=' * 78)
    dr, df, _, _, _ = results['DESKTOP ']
    wr, wf, _, _, _ = results['WORKAREA']
    dm = {r: s for r, s in df}
    wm = {r: s for r, s in wf}
    only_d = sorted(set(dm) - set(wm))
    only_w = sorted(set(wm) - set(dm))
    print(f'仅在桌面: {len(only_d)}   仅在工作区: {len(only_w)}')
    for x in only_d[:20]:
        print(f'   [仅桌面] {x}')
    for x in only_w[:20]:
        print(f'   [仅工作区] {x}')
    common = sorted(set(dm) & set(wm))
    diff = []
    for r in common:
        if dm[r] != wm[r]:
            diff.append(r)
        elif dm[r] < 5_000_000:
            if sha(os.path.join(dr, r)) != sha(os.path.join(wr, r)):
                diff.append(r)
    print(f'\n同名但内容不同: {len(diff)}')
    for x in diff[:30]:
        print(f'   {x}')
