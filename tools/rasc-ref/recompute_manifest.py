# -*- coding: utf-8 -*-
"""全量重算 manifest.json 中所有 files 条目的 size/sha256。"""
import hashlib, json, os, sys

REPO = sys.argv[1] if len(sys.argv) > 1 else \
    r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\openra-zh-cn"
manifest_path = os.path.join(REPO, "manifest.json")
manifest = json.load(open(manifest_path, encoding="utf-8"))

changed = 0
missing = 0
for entry in manifest["files"]:
    rel = entry["path"]
    p = os.path.join(REPO, "files", rel.replace("/", os.sep))
    if not os.path.isfile(p):
        missing += 1
        print("MISSING", rel)
        continue
    data = open(p, "rb").read()
    size = len(data)
    sha = hashlib.sha256(data).hexdigest()
    if size != entry.get("size") or sha != entry.get("sha256"):
        changed += 1
    entry["size"] = size
    entry["sha256"] = sha

with open(manifest_path, "w", encoding="utf-8", newline="\n") as fh:
    json.dump(manifest, fh, ensure_ascii=False, indent=2)
    fh.write("\n")
print(f"total={len(manifest['files'])} changed={changed} missing={missing}")
