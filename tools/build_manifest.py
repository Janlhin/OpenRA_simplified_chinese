# -*- coding: utf-8 -*-
"""维护者工具:比对"英文原版安装目录"与"汉化后的安装目录",重新生成 files/ 与 manifest.json。

这样生成载荷的好处是:不靠手工维护文件清单,改动多了也不会漏文件。

用法:
    python tools/build_manifest.py --original "C:/Program Files/OpenRA (playtest)" \
                                   --patched  "C:/Users/你/OpenRA-CN" \
                                   [--version 1.3.1] [--engine playtest-20260222] \
                                   [--date 2026-10-01] [--dry-run]

注意:
  - 只收集 mods/ 下的文本文件;字体(.ttf/.ttc/.otf)一律排除,补丁不分发字体。
  - 所有 .ftl 会加上 SPDX 许可头后写入 files/。
"""
import argparse
import datetime
import hashlib
import json
import os
import shutil
import sys

SPDX_HEADER = (
    "## OpenRA 简体中文汉化补丁 (SPDX-License-Identifier: GPL-3.0-or-later)\n"
    "## 中文译文:OpenRA_simplified_chinese 项目贡献;原始英文文案版权归 OpenRA 项目 (GPL-3.0) 所有。\n"
)
FONT_EXT = ('.ttf', '.ttc', '.otf')


def walk_mods(root):
    out = {}
    for dirpath, _dirnames, filenames in os.walk(os.path.join(root, 'mods')):
        for name in filenames:
            path = os.path.join(dirpath, name)
            out[os.path.relpath(path, root).replace(os.sep, '/')] = path
    return out


def md5(path):
    with open(path, 'rb') as fh:
        return hashlib.md5(fh.read()).hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--original', required=True, help='英文原版安装目录')
    ap.add_argument('--patched', required=True, help='汉化后的安装目录')
    ap.add_argument('--repo', default=os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    ap.add_argument('--version')
    ap.add_argument('--engine')
    ap.add_argument('--date')
    ap.add_argument('--dry-run', action='store_true')
    args = ap.parse_args()

    repo = os.path.abspath(args.repo)
    payload = os.path.join(repo, 'files')
    manifest_path = os.path.join(repo, 'manifest.json')

    with open(manifest_path, encoding='utf-8') as fh:
        manifest = json.load(fh)
    if args.version:
        manifest['version'] = args.version
    if args.engine:
        manifest['engineVersion'] = args.engine
    manifest['releaseDate'] = args.date or datetime.date.today().isoformat()

    original, patched = walk_mods(args.original), walk_mods(args.patched)
    changed = []
    for rel, path in sorted(patched.items()):
        if rel.lower().endswith(FONT_EXT):
            continue
        other = original.get(rel)
        if other is None or md5(path) != md5(other):
            changed.append(rel)

    print(f'改动文件 {len(changed)} 个:')
    for rel in changed:
        mark = '' if rel in original else '  (新增)'
        print(f'  {rel}{mark}')
    if args.dry_run:
        print('干跑结束,未写任何文件')
        return 0

    if os.path.isdir(payload):
        shutil.rmtree(payload)
    entries = []
    for rel in changed:
        src = os.path.join(args.patched, rel.replace('/', os.sep))
        dst = os.path.join(payload, rel.replace('/', os.sep))
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if rel.endswith('.ftl'):
            with open(src, encoding='utf-8') as fh:
                body = fh.read()
            with open(dst, 'w', encoding='utf-8', newline='') as fh:
                fh.write(SPDX_HEADER + body)
        else:
            shutil.copy2(src, dst)
        with open(dst, 'rb') as fh:
            data = fh.read()
        entries.append({'path': rel, 'size': len(data),
                        'sha256': hashlib.sha256(data).hexdigest()})

    manifest['files'] = entries
    manifest.setdefault('stats', {})
    manifest['stats']['payloadFiles'] = len(entries)
    with open(manifest_path, 'w', encoding='utf-8', newline='\n') as fh:
        json.dump(manifest, fh, ensure_ascii=False, indent=2)
        fh.write('\n')
    print(f'载荷 {len(entries)} 个文件已重建,manifest.json 已更新(版本 {manifest["version"]})')
    print('别忘了同步 README/CHANGELOG 里的数字,并跑一遍 tools/verify_manifest.py')
    return 0


if __name__ == '__main__':
    sys.exit(main())
