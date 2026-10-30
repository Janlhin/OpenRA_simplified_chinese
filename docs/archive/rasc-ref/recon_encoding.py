# -*- coding: utf-8 -*-
"""只读侦察：目标文件的 BOM / 换行 / 编码，以及仓库地址线索。"""
import os, sys, re
sys.stdout.reconfigure(encoding='utf-8')

ROOT = r'C:\Users\Janlhin\Desktop\openra-zh-cn'

TARGETS = [
    'install.ps1',
    'verify-uninstall.bat',
    'install.bat',
    'uninstall.bat',
    'README.md',
    'CONTRIBUTING.md',
    'docs/ANATOMY.md',
    'docs/MAINTAINING.md',
    'manifest.json',
    'files/mods/ra/fluent/lua.ftl',
    'files/mods/ra/maps/allies-05a/map.ftl',
    'files/mods/ra/maps/allies-05b/map.ftl',
    'files/mods/ra/maps/allies-05c/map.ftl',
]

BOM = b'\xef\xbb\xbf'
CR = b'\r'
LF = b'\n'

print('==== 编码 / 换行 / 结尾 ====')
for rel in TARGETS:
    p = os.path.join(ROOT, rel.replace('/', os.sep))
    d = open(p, 'rb').read()
    crlf = d.count(CR + LF)
    lone_lf = d.count(LF) - crlf
    lone_cr = d.count(CR) - crlf
    kind = []
    if crlf and not lone_lf:
        kind.append('CRLF')
    elif lone_lf and not crlf:
        kind.append('LF')
    elif crlf and lone_lf:
        kind.append('MIXED(CRLF=%d,LF=%d)' % (crlf, lone_lf))
    if lone_cr:
        kind.append('lone-CR=%d' % lone_cr)
    print('%-42s %7d B  BOM=%-5s  %s  endswith-LF=%s' % (
        rel, len(d), str(d.startswith(BOM)), '/'.join(kind) or 'NO-EOL',
        str(d.endswith(LF))))

print()
print('==== 仓库地址线索（gitee/github URL）====')
pat = re.compile(r'https?://[^\s"\'<>)\]]*(?:gitee|github)[^\s"\'<>)\]]*')
hits = {}
for dp, dn, fn in os.walk(ROOT):
    for f in fn:
        if os.path.splitext(f)[1].lower() not in ('.md', '.json', '.yml', '.yaml', '.ps1', '.bat', '.py'):
            continue
        p = os.path.join(dp, f)
        try:
            t = open(p, encoding='utf-8', errors='replace').read()
        except OSError:
            continue
        for m in pat.findall(t):
            rel = os.path.relpath(p, ROOT)
            hits.setdefault(m, set()).add(rel)
for u in sorted(hits):
    print('  %s' % u)
    for r in sorted(hits[u]):
        print('      <- %s' % r)

print()
print('==== 本机 git/凭证线索 ====')
for p in [os.path.expanduser('~/.gitconfig'),
          os.path.expanduser('~/.git-credentials'),
          os.path.expanduser('~/.config/git/config')]:
    if os.path.isfile(p):
        print('  [存在]', p)
        try:
            print('    ', open(p, encoding='utf-8', errors='replace').read()[:600].replace('\n', '\n     '))
        except OSError:
            pass
    else:
        print('  [无]  ', p)
