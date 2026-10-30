# -*- coding: utf-8 -*-
"""构建发布包：把仓库（不含 .git/）打成 OpenRA_simplified_chinese-<版本>.zip，
顶层带一个同名目录。可选 --verify：解压到临时目录并跑载荷校验，证明包内文件完好。

用法: python build_release.py [仓库根] [--out <zip路径>] [--verify]
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile

sys.stdout.reconfigure(encoding='utf-8')

# 固定时间戳 -> 同一个仓库内容每次都产出字节一致的 zip
ZIP_DT = (2026, 9, 30, 0, 0, 0)
TOP = 'OpenRA_simplified_chinese'


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
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    root = args[0] if args else r'C:\Users\Janlhin\Desktop\openra-zh-cn'
    verify = '--verify' in sys.argv
    manifest = json.load(open(os.path.join(root, 'manifest.json'), encoding='utf-8'))
    version = manifest['version']

    if '--out' in sys.argv:
        out = sys.argv[sys.argv.index('--out') + 1]
    else:
        out = os.path.join(os.path.dirname(root.rstrip(os.sep)),
                           'dist', '%s-%s.zip' % (TOP, version))
    os.makedirs(os.path.dirname(out), exist_ok=True)

    files = collect(root)
    with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
        for arc, full in files:
            zi = zipfile.ZipInfo(TOP + '/' + arc, date_time=ZIP_DT)
            zi.compress_type = zipfile.ZIP_DEFLATED
            zi.external_attr = 0o644 << 16
            z.writestr(zi, open(full, 'rb').read())

    data = open(out, 'rb').read()
    print('发布包:', out)
    print('  版本    :', version, '/ 引擎', manifest['engineVersion'])
    print('  条目    : %d 个文件（不含 .git/ 与 *.zip）' % len(files))
    print('  大小    : %d 字节 (%.1f KB)' % (len(data), len(data) / 1024))
    print('  sha256  :', hashlib.sha256(data).hexdigest())

    if not verify:
        return 0

    tmp = tempfile.mkdtemp(prefix='relverify-')
    try:
        with zipfile.ZipFile(out) as z:
            z.extractall(tmp)
        vroot = os.path.join(tmp, TOP)
        py = sys.executable
        print('解压自校验:', vroot)
        for name, cmd in (('载荷 ↔ manifest', [py, 'tools/verify_manifest.py']),
                          ('Fluent 规范', [py, 'tools/lint_ftl.py', 'files/mods']),
                          ('地图文案结构', [py, 'tools/struct_check_maps.py', 'files/mods'])):
            p = subprocess.run(cmd, cwd=vroot, capture_output=True, text=True)
            tail = (p.stdout or '').strip().splitlines()
            print('  [%s] %s | %s' % ('通过' if p.returncode == 0 else '失败',
                                      name, tail[-1] if tail else ''))
            if p.returncode != 0:
                print(p.stdout, p.stderr)
                return 1
        return 0
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
