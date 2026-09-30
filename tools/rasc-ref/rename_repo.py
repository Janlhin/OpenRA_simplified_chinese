# -*- coding: utf-8 -*-
"""把仓库里的旧仓库名 OpenRA-simplified-chinese 换成 GitHub 上的真实仓库名
OpenRA_simplified_chinese，并填写 manifest.json 的 repository 字段。

字节级替换：保留各文件原有编码（.ps1 的 BOM）与换行符。
新旧名都是 25 字节，所以文件体积不变。

用法: python rename_repo.py <仓库根> [--apply]
"""
import json
import os
import sys

OLD = b'OpenRA-simplified-chinese'
NEW = b'OpenRA_simplified_chinese'
REPO_URL = 'https://github.com/Janlhin/OpenRA_simplified_chinese'

assert len(OLD) == len(NEW), '新旧名长度必须一致，否则体积会变'


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    apply = '--apply' in sys.argv
    root = args[0] if args else r'C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\openra-zh-cn'
    if not os.path.isdir(root):
        print('[错误] 根目录不存在:', root)
        return 2

    print(('APPLY   ' if apply else 'DRY-RUN ') + root)
    print('-' * 74)

    hits = []
    for dp, dn, fn in os.walk(root):
        parts = dp.split(os.sep)
        if '.git' in parts:
            continue
        for f in sorted(fn):
            p = os.path.join(dp, f)
            try:
                d = open(p, 'rb').read()
            except OSError as e:
                print('  !! 读取失败', p, e)
                continue
            n = d.count(OLD)
            if not n:
                continue
            rel = os.path.relpath(p, root).replace(os.sep, '/')
            hits.append((rel, n))
            if apply:
                open(p, 'wb').write(d.replace(OLD, NEW))

    by_ext = {}
    total = 0
    for rel, n in hits:
        ext = os.path.splitext(rel)[1] or '(无扩展名)'
        by_ext[ext] = by_ext.get(ext, 0) + 1
        total += n
    for ext in sorted(by_ext, key=lambda e: -by_ext[e]):
        print('  %-14s %3d 个文件' % (ext, by_ext[ext]))
    print('  合计 %d 个文件、%d 处' % (len(hits), total))
    for rel, n in hits:
        if not rel.endswith('.ftl'):
            print('     非 .ftl: %-30s x%d' % (rel, n))

    # manifest.json 的 repository 字段
    mp = os.path.join(root, 'manifest.json')
    m = json.load(open(mp, encoding='utf-8'))
    old_repo = m.get('repository')
    print('-' * 74)
    print('manifest.repository: %r -> %r' % (old_repo, REPO_URL))
    if apply:
        m['repository'] = REPO_URL
        with open(mp, 'w', encoding='utf-8', newline='\n') as fh:
            json.dump(m, fh, ensure_ascii=False, indent=2)
            fh.write('\n')
        print('已写入 manifest.json')
    return 0


if __name__ == '__main__':
    sys.exit(main())
