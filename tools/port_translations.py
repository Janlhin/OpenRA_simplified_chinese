# -*- coding: utf-8 -*-
"""引擎升级后把旧译文迁移到新版英文目录(不依赖游戏本体,任意平台可跑)。

思路:**结构一律取新版英文文件,取值取自旧译文**。这样上游新增、删除、重排消息都不会漏,
需要人工处理的只剩两类:①新版新增的 key;②英文原文改过的 key(译文可能已过时)。

用法:
    python tools/port_translations.py \
        --old-english   "旧版英文目录/mods"        # 例:git 旧 tag 的 mods/ 树
        --old-payload   "files/mods"               # 本仓库旧版载荷(带 SPDX 头的译文)
        --new-english   "新版安装目录/mods"        # 新引擎的英文原版
        --out           "../stage/patched/mods"    # 输出:待人工补译的译文树
        [--font-from "common|FreeSans.ttf" --font-to "common|NotoSansSC-Regular.ttf"]
        [--translations new.tsv] [--fix fix.tsv]

    new.tsv : 文件 <TAB> 键[.属性] <TAB> 译文        (译文内用 \\n 表示换行)
    fix.tsv : 文件 <TAB> 消息键 <TAB> 旧行 <TAB> 新行 (在该消息块内精确替换;新行留空即删除该行)

输出报告(与 --out 同级):
    port_untranslated.tsv  仍需翻译的键
    port_changed.txt       英文原文变过的键(附旧译文,供复核)
    port_placeholder.txt   译文与英文占位符不一致的键(必须改)
    port_manual.txt        需要人工处理的非 .ftl 文件
"""
import argparse
import os
import re
import sys

KEY_RE = re.compile(r'^(-?[A-Za-z][A-Za-z0-9_-]*)\s*=')
ATTR_RE = re.compile(r'^\s+\.([A-Za-z][A-Za-z0-9_-]*)\s*=')
VAR_RE = re.compile(r'\{\s*\$([A-Za-z0-9_-]+)')
SEL_RE = re.compile(r'\{[^{}]*->')
SPDX = '## OpenRA 简体中文汉化补丁'


def read_text(path, strip_spdx=False):
    with open(path, 'rb') as fh:
        raw = fh.read()
    if raw.startswith(b'\xef\xbb\xbf'):
        raw = raw[3:]
    text = raw.decode('utf-8').replace('\r\n', '\n').replace('\r', '\n')
    if strip_spdx and text.startswith(SPDX):
        lines = text.split('\n')
        if len(lines) > 2 and lines[1].startswith('##'):
            text = '\n'.join(lines[2:])
    return text


def parse_ftl(text):
    """→ (items, msgs);items 保留行序,msgs: key -> {keyline, value, attrs, attr_order}"""
    lines = text.split('\n')
    items, msgs = [], {}
    i = 0
    while i < len(lines):
        m = KEY_RE.match(lines[i])
        if m and not lines[i].startswith(' '):
            key, keyline = m.group(1), lines[i]
            body, attr_order, attrs, cur = [], [], {}, None
            i += 1
            while i < len(lines):
                l = lines[i]
                if l.strip() == '':
                    j = i
                    while j < len(lines) and lines[j].strip() == '':
                        j += 1
                    if j < len(lines) and lines[j].startswith(' ') and not lines[j].lstrip().startswith('#'):
                        (attrs[cur] if cur else body).append('')
                        i += 1
                        continue
                    break
                if not l.startswith(' '):
                    break
                a = ATTR_RE.match(l)
                if a:
                    cur = a.group(1)
                    attr_order.append(cur)
                    attrs[cur] = [l]
                elif cur is None:
                    body.append(l)
                else:
                    attrs[cur].append(l)
                i += 1
            msgs[key] = {'keyline': keyline, 'value': body, 'attrs': attrs, 'attr_order': attr_order}
            items.append(('msg', key))
            continue
        items.append(('raw', lines[i]))
        i += 1
    return items, msgs


def value_text(msg):
    parts = [msg['keyline'].split('=', 1)[1] if '=' in msg['keyline'] else ''] + msg['value']
    return '\n'.join(parts).strip()


def attr_text(msg, a):
    lines = msg['attrs'][a]
    return ('\n'.join([lines[0].split('=', 1)[1] if '=' in lines[0] else ''] + lines[1:])).strip()


