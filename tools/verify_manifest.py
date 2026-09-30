# -*- coding: utf-8 -*-
"""校验 files/ 里的载荷与 manifest.json 是否逐字节一致。

用途:
  - 贡献者在提交前自检;
  - CI 每次提交自动跑一遍,防止有人改了译文却忘了同步哈希;
  - 顺带守住"补丁包不含字体"这条授权红线。

用法:
    python tools/verify_manifest.py [仓库根目录]
退出码 0 表示一致。
"""
import hashlib
import json
import os
import sys

FONT_EXT = ('.ttf', '.ttc', '.otf')


def main():
    if len(sys.argv) > 1:
        root = os.path.abspath(sys.argv[1])
    else:
        root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    manifest_path = os.path.join(root, 'manifest.json')
    payload = os.path.join(root, 'files')
    if not os.path.exists(manifest_path):
        print(f'[错误] 找不到 {manifest_path}')
        return 1

    with open(manifest_path, encoding='utf-8') as fh:
        manifest = json.load(fh)

    problems = 0
    listed = set()
    for entry in manifest['files']:
        rel = entry['path']
        listed.add(rel)
        if rel.lower().endswith(FONT_EXT):
            print(f'[违规] 载荷里不应包含字体文件:{rel}')
            problems += 1
            continue
        path = os.path.join(payload, rel.replace('/', os.sep))
        if not os.path.exists(path):
            print(f'[缺失] {rel}')
            problems += 1
            continue
        with open(path, 'rb') as fh:
            data = fh.read()
        if len(data) != entry['size']:
            print(f'[大小不符] {rel}:manifest 记录 {entry["size"]},实际 {len(data)}')
            problems += 1
        if hashlib.sha256(data).hexdigest() != entry['sha256']:
            print(f'[哈希不符] {rel}')
            problems += 1

    for dirpath, _dirnames, filenames in os.walk(payload):
        for name in filenames:
            rel = os.path.relpath(os.path.join(dirpath, name), payload).replace(os.sep, '/')
            if rel not in listed:
                print(f'[未登记] files/{rel} 存在但 manifest.json 没有记录')
                problems += 1

    stats = manifest.get('stats', {})
    print(f"载荷 {len(listed)} 个文件,问题 {problems} 处")
    print(f"补丁版本 {manifest.get('version')} / 适配引擎 {manifest.get('engineVersion')} / "
          f"许可 {manifest.get('license')}")
    if stats:
        print(f"统计 {stats}")
    print('全部一致' if problems == 0 else '校验未通过')
    return 0 if problems == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
