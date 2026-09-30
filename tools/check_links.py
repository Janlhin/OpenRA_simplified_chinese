# -*- coding: utf-8 -*-
"""检查仓库内 Markdown 的相对链接是否都能解析到真实文件、锚点是否存在。

用途：`docs/` 下的文档引用仓库根目录的文件时必须写 `../README.md`，
写成 `README.md` 会静默指向不存在的 `docs/README.md`。CI 会跑这个脚本挡住这类错误。

用法: python tools/check_links.py [仓库根]      # 省略则以本脚本所在仓库为根
退出码 0 = 全部通过。
"""
import os
import re
import sys

LINK = re.compile(r'\[[^\]]*\]\(([^)\s]+)\)')
HEADING = re.compile(r'^(#{1,6})\s+(.*?)\s*$')
# GitHub 生成锚点时会剥掉这些标点（保留中日韩字符与字母数字）
PUNCT = re.compile(r'[，。、；：！？（）【】《》""\'\'".,;:!?()\[\]{}<>/\\|+*=~^$%@#&]')


def slug(text):
    """近似 GitHub 的标题锚点算法。"""
    t = PUNCT.sub('', text.replace('`', '')).strip().lower()
    return re.sub(r'\s+', '-', t)


def collect_headings(path):
    out = set()
    with open(path, encoding='utf-8') as fh:
        for line in fh:
            m = HEADING.match(line)
            if m:
                out.add(slug(m.group(2)))
    return out


def main():
    if len(sys.argv) > 1:
        root = os.path.abspath(sys.argv[1])
    else:
        root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    if not os.path.isdir(root):
        print('[错误] 目录不存在:', root)
        return 2

    mds = []
    for dp, dn, fn in os.walk(root):
        if os.sep + '.git' in dp + os.sep:
            continue
        mds += [os.path.join(dp, f) for f in fn if f.lower().endswith('.md')]

    headings = {}
    problems = []
    checked = 0
    for md in sorted(mds):
        rel = os.path.relpath(md, root).replace(os.sep, '/')
        own = collect_headings(md)
        headings[md] = own
        with open(md, encoding='utf-8') as fh:
            for lineno, line in enumerate(fh, 1):
                for target in LINK.findall(line):
                    if target.startswith(('http://', 'https://', 'mailto:')):
                        continue
                    checked += 1
                    path_part, _, frag = target.partition('#')
                    if not path_part:                       # 纯锚点，指向本文档
                        if frag and slug(frag) not in own:
                            problems.append('%s:%d 锚点不存在: #%s' % (rel, lineno, frag))
                        continue
                    dest = os.path.normpath(os.path.join(os.path.dirname(md), path_part))
                    if not os.path.exists(dest):
                        problems.append('%s:%d 目标不存在: %s' % (rel, lineno, path_part))
                        continue
                    if frag and dest.lower().endswith('.md'):
                        if dest not in headings:
                            headings[dest] = collect_headings(dest)
                        if slug(frag) not in headings[dest]:
                            problems.append('%s:%d 锚点不存在: %s#%s'
                                            % (rel, lineno, path_part, frag))

    print('Markdown 链接检查:%d 个文件、%d 条相对链接' % (len(mds), checked))
    if problems:
        for p in problems:
            print('  [问题]', p)
        print('问题 %d 处' % len(problems))
        return 1
    print('全部通过')
    return 0


if __name__ == '__main__':
    sys.exit(main())
