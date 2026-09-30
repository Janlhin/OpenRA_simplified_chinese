import os, re, json, glob

OUR_ROOT = r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\openra-zh-cn\files"
RASC_JSON = r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\rasc-ref\rasc_translations.json"
REPORT = r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\rasc-ref\rasc_vs_ours.md"

# 收集我们 .ftl 的全部中文文本
our_text = []
n_ftl = 0
for path in glob.glob(os.path.join(OUR_ROOT, '**', '*.ftl'), recursive=True):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            our_text.append(f.read())
        n_ftl += 1
    except Exception:
        pass
our_blob = '\n'.join(our_text)

with open(RASC_JSON, 'r', encoding='utf-8') as f:
    rasc = json.load(f)

# 只取 rasc/rules 下（单位/建筑/升级/科技）的命名类字段
candidate = [r for r in rasc
             if 'mods\\rasc\\rules' in r['file'].replace('/', '\\')
             and r['field'] in ('Name', 'Tooltip', 'Description', 'Title', 'Text')]

def clean(v):
    return v.split('#')[0].strip()

results = []
for r in candidate:
    cv = clean(r['value'])
    if not cv or len(cv) < 2:
        continue
    matched = cv in our_blob
    results.append({'keypath': r['keypath'], 'field': r['field'],
                    'rasc': r['value'], 'clean': cv, 'matched': matched})

matched = [x for x in results if x['matched']]
unmatched = [x for x in results if not x['matched']]

print('our ftl files scanned:', n_ftl)
print('rasc naming candidates:', len(results))
print('matched (identical string present in our ftl):', len(matched))
print('unmatched:', len(unmatched))
print('--- unmatched (RASC term NOT found verbatim in our ra ftl) ---')
for x in unmatched:
    print(f"{x['keypath']:28s} | {x['rasc']}")

# 写 markdown 报告
with open(REPORT, 'w', encoding='utf-8') as f:
    f.write('# RASC 汉化组 vs 我们的 ra 译文 — 术语对齐\n\n')
    f.write(f'- 我们扫描的 .ftl 文件数: {n_ftl}\n')
    f.write(f'- RASC 命名类候选条数: {len(results)}\n')
    f.write(f'- 完全一致(子串命中): {len(matched)}\n')
    f.write(f'- 未命中(可能译法不同/我们遗漏): {len(unmatched)}\n\n')
    f.write('## 未命中清单（建议人工核对 / 对齐汉化组共识译名）\n\n')
    f.write('| 英文ID锚点 | RASC 译名 | 字段 |\n')
    f.write('|---|---|---|\n')
    for x in unmatched:
        f.write(f"| {x['keypath']} | {x['rasc']} | {x['field']} |\n")
print('\nreport written:', REPORT)
