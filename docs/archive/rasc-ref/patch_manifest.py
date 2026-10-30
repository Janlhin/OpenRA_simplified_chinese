# -*- coding: utf-8 -*-
"""仅重算 manifest.json 中 ra/cnc rules.ftl 两个条目的 size/sha256,
对齐当前磁盘上的 LF 内容。不触碰其它 194 个条目,格式与 build_manifest.py 保持一致。"""
import hashlib, json, os

REPO = r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\openra-zh-cn"
TARGETS = ["mods/ra/fluent/rules.ftl", "mods/cnc/fluent/rules.ftl"]

manifest_path = os.path.join(REPO, "manifest.json")
manifest = json.load(open(manifest_path, encoding="utf-8"))

for entry in manifest["files"]:
    rel = entry["path"]
    if rel in TARGETS:
        p = os.path.join(REPO, "files", rel.replace("/", os.sep))
        data = open(p, "rb").read()
        entry["size"] = len(data)
        entry["sha256"] = hashlib.sha256(data).hexdigest()
        print(f"updated {rel}: size={entry['size']} sha256={entry['sha256'][:12]}...")

with open(manifest_path, "w", encoding="utf-8", newline="\n") as fh:
    json.dump(manifest, fh, ensure_ascii=False, indent=2)
    fh.write("\n")
print("manifest.json 已更新")
