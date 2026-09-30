# -*- coding: utf-8 -*-
"""地图 .ftl 结构校验(不依赖第三方库)。

检查项:
  1. 顶层只有两种行:注释(## / #)或 `键 = ...`;不允许出现"意外掉到第 0 列"的值行
     —— 那会让 Fluent 把一段文字当成新消息,是最容易犯的错。
  2. 消息键集合与英文原文完全一致(不增不减)。
  3. 原文里非空的取值,译文不能为空。
  4. 缩进统一用空格、文件以换行结尾。

用法:
    python struct_check_maps.py <mods 目录> [<英文原版 mods 目录>]
给出第二个参数时额外比对键集合;只给一个参数则只做自检(CI 用这个模式,不需要游戏本体)。
"""
import os
import re
import sys

KEYLINE = re.compile(r'^(-?[A-Za-z][A-Za-z0-9_-]*)\s*=(.*)$')


def parse(path):
    """返回 {key: [value_lines]},以及结构问题列表。"""
    problems = []
    msgs = {}
    cur = None
    with open(path, encoding='utf-8', errors='replace') as fh:
        raw = fh.read()
    if not raw.endswith('\n'):
        problems.append('文件未以换行结尾')
    for lineno, line in enumerate(raw.split('\n'), 1):
        if line.strip() == '':
            if cur:
                msgs[cur].append('')
            continue
        if line.startswith('\t'):
            problems.append(f'第 {lineno} 行用制表符缩进')
            continue
        if line.startswith(' '):
            if cur is None:
                problems.append(f'第 {lineno} 行是缩进行但前面没有键')
            else:
                msgs[cur].append(line.strip())
            continue
        if line.startswith('#'):
            cur = None
            continue
        m = KEYLINE.match(line)
        if not m:
            problems.append(f'第 {lineno} 行既不是注释也不是 `键 =`:{line[:60]!r}')
            continue
        cur = m.group(1)
        msgs[cur] = []
        inline = m.group(2).strip()
        if inline:
            msgs[cur].append(inline)
    return msgs, problems


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    compare = len(sys.argv) > 2
    src_root, dst_root = (sys.argv[2], sys.argv[1]) if compare else (None, sys.argv[1])
    total = bad = 0
    for mod in ('ra', 'cnc', 'd2k'):
        for dirpath, _dn, fn in os.walk(os.path.join(dst_root, mod, 'maps')):
            for f in fn:
                if f != 'map.ftl':
                    continue
                dst = os.path.join(dirpath, f)
                rel = os.path.relpath(dst, dst_root)
                total += 1
                b, probs = parse(dst)
                for p in probs:
                    print(f'[结构] {rel}: {p}')
                bad += len(probs)
                if compare:
                    a, _ = parse(os.path.join(src_root, rel))
                    if set(a) != set(b):
                        print(f'[键集合不一致] {rel}: 缺 {sorted(set(a) - set(b))} '
                              f'多 {sorted(set(b) - set(a))}')
                        bad += 1
                    for k in a:
                        if a[k] and not b.get(k):
                            print(f'[取值为空] {rel}: {k}')
    mode = '含键集合比对' if compare else '自检'
    print(f'地图 .ftl 结构校验({mode}):{total} 个文件,问题 {bad} 处')
    return 0 if bad == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
