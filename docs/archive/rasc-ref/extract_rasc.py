import os, re, json

ROOT = r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\rasc-ref\OpenRA_rasc"
OUT = r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\rasc-ref\rasc_translations.json"

cjk = re.compile(r'[\u4e00-\u9fff]')
field_line = re.compile(r'^(\t*)([A-Za-z0-9_@.\-]+):\s*(.*)$')

records = []
for dirpath, dirnames, filenames in os.walk(ROOT):
    for fn in filenames:
        if not fn.endswith('.yaml'):
            continue
        path = os.path.join(dirpath, fn)
        rel = os.path.relpath(path, ROOT)
        try:
            with open(path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except UnicodeDecodeError:
            try:
                with open(path, 'r', encoding='gbk') as f:
                    lines = f.readlines()
            except Exception:
                continue
        stack = []
        for raw in lines:
            line = raw.rstrip('\n')
            if not line.strip():
                continue
            m = field_line.match(line)
            if not m:
                continue
            indent = len(m.group(1))
            key = m.group(2)
            value = m.group(3).strip()
            while stack and stack[-1][0] >= indent:
                stack.pop()
            stack.append((indent, key))
            if value and cjk.search(value):
                keypath = ' > '.join(k for _, k in stack[:-1])
                records.append({
                    'file': rel,
                    'field': key,
                    'value': value,
                    'keypath': keypath,
                })

with open(OUT, 'w', encoding='utf-8') as f:
    json.dump(records, f, ensure_ascii=False, indent=1)

# summary
from collections import Counter
by_file = Counter(r['file'] for r in records)
names = [r for r in records if r['field'] == 'Name']
print('total records:', len(records))
print('Name-field records:', len(names))
print('--- by file (top 20) ---')
for f, c in by_file.most_common(20):
    print(f'{c:4d}  {f}')
print('--- sample Name records (first 40) ---')
for r in names[:40]:
    print(f"{r['keypath']:35s} | {r['value']}")
