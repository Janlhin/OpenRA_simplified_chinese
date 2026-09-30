# -*- coding: utf-8 -*-
"""构建发布包：把仓库（不含 .git/ 与 *.zip）打成 `<仓库名>-<版本>.zip`。

- 顶层带一个同名目录，用户解压到一个英文路径即可（与 README 的说明一致）。
- zip 时间戳取自 manifest.json 的 releaseDate，所以**同一个仓库内容每次产出字节一致的包**。
- `--verify` 会把包解压到临时目录并跑一遍载荷校验，证明包内文件完好。

用法:
    python tools/build_release.py [--out <zip路径>] [--verify]
"""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def collect(root):
    out = []
    for dp, dn, fn in os.walk(root):
        parts = os.path.relpath(dp, root).split(os.sep)
        if parts and parts[0] == '.git':
            dn[:] = []
            continue
        dn.sort()
        for f in sorted(fn):
            if f.lower().endswith('.zip'):
                continue
            full = os.path.join(dp, f)
            out.append((os.path.relpath(full, root).replace(os.sep, '/'), full))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default=REPO, help='仓库根（默认本脚本所在仓库）')
    ap.add_argument('--out', help='输出 zip 路径（默认 dist/<仓库名>-<版本>.zip）')
    ap.add_argument('--verify', action='store_true', help='解压并跑载荷校验')
    args = ap.parse_args()

    root = os.path.abspath(args.repo)
    manifest = json.load(open(os.path.join(root, 'manifest.json'), encoding='utf-8'))
    version = manifest['version']
    top = manifest['name']
    y, m, d = (int(x) for x in manifest['releaseDate'].split('-'))
    dt = (y, m, d, 0, 0, 0)

    out = args.out or os.path.join(root, 'dist', '%s-%s.zip' % (top, version))
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)

    files = collect(root)
    with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
        for arc, full in files:
            zi = zipfile.ZipInfo(top + '/' + arc, date_time=dt)
            zi.compress_type = zipfile.ZIP_DEFLATED
            zi.external_attr = 0o644 << 16
            z.writestr(zi, open(full, 'rb').read())

    blob = open(out, 'rb').read()
    print('发布包:', out)
    print('  版本    :', version, '/ 引擎', manifest['engineVersion'])
    print('  条目    : %d 个文件（不含 .git/ 与 *.zip）' % len(files))
    print('  大小    : %d 字节 (%.1f KB)' % (len(blob), len(blob) / 1024))
    print('  sha256  :', hashlib.sha256(blob).hexdigest())

    if not args.verify:
        print('(未加 --verify，跳过解压自校验)')
        return 0

    tmp = tempfile.mkdtemp(prefix='relverify-')
    try:
        with zipfile.ZipFile(out) as z:
            z.extractall(tmp)
        vroot = os.path.join(tmp, top)
        checks = [('载荷 ↔ manifest.json', ['tools/verify_manifest.py']),
                  ('Fluent 规范', ['tools/lint_ftl.py', 'files/mods']),
                  ('地图文案结构', ['tools/struct_check_maps.py', 'files/mods']),
                  ('Markdown 链接', ['tools/check_links.py', '.'])]
        print('解压自校验:', vroot)
        for name, cmd in checks:
            p = subprocess.run([sys.executable] + cmd, cwd=vroot,
                               capture_output=True, text=True)
            tail = (p.stdout or '').strip().splitlines()
            print('  [%s] %s%s' % ('通过' if p.returncode == 0 else '失败', name,
                                   ' | ' + tail[-1] if tail else ''))
            if p.returncode != 0:
                print(p.stdout or '', p.stderr or '')
                return 1
        return 0
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
