# -*- coding: utf-8 -*-
"""构建发布包：`<仓库名>-<版本>.zip`。

默认**只打玩家需要的文件**（白名单），研发资产（tools/、docs/、.github/、
CONTRIBUTING 等）留在仓库里，不进包。玩家解压后看到的布局：

    setup.cmd / README.md / 安装说明.txt / 安装说明.md / LICENSE / LICENSE-OFL.txt
    bin/install.ps1 / bin/manifest.json      ← 脚本与清单收进 bin/
    files/**                                 ← 208 个文本载荷
    fonts/**                                 ← Noto Sans SC 两个字重

`--dev` 打全量快照（除 .git/、dist/、*.zip），给内部复现问题用。

包是**确定性**的：zip 内时间戳取自 manifest.json 的 releaseDate，
同一份仓库内容每次产出字节一致的 zip。

`--verify` 把包解压到临时目录后**在包内自带校验**（不依赖 tools/，因为发布包
不含 tools/）：入口文件是否齐全、bin/manifest.json 是否与仓库一致、208 个载荷的
size/sha256 是否对得上、files/ 里有没有多余文件。

用法:
    python tools/build_release.py [--out <zip路径>] [--verify] [--dev]
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import sys
import tempfile
import zipfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 发布包白名单：改这里等于改「玩家拿到什么」
RELEASE_FILES = ('setup.cmd', '安装说明.txt', '安装说明.md', 'LICENSE', 'LICENSE-OFL.txt')
RELEASE_DIRS = ('files', 'fonts')

# 仓库路径 -> 包内路径（脚本与清单统一收进 bin\，顶层只留入口与说明）
#
# PACKAGE-README.md 是**包内**那份 README 的源文件：它的链接只指向 zip 里确实存在的
# 文件，与仓库首页（README.md，面向读源码的人）分开维护。包里它就叫 README.md。
PACKAGE_LAYOUT = {
    'install.ps1': 'bin/install.ps1',
    'manifest.json': 'bin/manifest.json',
    'PACKAGE-README.md': 'README.md',
}


def sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def walk_dir(root, sub):
    out = []
    base = os.path.join(root, sub)
    for dp, dn, fn in os.walk(base):
        dn.sort()
        for f in sorted(fn):
            out.append(os.path.relpath(os.path.join(dp, f), root).replace(os.sep, '/'))
    return out


def collect(root, dev=False):
    if dev:
        out = []
        for dp, dn, fn in os.walk(root):
            parts = os.path.relpath(dp, root).split(os.sep)
            if parts and parts[0] in ('.git', 'dist'):
                dn[:] = []
                continue
            dn.sort()
            for f in sorted(fn):
                if f.lower().endswith('.zip'):
                    continue
                out.append(os.path.relpath(os.path.join(dp, f), root).replace(os.sep, '/'))
        return sorted(out)

    missing = [f for f in list(RELEASE_FILES) + list(PACKAGE_LAYOUT) if not os.path.exists(os.path.join(root, f))]
    if missing:
        raise SystemExit('白名单里的文件在仓库中不存在：%s' % ', '.join(missing))
    out = list(RELEASE_FILES) + list(PACKAGE_LAYOUT)
    for d in RELEASE_DIRS:
        if not os.path.isdir(os.path.join(root, d)):
            raise SystemExit('白名单目录不存在：%s' % d)
        out += walk_dir(root, d)
    return sorted(out)


def package_path(rel):
    return PACKAGE_LAYOUT.get(rel, rel)


LINK = re.compile(r'\[[^\]]*\]\(([^)\s]+)\)')


def check_package_links(vroot):
    """包内 Markdown 的相对链接必须指向包里真实存在的文件。

    仓库里 check_links.py 只保证"在仓库里能解析"——README 一旦被放进 zip，
    指向 CONTRIBUTING.md / docs/ 的链接就全成了死链，而仓库侧完全看不出来。
    """
    problems = []
    for name in sorted(os.listdir(vroot)):
        if not name.lower().endswith(('.md', '.txt')):
            continue
        path = os.path.join(vroot, name)
        if not os.path.isfile(path):
            continue
        text = open(path, encoding='utf-8', errors='ignore').read()
        for target in set(LINK.findall(text)):
            if target.startswith(('http://', 'https://', 'mailto:', '#')):
                continue
            rel = target.split('#')[0]
            if not os.path.exists(os.path.join(vroot, rel.replace('/', os.sep))):
                problems.append('包内死链：%s 里的 %s' % (name, target))
    return problems


def verify_package(vroot, root, manifest):
    """在解压出的包上做自校验，返回问题列表（空 = 通过）。"""
    problems = []

    required = [package_path(f) for f in list(RELEASE_FILES) + list(PACKAGE_LAYOUT)]
    for name in required:
        if not os.path.exists(os.path.join(vroot, name.replace('/', os.sep))):
            problems.append('缺少入口文件：%s' % name)

    pkg_manifest = os.path.join(vroot, package_path('manifest.json').replace('/', os.sep))
    if os.path.exists(pkg_manifest):
        if sha256(pkg_manifest) != sha256(os.path.join(root, 'manifest.json')):
            problems.append('包内 manifest.json 与仓库不一致（请重新构建）')

    listed = set()
    for entry in manifest['files']:
        rel = entry['path']                      # 相对 files/（例如 mods/ra/fluent/ra.ftl）
        listed.add('files/' + rel)
        path = os.path.join(vroot, 'files', rel.replace('/', os.sep))
        if not os.path.exists(path):
            problems.append('载荷缺失：%s' % rel)
            continue
        size = os.path.getsize(path)
        if size != entry['size']:
            problems.append('大小不符：%s（实际 %d，清单 %d）' % (rel, size, entry['size']))
        if sha256(path) != entry['sha256']:
            problems.append('哈希不符：%s' % rel)

    problems.extend(check_package_links(vroot))

    if os.path.isdir(os.path.join(vroot, 'files')):
        for rel in walk_dir(vroot, 'files'):     # 相对包根，形如 files/mods/...
            if rel not in listed:
                problems.append('多余载荷：%s' % rel)

    # 随包字体：路径、大小、哈希都要与 manifest 的 font.bundled 对得上
    for font in (manifest.get('font') or {}).get('bundled', []):
        rel = font['path']
        path = os.path.join(vroot, rel.replace('/', os.sep))
        if not os.path.exists(path):
            problems.append('字体缺失：%s' % rel)
            continue
        if os.path.getsize(path) != font['size']:
            problems.append('字体大小不符：%s' % rel)
        if sha256(path) != font['sha256']:
            problems.append('字体哈希不符：%s' % rel)

    return problems


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default=REPO, help='仓库根（默认本脚本所在仓库）')
    ap.add_argument('--out', help='输出 zip 路径（默认 dist/<仓库名>-<版本>.zip）')
    ap.add_argument('--verify', action='store_true', help='解压并做包内自校验')
    ap.add_argument('--dev', action='store_true', help='打全量快照（含 tools/docs 等研发资产）')
    args = ap.parse_args()

    root = os.path.abspath(args.repo)
    with open(os.path.join(root, 'manifest.json'), encoding='utf-8') as fh:
        manifest = json.load(fh)
    version = manifest['version']
    top = manifest['name']
    y, m, d = (int(x) for x in manifest['releaseDate'].split('-'))
    dt = (y, m, d, 0, 0, 0)

    name = '%s-%s%s.zip' % (top, version, '-dev' if args.dev else '')
    out = args.out or os.path.join(root, 'dist', name)
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)

    files = collect(root, dev=args.dev)
    with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
        for rel in files:
            arc = top + '/' + (rel if args.dev else package_path(rel))
            zi = zipfile.ZipInfo(arc, date_time=dt)
            zi.compress_type = zipfile.ZIP_DEFLATED
            zi.external_attr = 0o644 << 16
            with open(os.path.join(root, rel.replace('/', os.sep)), 'rb') as fh:
                z.writestr(zi, fh.read())

    size = os.path.getsize(out)
    print('发布包:', out)
    print('  模式    :', '全量快照(--dev)' if args.dev else '玩家包(白名单)')
    print('  版本    :', version, '/ 引擎', manifest['engineVersion'])
    print('  条目    : %d 个文件' % len(files))
    print('  大小    : %d 字节 (%.1f KB)' % (size, size / 1024))
    print('  sha256  :', sha256(out))

    if not args.verify:
        print('(未加 --verify，跳过解压自校验)')
        return 0

    tmp = tempfile.mkdtemp(prefix='relverify-')
    try:
        with zipfile.ZipFile(out) as z:
            z.extractall(tmp)
        vroot = os.path.join(tmp, top)
        print('解压自校验:', vroot)
        problems = verify_package(vroot, root, manifest)
        if problems:
            for p in problems[:20]:
                print('  [失败] ' + p)
            if len(problems) > 20:
                print('  ...共 %d 个问题' % len(problems))
            return 1
        print('  [通过] 入口文件齐全，bin/manifest.json 与仓库一致')
        print('  [通过] 随包字体 %d 个，size+sha256 与 manifest 一致' % len((manifest.get('font') or {}).get('bundled', [])))
        print('  [通过] %d 个载荷 size+sha256 全部一致，无多余文件' % len(manifest['files']))
        print('  [通过] 包内 Markdown/TXT 的相对链接都落在包里')
        return 0
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
