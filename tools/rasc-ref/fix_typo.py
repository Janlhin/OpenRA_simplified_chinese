import os, glob

ROOT = r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\openra-zh-cn\files"
changed = 0
files_changed = []
for p in glob.glob(os.path.join(ROOT, '**', '*.ftl'), recursive=True):
    try:
        data = open(p, 'r', encoding='utf-8').read()
    except Exception:
        continue
    if '支奴干' in data:
        new = data.replace('支奴干', '支努干')
        open(p, 'w', encoding='utf-8').write(new)
        n = data.count('支奴干')
        changed += n
        files_changed.append((p, n))
for p, n in files_changed:
    print(f'{n}  {p}')
print('total fixed:', changed)