def port_ftl(new_text, pay_text, old_text, rel, report):
    items, new_msgs = parse_ftl(new_text)
    pay_msgs = parse_ftl(pay_text)[1] if pay_text else {}
    old_msgs = parse_ftl(old_text)[1] if old_text else {}
    out = []
    for kind, payload in items:
        if kind == 'raw':
            out.append(payload)
            continue
        key, nm = payload, new_msgs[payload]
        if key not in pay_msgs:
            out.append(nm['keyline'])
            out.extend(nm['value'])
            for a in nm['attr_order']:
                out.extend(nm['attrs'][a])
            report['untranslated'].append((rel, key, value_text(nm)))
            continue
        pm = pay_msgs[key]
        out.append('%s =%s' % (key, pm['keyline'].split('=', 1)[1] if '=' in pm['keyline'] else ''))
        out.extend(pm['value'])
        for a in nm['attr_order']:
            if a in pm['attrs']:
                out.extend(pm['attrs'][a])
                if key in old_msgs and a in old_msgs[key]['attrs'] and \
                        attr_text(old_msgs[key], a) != attr_text(nm, a):
                    report['changed'].append((rel, '%s.%s' % (key, a), attr_text(old_msgs[key], a),
                                             attr_text(nm, a), attr_text(pm, a)))
            else:
                out.extend(nm['attrs'][a])
                report['untranslated'].append((rel, '%s.%s' % (key, a), attr_text(nm, a)))
        for a in pm['attr_order']:
            if a not in nm['attr_order']:
                report['stale'].append((rel, '%s.%s' % (key, a)))
        if key in old_msgs and value_text(old_msgs[key]) != value_text(nm):
            report['changed'].append((rel, key, value_text(old_msgs[key]), value_text(nm), value_text(pm)))
        pv, nv = set(VAR_RE.findall(value_text(pm))), set(VAR_RE.findall(value_text(nm)))
        if pv != nv or bool(SEL_RE.search(value_text(pm))) != bool(SEL_RE.search(value_text(nm))):
            report['placeholder'].append((rel, key, sorted(pv), sorted(nv)))
    return '\n'.join(out)


def blocks(lines):
    out, i = {}, 0
    while i < len(lines):
        m = KEY_RE.match(lines[i])
        if m and not lines[i].startswith(' '):
            key, start = m.group(1), i
            i += 1
            while i < len(lines):
                l = lines[i]
                if l.strip() == '':
                    j = i
                    while j < len(lines) and lines[j].strip() == '':
                        j += 1
                    if j < len(lines) and lines[j].startswith(' ') and not lines[j].lstrip().startswith('#'):
                        i = j
                        continue
                    break
                if not l.startswith(' '):
                    break
                i += 1
            out[key] = (start, i)
            continue
        i += 1
    return out


def set_value(path, key, value):
    value = value.replace('\\n', '\n')   # 译表里用 \n 表示换行,不能原样写进 .ftl
    lines = open(path, encoding='utf-8').read().split('\n')
    bl = blocks(lines)
    msg, _, attr = key.partition('.')
    if msg not in bl:
        return 'missing-key'
    start, end = bl[msg]
    if attr:
        for i in range(start, end):
            m = ATTR_RE.match(lines[i])
            if m and m.group(1) == attr:
                lines[i] = '%s = %s' % (lines[i][:lines[i].index('=')].rstrip(), value)
                break
        else:
            return 'missing-attr'
    else:
        parts = value.split('\n')
        # 跟随英文原块的形状:原本把首段写在 `键 =` 后面就继续写在后面,原本首行为空则整体缩进
        inline = bool(lines[start].split('=', 1)[1].strip()) if '=' in lines[start] else False
        if len(parts) > 1 and not inline:
            new_block = ['%s =' % msg]
            new_block += [('    ' + p).rstrip() if p.strip() else '    ' for p in parts]
        else:
            new_block = ['%s = %s' % (msg, parts[0].rstrip())]
            new_block += [('    ' + p).rstrip() if p.strip() else '    ' for p in parts[1:]]
        keep = [l for l in lines[start + 1:end] if ATTR_RE.match(l)]
        lines[start:end] = new_block[:1] + keep + new_block[1:]
    open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines))
    return 'ok'


def replace_in_block(path, key, old, new):
    lines = open(path, encoding='utf-8').read().split('\n')
    bl = blocks(lines)
    base = key.split('.')[0]
    start, end = bl[base]
    hit = [i for i in range(start, end) if lines[i] == old]
    if len(hit) != 1:
        return False
    if new == '':
        del lines[hit[0]]
    else:
        lines[hit[0]] = new
    open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines))
    return True


