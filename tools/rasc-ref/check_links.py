# -*- coding: utf-8 -*-
"""检查仓库内 Markdown 的相对链接是否都能解析到真实文件，锚点是否存在。

用法: python check_links.py <仓库根>
退出码 0 = 全部通过。
"""
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

LINK = re.compile(r'\[[^\]]*\]\(([^)\s]+)\)')
HEADING = re.compile(r'^(#{1,6})\s+(.*?)\s*$')


def slug(text):
    """近似 GitHub 的标题锚点算法：去反引号/标点，空格转连字符，转小写。"""
    t = text.replace('`', '')
    t = re.sub(r'[，。、；：！？（）【】《》""\'\'".,;:!?()\[\]{}<>/\\|+*=~^$%@#&]', '', t)
    t = t.strip().lower()
    t = re.sub(r'\s+', '-', t)
    return t


def collect_headings(path):
    out = set()
    with open(path, encoding='utf-8') as fh:
        for line in fh:
            m = HEADING.match(line)
            if m:
                out.add(slug(m.group(2)))
    return out


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else '.'
    root = os.path.abspath(root)
    mds = []
    for dp, dn, fn in os.walk(root):
        if os.sep + '.git' in dp:
            continue
        for f in fn:
            if f.lower().endswith('.md'):
                mds.append(os.path.join(dp, f))

    heading_cache = {}
    problems = []
    checked = 0
    for md in sorted(mds):
        rel = os.path.relpath(md, root).replace(os.sep, '/')
        own = collect_headings(md)
        heading_cache[md] = own
        with open(md, encoding='utf-8') as fh:
            for lineno, line in enumerate(fh, 1):
                for target in LINK.findall(line):
                    if target.startswith(('http://', 'https://', 'mailto:')):
                        continue
                    checked += 1
                    path_part, _, frag = target.partition('#')
                    if not path_part:  # 纯锚点，指向本文档
                        if frag and slug(frag) not in own:
                            problems.append('%s:%d 锚点不存在: #%s' % (rel, lineno, frag))
                        continue
                    dest = os.path.normpath(os.path.join(os.path.dirname(md), path_part))
                    if not os.path.exists(dest):
                        problems.append('%s:%d 目标不存在: %s' % (rel, lineno, path_part))
                        continue
                    if frag and dest.lower().endswith('.md'):
                        if dest not in heading_cache:
                            heading_cache[dest] = collect_headings(dest)
                        if slug(frag) not in heading_cache[dest]:
                            problems.append('%s:%d 锚点不存在: %s#%s' % (rel, lineno, path_part, frag))

    print('扫描 %d 个 Markdown,检查 %d 条相对链接' % (len(mds), checked))
    if problems:
        print('问题 %d 处:' % len(problems))
        for p in problems:
            print('  -', p)
        return 1
    print('全部通过')
    return 0


if __name__ == '__main__':
    sys.exit(main())
