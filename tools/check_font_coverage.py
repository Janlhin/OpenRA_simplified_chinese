# -*- coding: utf-8 -*-
"""校验「载荷里出现的每个字符，字体都画得出来」。

背景:补丁随包带一份固定字体。译文里一旦出现字体没有的字符,界面上就是一个方块/空白,
而 .ftl 语法、引擎的 --check-yaml 都不会报错——只有人眼能发现。这个脚本把这件事变成 CI 断言。

用法:
    python tools/check_font_coverage.py [--payload files] [--font fonts/NotoSansSC-Regular.ttf]
                                        [--extra 字体2.ttf ...]

需要 fonttools(pip install fonttools);CI 里装一次即可。
退出码 0 = 全覆盖;1 = 有缺字(逐条列出)。
"""
import argparse
import os
import sys

try:
    from fontTools.ttLib import TTFont
except ImportError:
    print('[错误] 需要 fonttools:pip install fonttools')
    sys.exit(2)

TEXT_EXT = ('.ftl', '.yaml', '.lua', '.md', '.txt')


def collect_chars(root):
    """返回 {字符: 首次出现的相对路径}"""
    seen = {}
    for base, _dirs, files in os.walk(root):
        for fn in sorted(files):
            if not fn.lower().endswith(TEXT_EXT):
                continue
            path = os.path.join(base, fn)
            rel = os.path.relpath(path, root).replace('\\', '/')
            with open(path, encoding='utf-8', errors='replace') as fh:
                for ch in fh.read():
                    if ch in '\r\n\t':
                        continue
                    if ord(ch) < 0x20:
                        continue
                    seen.setdefault(ch, rel)
    return seen


def font_cmap(path):
    font = TTFont(path, lazy=True, fontNumber=0)
    try:
        return set(font.getBestCmap().keys())
    finally:
        font.close()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--payload', default='files')
    ap.add_argument('--font', action='append', default=[],
                    help='要检查的字体(可重复;默认 fonts/NotoSansSC-Regular.ttf 与 -Bold.ttf)')
    ap.add_argument('--repo', default=os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    args = ap.parse_args()

    repo = os.path.abspath(args.repo)
    payload = os.path.join(repo, args.payload)
    fonts = args.font or [os.path.join('fonts', 'NotoSansSC-Regular.ttf'),
                          os.path.join('fonts', 'NotoSansSC-Bold.ttf')]

    if not os.path.isdir(payload):
        print('[错误] 载荷目录不存在:%s' % payload)
        return 2

    chars = collect_chars(payload)
    print('载荷用到的不同字符:%d 个' % len(chars))

    bad = 0
    for rel in fonts:
        path = os.path.join(repo, rel)
        if not os.path.exists(path):
            print('[错误] 字体不存在:%s' % rel)
            bad += 1
            continue
        cmap = font_cmap(path)
        missing = sorted(ch for ch in chars if ord(ch) not in cmap)
        if missing:
            bad += 1
            print('[缺字] %s 缺 %d 个字符:' % (rel, len(missing)))
            for ch in missing[:50]:
                print('    U+%04X %s   （首次出现:%s）' % (ord(ch), ch, chars[ch]))
            if len(missing) > 50:
                print('    ...共 %d 个' % len(missing))
        else:
            print('[通过] %s 覆盖全部 %d 个字符' % (rel, len(chars)))

    return 0 if bad == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