def walk_ftl(root):
    out = []
    for base, _, files in os.walk(root):
        for fn in files:
            if fn.endswith('.ftl'):
                p = os.path.join(base, fn)
                out.append(os.path.relpath(p, root).replace('\\', '/'))
    return sorted(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--old-english', required=True)
    ap.add_argument('--old-payload', required=True)
    ap.add_argument('--new-english', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--font-from')
    ap.add_argument('--font-to')
    ap.add_argument('--translations')
    ap.add_argument('--fix')
    args = ap.parse_args()

    outdir = os.path.abspath(args.out)
    os.makedirs(outdir, exist_ok=True)
    report = {'untranslated': [], 'changed': [], 'placeholder': [], 'stale': [], 'manual': []}

    def w(rel, text):
        dst = os.path.join(outdir, rel.replace('/', os.sep))
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, 'w', encoding='utf-8', newline='\n').write(text)

    def rd(root, rel, strip=False):
        p = os.path.join(root, rel.replace('/', os.sep))
        return read_text(p, strip_spdx=strip) if os.path.exists(p) else None

    for rel in walk_ftl(args.new_english):
        pay = rd(args.old_payload, rel, strip=True)
        w(rel, port_ftl(rd(args.new_english, rel), pay, rd(args.old_english, rel), rel, report))

    # 非 .ftl:mod.yaml 用新版作底稿(可替换字体),其余仅当新旧英文完全一致时才复用旧载荷
    for base, _, files in os.walk(args.old_payload):
        for fn in files:
            if fn.endswith('.ftl'):
                continue
            p = os.path.join(base, fn)
            rel = os.path.relpath(p, args.old_payload).replace('\\', '/')
            if rel.endswith('mod.yaml'):
                text = rd(args.new_english, rel).rstrip('\n') + '\n'
                if args.font_from and args.font_to:
                    for src in [s.strip() for s in args.font_from.split(',') if s.strip()]:
                        text = text.replace(src, args.font_to)
                w(rel, text)
            elif rd(args.old_english, rel) == rd(args.new_english, rel):
                w(rel, read_text(p, strip_spdx=True))
            else:
                report['manual'].append(rel)

    # 应用人工译文
    if args.translations and os.path.exists(args.translations):
        bad = 0
        for line in open(args.translations, encoding='utf-8-sig').read().split('\n'):
            if not line.strip():
                continue
            rel, key, value = line.split('\t')
            if set_value(os.path.join(outdir, rel.replace('/', os.sep)), key, value) != 'ok':
                print('[译表未命中] %s :: %s' % (rel, key))
                bad += 1
    else:
        bad = 0
    if args.fix and os.path.exists(args.fix):
        fixbad = 0
        for line in open(args.fix, encoding='utf-8-sig').read().split('\n'):
            if not line.strip():
                continue
            parts = line.split('\t')
            rel, key, old = parts[0], parts[1], parts[2]
            new = parts[3] if len(parts) > 3 else ''
            if not replace_in_block(os.path.join(outdir, rel.replace('/', os.sep)), key, old, new):
                print('[修正未命中] %s :: %s :: %r' % (rel, key, old))
                fixbad += 1
    else:
        fixbad = 0

    base_out = os.path.dirname(outdir)
    with open(os.path.join(base_out, 'port_untranslated.tsv'), 'w', encoding='utf-8') as fh:
        for rel, key, en in report['untranslated']:
            fh.write('%s\t%s\t%s\n' % (rel, key, en.replace('\n', '\\n')))
    with open(os.path.join(base_out, 'port_changed.txt'), 'w', encoding='utf-8') as fh:
        for rel, key, o, n, cn in report['changed']:
            fh.write('%s\t%s\n  OLD: %s\n  NEW: %s\n  CN : %s\n' % (
                rel, key, o.replace('\n', '\\n'), n.replace('\n', '\\n'), cn.replace('\n', '\\n')))
    with open(os.path.join(base_out, 'port_placeholder.txt'), 'w', encoding='utf-8') as fh:
        for rel, key, a, b in report['placeholder']:
            fh.write('%s\t%s\t译文=%s\t英文=%s\n' % (rel, key, a, b))
    with open(os.path.join(base_out, 'port_manual.txt'), 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(report['manual']) + '\n')

    print('译文树已生成:%s' % outdir)
    print('待翻译 %d 条,英文变更 %d 条,占位符不一致 %d 条,非 .ftl 待人工 %d 个'
          % (len(report['untranslated']), len(report['changed']), len(report['placeholder']), len(report['manual'])))
    if bad or fixbad:
        print('译表/修正有 %d + %d 条未命中,请检查' % (bad, fixbad))
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
