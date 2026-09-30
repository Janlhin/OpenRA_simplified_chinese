#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""将 .ftl 头注释中的旧项目名 openra-zh-cn 改写为新名（字节级，保留换行符）。"""
import os, sys

OLD = b"openra-zh-cn"
NEW = "OpenRA-simplified-chinese".encode("ascii")
BASE = sys.argv[1] if len(sys.argv) > 1 else r"C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\openra-zh-cn\files"

n_files = 0
n_hits = 0
for root, _, files in os.walk(BASE):
    for fn in files:
        if not fn.endswith(".ftl"):
            continue
        p = os.path.join(root, fn)
        data = open(p, "rb").read()
        if OLD in data:
            n_hits += data.count(OLD)
            open(p, "wb").write(data.replace(OLD, NEW))
            n_files += 1
print(f"updated files: {n_files}, total replacements: {n_hits}")
