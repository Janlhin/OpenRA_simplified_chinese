#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""把 `src/安装说明.md` 渲染成纯文本版 `src/安装说明.txt`。

为什么要有这个脚本
------------------
两份文件是**同一份内容**，过去靠手写维护，已经出过事：md 里改完忘了同步 txt，
结果 txt 里残留了字面 `**`（"没有校验，**顺序不能错**"）——键集合、占位符、
链接检查全都放过了，只有人眼能看出来。

现在反过来：**md 是唯一真相源**，txt 由本脚本生成，CI 用 `--check` 断言两者一致。
改说明只改 md，然后跑一次本脚本。

txt 的格式约束
--------------
目标运行环境是 Windows 记事本：

- **UTF-8 带 BOM**（老系统的 notepad 不认无 BOM 的 UTF-8，会显示乱码）
- **CRLF** 换行
- 段落按显示宽度折行（中日韩字符按 2 列计），否则一行 200 字要横向拖动
- 折行做禁则处理：`，。；：）` 等标点不落到行首，`<游戏目录>` 这类尖括号字段不拆开

支持的 Markdown 子集（够这份说明用，多了不写）：
`#` / `##` 标题、`---` 分隔线、`**粗体**`、`` `代码` ``、`> 引用`、
`- ` 与 `1. ` 列表、``` 围栏代码块、两列表格（第二列过长时降级成"条目 + 缩进说明"）。

用法::

    python tools/build_install_txt.py            # 生成/覆盖 src/安装说明.txt
    python tools/build_install_txt.py --check    # 只校验，不一致退出码 1
    python tools/build_install_txt.py --stdout   # 打到标准输出，便于肉眼比对
"""
import argparse
import os
import re
import sys
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'src', '安装说明.md')
DST = os.path.join(ROOT, 'src', '安装说明.txt')

BAR = '-' * 62
BAR_HEAVY = '=' * 62
WRAP = 78          # 正文折行宽度（显示列）
TABLE_NARROW = 40  # 第二列超过这个宽度，就降级成"条目 + 缩进说明"

BOLD = re.compile(r'\*\*(.+?)\*\*')
CODE = re.compile(r'`([^`]*)`')
TABLE_SEP = re.compile(r'^\|[\s:\-|]+\|$')
FENCE = re.compile(r'^```')
NUM = re.compile(r'^(\d+)\.\s+(.*)$')

# 折行时不允许出现在行首的标点（中文禁则）
NO_START = '，。、；：？！）〕】》」』”’·…%'

# 分词：尖括号字段整体保留（<游戏目录> 不能被拆），ASCII 词整体保留（路径/参数名），
# 其余按字符切（中日韩可任意断行）。
TOKEN = re.compile(r'<[^<>]*>|[A-Za-z0-9_\\/.:\-]+| +|.', re.S)


# ---------- 显示宽度 ----------

def dwidth(text):
    """按终端显示列计宽：CJK 全角算 2，其余算 1。"""
    return sum(2 if unicodedata.east_asian_width(c) in ('W', 'F') else 1 for c in text)


def pad(text, width):
    return text + ' ' * max(0, width - dwidth(text))


# ---------- 行内标记 ----------

def plain(text):
    """去掉行内 Markdown 标记，保留文字。顺序要紧：先剥代码再剥粗体。"""
    text = CODE.sub(r'\1', text)
    text = BOLD.sub(r'\1', text)
    return text.strip()


# ---------- 折行 ----------

def wrap(text, width=WRAP):
    out, cur, curw = [], '', 0
    for tok in TOKEN.findall(text):
        if not tok.strip():                     # 空白：转成单个空格，允许在此断行
            if curw == 0:
                continue
            cur, curw = cur + ' ', curw + 1
            continue
        w = dwidth(tok)
        if curw + w > width and cur.strip() and tok[0] not in NO_START:
            out.append(cur.rstrip())
            cur, curw = '', 0
        cur, curw = cur + tok, curw + w
    if cur.strip():
        out.append(cur.rstrip())
    return out or ['']


def emit(out, text, first='  ', cont=None, width=WRAP):
    """按首行/续行前缀输出一段，前缀宽度自动从行宽里扣掉。"""
    cont = first if cont is None else cont
    lines = wrap(text, width - max(dwidth(first), dwidth(cont)))
    for n, line in enumerate(lines):
        out.append(((first if n == 0 else cont) + line).rstrip())


# ---------- 结构块 ----------

def split_row(line):
    return [plain(c) for c in line.strip().strip('|').split('|')]


def render_table(rows, out):
    header, body = rows[0], rows[1:]
    col2 = max(dwidth(r[1]) for r in rows if len(r) > 1)
    if col2 > TABLE_NARROW:
        # 说明文字太长，横向对齐反而读不动：第一列做条目，第二列缩进成段
        for row in body:
            emit(out, '· ' + row[0], first='  ', cont='    ')
            emit(out, row[1], first='      ', cont='      ')
            out.append('')
        if out and out[-1] == '':
            out.pop()
        return
    col1 = max(dwidth(r[0]) for r in rows)
    col2w = max([dwidth(r[1]) for r in rows if len(r) > 1] + [0])
    out.append('  ' + pad(header[0], col1) + '  ' + header[1])
    out.append('  ' + '-' * (col1 + 2 + col2w))
    for row in body:
        right = row[1] if len(row) > 1 else ''
        out.append(('  ' + pad(row[0], col1) + '  ' + right).rstrip())


def render(md):
    lines = md.splitlines()
    i, out = 0, []

    # ---- 文件头：H1 + 紧随其后的段落（到第一个 --- 或 ## 为止）----
    title = ''
    while i < len(lines) and not lines[i].strip():
        i += 1
    if i < len(lines) and lines[i].startswith('# '):
        title = plain(lines[i][2:])
        i += 1

    subtitle = []
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        if line == '---' or line.startswith(('#', '>', '- ', '|')):
            break
        subtitle.append(plain(line))
        i += 1

    out.append(BAR_HEAVY)
    if title:
        out.append(' ' + title)
    for line in subtitle:
        out.append(' ' + line)
    out.append(BAR_HEAVY)
    out.append('')

    # ---- 正文 ----
    in_fence = False
    while i < len(lines):
        raw = lines[i].rstrip()
        line = raw.strip()

        if FENCE.match(line):
            in_fence = not in_fence
            i += 1
            continue
        if in_fence:                            # 围栏内容原样保留（提示词要能整段复制）
            out.append('    ' + raw if raw.strip() else '')
            i += 1
            continue

        if not line or line == '---':
            if out and out[-1] != '':
                out.append('')
            i += 1
            continue

        if line.startswith('## '):
            if out and out[-1] != '':
                out.append('')
            out.append(BAR)
            out.append(' ' + plain(line[3:]))
            out.append(BAR)
            out.append('')
            i += 1
            continue

        if line.startswith('|') and i + 1 < len(lines) and TABLE_SEP.match(lines[i + 1].strip()):
            rows = [split_row(line)]
            i += 2
            while i < len(lines) and lines[i].strip().startswith('|'):
                rows.append(split_row(lines[i]))
                i += 1
            render_table(rows, out)
            out.append('')
            continue

        if line.startswith('> '):
            emit(out, '※ ' + plain(line[2:]), first='  ', cont='    ')
            out.append('')
            i += 1
            continue

        m = NUM.match(line)
        if m:
            emit(out, '%s. %s' % (m.group(1), plain(m.group(2))), first='  ', cont='     ')
            i += 1
            continue

        if line.startswith('- '):
            emit(out, '· ' + plain(line[2:]), first='  ', cont='    ')
            i += 1
            continue

        emit(out, plain(line))
        i += 1

    while out and out[-1] == '':               # 收尾收敛成单个换行
        out.pop()
    return '\n'.join(out) + '\n'


def encode(text):
    """UTF-8 BOM + CRLF：记事本的兼容性要求，别改成纯 LF。"""
    return ('\ufeff' + text.replace('\n', '\r\n')).encode('utf-8')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--check', action='store_true', help='只校验，不写文件；不一致退出码 1')
    ap.add_argument('--stdout', action='store_true', help='打到标准输出，不写文件')
    args = ap.parse_args()

    with open(SRC, encoding='utf-8') as fh:
        md = fh.read()
    want = encode(render(md))

    if args.stdout:
        sys.stdout.write(want.decode('utf-8'))
        return 0

    if args.check:
        if not os.path.exists(DST):
            print('[失败] 缺少 %s，请运行 python tools/build_install_txt.py' % DST)
            return 1
        with open(DST, 'rb') as fh:
            have = fh.read()
        if have == want:
            print('安装说明.txt 与 安装说明.md 一致 ✓')
            return 0
        print('[失败] 安装说明.txt 与 md 的生成结果不一致')
        a = have.decode('utf-8', 'replace').replace('\r\n', '\n').splitlines()
        b = want.decode('utf-8', 'replace').replace('\r\n', '\n').splitlines()
        for n in range(max(len(a), len(b))):
            x = a[n] if n < len(a) else '<缺少>'
            y = b[n] if n < len(b) else '<多余>'
            if x != y:
                print('  首个差异在第 %d 行' % (n + 1))
                print('    实际: %s' % x)
                print('    应为: %s' % y)
                break
        print('  修法: python tools/build_install_txt.py')
        return 1

    with open(DST, 'wb') as fh:
        fh.write(want)
    print('已生成:', os.path.relpath(DST, ROOT).replace(os.sep, '/'))
    print('  %d 行 / %d 字节' % (want.count(b'\r\n'), len(want)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
