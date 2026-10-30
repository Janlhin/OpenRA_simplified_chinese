#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""把 manifest.json 里的载荷清单渲染进 README.md 的附录,并校验它没走样。

为什么要有这个脚本:README 里"包里有什么"如果手写,改一次载荷就要人肉同步一次,
而这种清单**最容易悄悄过期**——玩家照着 README 数文件,数和实际对不上,就没人再信它了。
所以清单由 manifest.json 生成,`--check` 在 CI 里断言 README 与 manifest 一致。

渲染进 README 的那一段用两个标记包起来,只替换标记之间的内容:

    <!-- INVENTORY:BEGIN 由 tools/build_readme_inventory.py 生成,勿手改 -->
    ...
    <!-- INVENTORY:END -->

用法:
    python tools/build_readme_inventory.py            # 写入 README.md
    python tools/build_readme_inventory.py --check    # 只校验,不写;不一致退出码 1
    python tools/build_readme_inventory.py --stdout   # 打到标准输出,便于肉眼比对
"""
import argparse
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
README = os.path.join(ROOT, 'README.md')
MANIFEST = os.path.join(ROOT, 'manifest.json')

BEGIN = '<!-- INVENTORY:BEGIN 由 tools/build_readme_inventory.py 生成,勿手改 -->'
END = '<!-- INVENTORY:END -->'

# 载荷里各 mod 目录的展示顺序(玩家视角:先通用,再三个游戏,最后内容安装器)
GROUP_ORDER = ['common', 'ra', 'cnc', 'd2k',
               'ra-content', 'cnc-content', 'd2k-content', 'common-content']
GROUP_TITLE = {
    'common': '三个游戏共用',
    'ra': '红色警戒',
    'cnc': '泰伯利亚黎明',
    'd2k': '沙丘 2000',
    'ra-content': '红警内容安装器',
    'cnc-content': '泰伯利亚黎明内容安装器',
    'd2k-content': '沙丘 2000 内容安装器',
    'common-content': '内容安装器公共部分',
}

# 一个文件一行说明。顺序即优先级,先匹配先生效。
# 每条:(正则, 类别名, 该类别的作用说明)
RULES = [
    (r'/fluent/chrome\.ftl$', '界面文案', '菜单、设置、按钮、提示等界面文字'),
    (r'/fluent/common\.ftl$', '通用文案', '通用提示、错误信息、单位类别、协议名'),
    (r'/fluent/rules\.ftl$', '单位与建筑', '单位与建筑名称、说明、技能与武器提示'),
    (r'/fluent/hotkeys\.ftl$', '快捷键', '快捷键说明（设置 → 快捷键页）'),
    (r'/fluent/ingame-debug\.ftl$', '作弊面板', '作弊菜单（上游把 Debug 改名成了 Cheats）'),
    (r'/fluent/campaign\.ftl$', '战役界面', '战役选择、任务列表、通关与失败提示'),
    (r'/fluent/(?:ra|cnc|d2k)\.ftl$', '模组信息', '模组名与描述、阵营介绍（启动器里显示）'),
    (r'/fluent/content\.ftl$', '安装器文案', '内容安装向导的公共文字（下一步、取消、来源）'),
    (r'/fluent/lua\.ftl$', '剧情脚本', '剧情脚本里上屏的对白与旁白'),
    (r'/maps/[^/]+/rules\.yaml$', '地图硬编码', '地图规则里写死的文字（倒计时、任务提示）'),
    (r'/installer/[^/]+\.yaml$', '安装源标题', '内容安装向导里列出的下载源名称（Steam / 光盘版…）'),
    (r'/chrome/[^/]+\.yaml$', '界面硬编码', '写死在界面 yaml 里的文字（建服对话框等）'),
    (r'/missions\.yaml$', '战役分组名', '任务列表左侧的分组标题（如「阿特雷德斯战役」）'),
    (r'/mod\.yaml$', '模块声明', '**不是文案**：字体指向 + 声明加载哪些 .ftl'),
    (r'/maps/([^/]+)/map\.ftl$', '战役简报', None),   # None = 用地图名生成
    (r'\.lua$', '地图脚本', '地图脚本里上屏的一句文字'),
]

# 同一 mod 内的排列顺序:文案 -> 界面 -> 地图 -> 安装源 -> 其余
CAT_RANK = {'界面文案': 0, '通用文案': 0, '战役界面': 0, '模组信息': 0, '单位与建筑': 0,
            '快捷键': 0, '作弊面板': 0, '剧情脚本': 0, '界面硬编码': 1, '战役简报': 2,
            '安装源标题': 3, '安装器文案': 3, '战役分组名': 4, '模块声明': 5,
            '地图硬编码': 6, '地图脚本': 6}

# 统计表的展示顺序(按"玩家看到的先后"排,不按数量)
KIND_ORDER = ['界面文案', '通用文案', '战役界面', '模组信息', '单位与建筑', '快捷键',
              '作弊面板', '剧情脚本', '战役简报', '战役分组名', '地图硬编码', '地图脚本',
              '界面硬编码', '安装源标题', '安装器文案', '模块声明']


def classify(path):
    """path 相对 files/,形如 mods/ra/maps/allies-01/map.ftl。返回 (类别, 作用)。"""
    for pattern, kind, desc in RULES:
        m = re.search(pattern, path)
        if not m:
            continue
        if desc is None:
            return kind, '「%s」的简报正文与任务目标' % m.group(1)
        return kind, desc
    return None, None


def human_size(n):
    if n >= 1024 * 1024:
        return '%.1f MB' % (n / 1024.0 / 1024.0)
    if n >= 1024:
        return '%.1f KB' % (n / 1024.0)
    return '%d B' % n


def load():
    with open(MANIFEST, encoding='utf-8') as fh:
        manifest = json.load(fh)
    entries = []
    for e in manifest['files']:
        path = e['path']
        kind, desc = classify(path)
        entries.append({'path': path, 'size': e['size'], 'kind': kind, 'desc': desc})
    return manifest, entries


def render(manifest, entries):
    unknown = [e for e in entries if e['kind'] is None]
    if unknown:
        print('有 %d 个文件没匹配到分类规则,请先补 RULES:' % len(unknown))
        for e in unknown:
            print('  ' + e['path'])
        sys.exit(1)

    total = len(entries)
    total_bytes = sum(e['size'] for e in entries)

    # ---- 类型统计表
    kind_order = []
    kind_count = {}
    kind_desc = {}
    for e in entries:
        if e['kind'] not in kind_count:
            kind_order.append(e['kind'])
            kind_count[e['kind']] = 0
            kind_desc[e['kind']] = e['desc']
        kind_count[e['kind']] += 1
    kind_order.sort(key=lambda k: (KIND_ORDER.index(k) if k in KIND_ORDER else 99, -kind_count[k]))

    out = []
    out.append(BEGIN)
    out.append('')
    out.append('共 **%d 个文件**、%.0f KB，按内容分成 %d 类。每一类一句话说清它是什么：'
               % (total, total_bytes / 1024.0, len(kind_order)))
    out.append('')
    out.append('| 类别 | 数量 | 是什么 | 举例 |')
    out.append('|---|---|---|---|')
    example = {}
    for e in entries:
        example.setdefault(e['kind'], e['path'])
    for k in kind_order:
        sample = example[k]
        if sample.startswith('mods/'):
            sample = sample[len('mods/'):]
        out.append('| %s | %d | %s | `%s` |' % (k, kind_count[k], kind_desc[k], sample.replace('/', '\\')))
    out.append('')

    # ---- 按 mod 分组
    groups = {}
    for e in entries:
        parts = e['path'].split('/')
        group = parts[1] if len(parts) > 2 and parts[0] == 'mods' else '(根)'
        groups.setdefault(group, []).append(e)

    order = [g for g in GROUP_ORDER if g in groups]
    order += [g for g in sorted(groups) if g not in order]

    for group in order:
        items = groups[group]
        items.sort(key=lambda e: (CAT_RANK.get(e['kind'], 9), e['path']))
        title = GROUP_TITLE.get(group, group)
        out.append('### `%s\\` — %s（%d 个）' % (group, title, len(items)))
        out.append('')
        out.append('| 文件（相对 `files\\mods\\`） | 大小 | 作用 |')
        out.append('|---|---|---|')
        for e in items:
            rel = e['path'][len('mods/'):] if e['path'].startswith('mods/') else e['path']
            out.append('| `%s` | %s | %s |' % (rel.replace('/', '\\'), human_size(e['size']), e['desc']))
        out.append('')

    out.append('> 这份清单由 `tools/build_readme_inventory.py` 从 `manifest.json` 生成,'
               '改载荷后重跑一次即可；CI 会校验两者一致。')
    out.append('')
    out.append(END)
    return '\n'.join(out)


def splice(readme_text, block):
    pattern = re.compile(re.escape(BEGIN) + r'.*?' + re.escape(END), re.S)
    if not pattern.search(readme_text):
        print('README 里找不到清单标记,请先手工放好这两行:')
        print('  ' + BEGIN)
        print('  ' + END)
        sys.exit(1)
    return pattern.sub(lambda _: block, readme_text)


def main():
    ap = argparse.ArgumentParser(description='把载荷清单渲染进 README 附录')
    ap.add_argument('--check', action='store_true', help='只校验 README 与 manifest 是否一致')
    ap.add_argument('--stdout', action='store_true', help='只打印生成结果,不写文件')
    args = ap.parse_args()

    manifest, entries = load()
    block = render(manifest, entries)

    if args.stdout:
        print(block)
        return 0

    text = open(README, encoding='utf-8').read()
    new_text = splice(text, block)

    if args.check:
        if new_text == text:
            print('README 的载荷清单与 manifest.json 一致(%d 个文件)' % len(entries))
            return 0
        print('README 的载荷清单**已过期**:manifest.json 有 %d 个文件,README 里的不清单不一致。'
              % len(entries))
        print('请运行:python tools/build_readme_inventory.py')
        return 1

    open(README, 'w', encoding='utf-8', newline='\n').write(new_text)
    print('已把 %d 个载荷清单写入 README.md' % len(entries))
    return 0


if __name__ == '__main__':
    sys.exit(main())
