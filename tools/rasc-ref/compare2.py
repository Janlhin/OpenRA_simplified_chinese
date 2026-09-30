import os, re, json, glob

OUR_ROOT = r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\openra-zh-cn\files"
RASC_JSON = r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\rasc-ref\rasc_translations.json"
REPORT = r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\rasc-ref\rasc_name_alignment.md"

# 收集我们 .ftl 的所有 message value（短中文串）
our_vals = set()
for path in glob.glob(os.path.join(OUR_ROOT, '**', '*.ftl'), recursive=True):
    try:
        txt = open(path, 'r', encoding='utf-8').read()
    except Exception:
        continue
    for m in re.finditer(r'=\s*([^\n#{}]{1,16})', txt):
        v = m.group(1).strip()
        if re.search(r'[\u4e00-\u9fff]', v):
            our_vals.add(v)

with open(RASC_JSON, 'r', encoding='utf-8') as f:
    rasc = json.load(f)

# 只看短名称：Name/Tooltip 字段，单行，长度<=12
cand = [r for r in rasc
        if 'mods\\rasc\\rules' in r['file'].replace('/', '\\')
        and r['field'] in ('Name', 'Tooltip')
        and '\n' not in r['value']
        and 2 <= len(r['value'].split('#')[0].strip()) <= 12]

def clean(v):
    return v.split('#')[0].strip()

rows = []
for r in cand:
    cv = clean(r['value'])
    if not cv:
        continue
    exact = cv in our_vals
    we_shorter = any(cv.startswith(ov) and ov != cv for ov in our_vals)  # 我们更短
    we_longer = any(ov.startswith(cv) and ov != cv for ov in our_vals)    # 我们更长
    if exact:
        cat = '一致'
    elif we_shorter:
        cat = '我们更短(汉化组全称)'
    elif we_longer:
        cat = '我们更长'
    else:
        cat = '无对应'
    rows.append((cat, r['keypath'], cv))

from collections import Counter
cnt = Counter(x[0] for x in rows)
print('short-name candidates:', len(rows))
for k, v in cnt.items():
    print(f'  {k}: {v}')

print('\n=== 我们更短（建议采纳汉化组全称）===')
for cat, kp, cv in rows:
    if cat == '我们更短(汉化组全称)':
        print(f'  {kp:22s} | RASC: {cv}')

print('\n=== 无对应（需核查是否漏译/键体系不同）===')
for cat, kp, cv in rows:
    if cat == '无对应':
        print(f'  {kp:22s} | RASC: {cv}')

with open(REPORT, 'w', encoding='utf-8') as f:
    f.write('# RASC vs 我们 — 单位/建筑短名称对齐\n\n')
    f.write('只看 rules 下的 Name/Tooltip 短名称（<=12字）。\n\n')
    f.write('## 统计\n\n')
    for k, v in cnt.items():
        f.write(f'- {k}: {v}\n')
    f.write('\n## 我们更短（汉化组用更完整的称呼，建议对齐）\n\n')
    f.write('| 英文ID | RASC 全称 |\n|---|---|\n')
    for cat, kp, cv in rows:
        if cat == '我们更短(汉化组全称)':
            f.write(f'| {kp} | {cv} |\n')
    f.write('\n## 无对应（需核查）\n\n')
    f.write('| 英文ID | RASC 名称 |\n|---|---|\n')
    for cat, kp, cv in rows:
        if cat == '无对应':
            f.write(f'| {kp} | {cv} |\n')
print('\nreport:', REPORT)
