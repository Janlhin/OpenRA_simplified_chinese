# -*- coding: utf-8 -*-
"""维护者工具:比对"英文原版安装目录"与"汉化后的安装目录",重新生成 files/ 与 manifest.json。

这样生成载荷的好处是:不靠手工维护文件清单,改动多了也不会漏文件。

用法:
    python tools/build_manifest.py --original "C:/Program Files/OpenRA (playtest)" \
                                   --patched  "C:/Users/你/OpenRA-CN" \
                                   [--version 1.3.1] [--engine playtest-20260222] \
                                   [--date 2026-10-01] [--dry-run]

注意:
  - 只收集 mods/ 下的文本文件;字体不进载荷——它们在 fonts/,由安装器单独部署。
  - 所有 .ftl 会加上 SPDX 许可头后写入 files/。
  - manifest.json 的 stats 三项也在这里**按固定口径重算**,不再手填(口径见 docs/MAINTAINING.md):
      fluentMessages = 非地图 .ftl 的顶层消息条数(不含术语 `-term` 与属性)
      installerTitles = `*-content/installer/*.yaml` 的顶层节点条数
      mapBriefings   = 含 `briefing` 消息的 `maps/*/map.ftl` 个数
"""
import argparse
import datetime
import hashlib
import json
import os
import re
import shutil
import sys

SPDX_HEADER = (
    "## OpenRA 简体中文汉化补丁 (SPDX-License-Identifier: GPL-3.0-or-later)\n"
    "## 中文译文:OpenRA_simplified_chinese 项目贡献;原始英文文案版权归 OpenRA 项目 (GPL-3.0) 所有。\n"
)
FONT_EXT = ('.ttf', '.ttc', '.otf')
FLUENT_KEY = re.compile(r'^(-?[A-Za-z][A-Za-z0-9_-]*)\s*=', re.M)
INSTALLER_NODE = re.compile(r'^[A-Za-z0-9_]+:\s', re.M)


def compute_stats(payload, entries):
    """按固定口径统计载荷规模(见模块文档)。"""
    msgs = briefs = titles = 0
    for entry in entries:
        rel = entry['path']
        path = os.path.join(payload, rel.replace('/', os.sep))
        with open(path, encoding='utf-8') as fh:
            text = fh.read()
        if rel.endswith('/map.ftl'):
            if re.search(r'^briefing\s*=', text, re.M):
                briefs += 1
        elif rel.endswith('.ftl'):
            msgs += sum(1 for m in FLUENT_KEY.finditer(text) if not m.group(1).startswith('-'))
        elif '/installer/' in rel and rel.endswith('.yaml'):
            titles += len(INSTALLER_NODE.findall(text))
    return {'fluentMessages': msgs, 'installerTitles': titles, 'mapBriefings': briefs}



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
    manifest_path = os.path.join(repo, 'src', 'manifest.json')

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
    stats = compute_stats(payload, entries)
    manifest['stats'] = {
        'fluentMessages': stats['fluentMessages'],
        'installerTitles': stats['installerTitles'],
        'mapBriefings': stats['mapBriefings'],
        'payloadFiles': len(entries),
    }
    with open(manifest_path, 'w', encoding='utf-8', newline='\n') as fh:
        json.dump(manifest, fh, ensure_ascii=False, indent=2)
        fh.write('\n')
    print(f'载荷 {len(entries)} 个文件已重建,manifest.json 已更新(版本 {manifest["version"]})')
    print('统计: %s' % manifest['stats'])
    print('别忘了同步 README/CHANGELOG 里的数字,并跑一遍 tools/verify_manifest.py')
    return 0


if __name__ == '__main__':
    sys.exit(main())
