# -*- coding: utf-8 -*-
"""openra-zh-cn 仓库「一致性清理」4 项，一次落地。默认 dry-run，加 --apply 才写盘。

用法: python apply_cleanup.py <仓库根> [--apply]

修的东西:
  1. 4 个载荷 .ftl 由 CRLF 归一化为 LF（其余 192 个载荷本来就是 LF）
  2. install.ps1 的窗口标题不再写死版本，改为从 manifest.json 动态读
  3. verify-uninstall.bat 改为「纯 ASCII + CRLF」，与 install/uninstall.bat 一致
  4. README.md / CONTRIBUTING.md 里残留的旧版本号改为当前版本

编码纪律:
  - .ps1 必须保住 UTF-8 BOM + CRLF（否则 PowerShell 5.1 会把中文读成乱码）
  - .bat 纯 ASCII + CRLF
  - .ftl/.md 一律 LF、无 BOM、以换行结尾
"""
import os
import sys

BOM = b'\xef\xbb\xbf'

CRLF_FTL = [
    'files/mods/ra/fluent/lua.ftl',
    'files/mods/ra/maps/allies-05a/map.ftl',
    'files/mods/ra/maps/allies-05b/map.ftl',
    'files/mods/ra/maps/allies-05c/map.ftl',
]

VERSION = '1.3.1'

NEW_BAT_LINES = [
    '@echo off',
    'chcp 65001 >nul',
    'setlocal',
    'title OpenRA Simplified Chinese Patch - Verify Uninstall',
    'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -Verify %*',
    'set "RC=%ERRORLEVEL%"',
    'echo.',
    'if "%RC%"=="0" (echo [OK] Patch fully uninstalled) else (echo [FAIL] Patch files still present - see report above)',
    'echo.',
    'echo Press any key to close this window . . .',
    'pause >nul',
    'endlocal',
]


def eol_of(text):
    return '\r\n' if '\r\n' in text else '\n'


def read_bytes(p):
    with open(p, 'rb') as fh:
        return fh.read()


def write_bytes(p, data):
    with open(p, 'wb') as fh:
        fh.write(data)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    apply = '--apply' in sys.argv
    root = args[0] if args else \
        r'C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\openra-zh-cn'
    if not os.path.isdir(root):
        print('[错误] 根目录不存在:', root)
        return 2

    print(('APPLY   ' if apply else 'DRY-RUN ') + root)
    print('-' * 74)
    problems = []
    changed = []

    # ---- 1. 载荷 .ftl: CRLF -> LF -------------------------------------
    for rel in CRLF_FTL:
        p = os.path.join(root, rel.replace('/', os.sep))
        if not os.path.isfile(p):
            problems.append('缺文件 ' + rel)
            continue
        d = read_bytes(p)
        n_crlf = d.count(b'\r\n')
        lone = d.count(b'\n') - n_crlf
        if n_crlf == 0:
            print('  [1] 跳过(已是 LF) %s' % rel)
            continue
        if lone:
            problems.append('换行混杂,不敢动: %s (CRLF=%d, LF=%d)' % (rel, n_crlf, lone))
            continue
        new = d.replace(b'\r\n', b'\n')
        assert not new.startswith(BOM), rel
        assert new.endswith(b'\n'), rel
        print('  [1] %-42s CRLF->LF  %d -> %d B' % (rel, len(d), len(new)))
        changed.append(rel)
        if apply:
            write_bytes(p, new)

    # ---- 2. install.ps1 标题动态化 -------------------------------------
    rel = 'install.ps1'
    p = os.path.join(root, rel)
    d = read_bytes(p)
    had_bom = d.startswith(BOM)
    text = d.decode('utf-8-sig')
    eol = eol_of(text)
    old = "    Title 'OpenRA 简体中文汉化补丁  v1.3.0'"
    new = ("    $ver = if ($manifest) { $manifest.version } else { '?' }" + eol +
           '    Title "OpenRA 简体中文汉化补丁  v$ver"')
    cnt = text.count(old)
    if cnt == 0:
        if '$manifest.version' in text:
            print('  [2] 跳过(标题已动态化) %s' % rel)
        else:
            problems.append('install.ps1 里没找到写死的标题行')
    elif cnt > 1:
        problems.append('install.ps1 标题行出现 %d 次,预期 1 次' % cnt)
    else:
        text = text.replace(old, new, 1)
        out = text.encode('utf-8')
        if had_bom:
            out = BOM + out
        print('  [2] %-42s 标题 v1.3.0 -> v$ver（动态读 manifest）' % rel)
        print('      BOM 保留=%s  换行=%s  %d -> %d B' %
              (had_bom, 'CRLF' if eol == '\r\n' else 'LF', len(d), len(out)))
        changed.append(rel)
        if apply:
            write_bytes(p, out)

    # ---- 3. verify-uninstall.bat 纯 ASCII + CRLF -----------------------
    rel = 'verify-uninstall.bat'
    p = os.path.join(root, rel)
    d = read_bytes(p)
    try:
        d.decode('ascii')
        already_ascii = True
    except UnicodeDecodeError:
        already_ascii = False
    body = ('\r\n'.join(NEW_BAT_LINES) + '\r\n').encode('ascii')
    if d == body:
        print('  [3] 跳过(已是纯 ASCII + CRLF) %s' % rel)
    elif already_ascii:
        print('  [3] %-42s 仅换行归一化 -> CRLF' % rel)
        changed.append(rel)
        if apply:
            write_bytes(p, body)
    else:
        print('  [3] %-42s 中文 -> ASCII, 换行 -> CRLF  (%d -> %d B)' %
              (rel, len(d), len(body)))
        changed.append(rel)
        if apply:
            write_bytes(p, body)

    # ---- 4. 文档残留旧版本号 -------------------------------------------
    doc_edits = [
        ('README.md', 'OpenRA 简体中文汉化补丁 1.2.0',
         'OpenRA 简体中文汉化补丁 ' + VERSION),
        ('CONTRIBUTING.md', '--version 1.3.0', '--version ' + VERSION),
    ]
    for rel, old, new in doc_edits:
        p = os.path.join(root, rel)
        d = read_bytes(p)
        text = d.decode('utf-8')
        cnt = text.count(old)
        if cnt == 0:
            problems.append('%s 里没找到 %r' % (rel, old))
            continue
        if cnt > 1:
            problems.append('%s 里 %r 出现 %d 次' % (rel, old, cnt))
            continue
        text2 = text.replace(old, new, 1)
        out = text2.encode('utf-8')
        assert not out.startswith(BOM), rel
        assert out.endswith(b'\n'), rel
        print('  [4] %-42s %s -> %s' % (rel, old[-6:], new[-6:]))
        changed.append(rel)
        if apply:
            write_bytes(p, out)

    print('-' * 74)
    print('计划改动 %d 个文件' % len(set(changed)))
    if problems:
        print('!! 需要人工确认的问题 %d 处:' % len(problems))
        for x in problems:
            print('   -', x)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
