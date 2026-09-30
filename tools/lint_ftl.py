# -*- coding: utf-8 -*-
"""Fluent 载荷基础规范检查(不依赖游戏本体,可在任意平台跑)。

检查每个 .ftl:
  - 不带 UTF-8 BOM、以换行结尾、无 CRLF;
  - 缩进只用空格,不用制表符;
  - 顶层非空行必须是 `键 = ...` 或注释(`##` / `#`),不允许出现"掉到第 0 列的值行";
  - 每条消息的花括号配对平衡。

用法: python tools/lint_ftl.py [根目录]     # 默认 files/mods
退出码 0 表示通过。
"""
import os
import re
import sys

# 消息 `key = ...` 与术语 `-term = ...` 都是顶层定义,术语以单个 `-` 开头
KEYLINE = re.compile(r'^(-?[A-Za-z][A-Za-z0-9_-]*)\s*=(.*)$')


def check(path):
    problems = []
    with open(path, 'rb') as fh:
        raw = fh.read()
    if raw.startswith(b'\xef\xbb\xbf'):
        problems.append('文件带 UTF-8 BOM')
    if b'\r\n' in raw:
        problems.append('含 CRLF 换行')
    if not raw.endswith(b'\n'):
        problems.append('文件未以换行结尾')
    text = raw.decode('utf-8', errors='replace')

    cur = None
    braces = 0
    for lineno, line in enumerate(text.split('\n'), 1):
        if line.startswith('\t'):
            problems.append(f'第 {lineno} 行用制表符缩进')
            continue
        if line.strip() == '' or line.startswith(' '):
            braces += line.count('{') - line.count('}')
            continue
        if line.startswith('#'):
            if cur and braces:
                problems.append(f'{cur}:花括号不配对')
            cur, braces = None, 0
            continue
        m = KEYLINE.match(line)
        if not m:
            problems.append(f'第 {lineno} 行既不是注释也不是 `键 =`:{line[:50]!r}')
            continue
        if cur and braces:
            problems.append(f'{cur}:花括号不配对')
        cur = m.group(1)
        braces = m.group(2).count('{') - m.group(2).count('}')
    if cur and braces:
        problems.append(f'{cur}:花括号不配对')
    return problems


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'files', 'mods')
    if not os.path.isdir(root):
        print(f'[错误] 目录不存在:{root}')
        return 1
    total = bad = 0
    for dirpath, _dirnames, filenames in os.walk(root):
        for name in sorted(filenames):
            if not name.endswith('.ftl'):
                continue
            total += 1
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, root)
            for p in check(path):
                print(f'[{rel}] {p}')
                bad += 1
    print(f'Fluent 载荷检查:{total} 个文件,问题 {bad} 处')
    return 0 if bad == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
