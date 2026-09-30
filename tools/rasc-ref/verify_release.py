# -*- coding: utf-8 -*-
"""独立复核 GitHub Release：是否公开（非 draft）、附件能否匿名下载且与本地包逐字节一致。

API 元数据用本机凭据（避开未认证 60 次/小时的速率限制），
附件则用公开下载链接 + 不带任何凭据 拉取，验证普通用户拿到的东西是对的。
"""
import hashlib
import json
import os
import subprocess
import sys
import urllib.request

sys.stdout.reconfigure(encoding='utf-8')

OWNER_REPO = 'Janlhin/OpenRA_simplified_chinese'
TAG = 'v1.3.1'
API = 'https://api.github.com/repos/%s/releases/tags/%s' % (OWNER_REPO, TAG)
LOCAL = (r'C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\dist'
         r'\OpenRA_simplified_chinese-1.3.1.zip')


def token():
    p = subprocess.run(['git', 'credential', 'fill'],
                       input='protocol=https\nhost=github.com\n\n',
                       capture_output=True, text=True)
    for line in p.stdout.splitlines():
        if line.startswith('password='):
            return line[len('password='):].strip()
    return None


def fetch(url, auth=None, binary=False):
    req = urllib.request.Request(url)
    req.add_header('User-Agent', 'openra-zh-cn-verify')
    req.add_header('Accept', 'application/vnd.github+json')
    if auth:
        req.add_header('Authorization', 'Bearer ' + auth)
    with urllib.request.urlopen(req, timeout=180) as r:
        data = r.read()
    return data if binary else json.loads(data.decode('utf-8'))


tok = token()
rel = fetch(API, auth=tok)
print('tag        :', rel['tag_name'])
print('名称       :', rel['name'])
print('draft      :', rel['draft'], '   prerelease:', rel['prerelease'])
print('published  :', rel['published_at'])
print('说明长度   :', len(rel.get('body') or ''), '字符')
print('页面       :', rel['html_url'])

local = open(LOCAL, 'rb').read()
lh = hashlib.sha256(local).hexdigest()
print()
print('本地包     : %d 字节  %s' % (len(local), lh))

ok = not rel['draft']
for a in rel.get('assets', []):
    print()
    print('附件       : %s  声明 %d 字节  下载数 %s' % (a['name'], a['size'], a['download_count']))
    print('  公开 URL :', a['browser_download_url'])
    blob = fetch(a['browser_download_url'], binary=True)   # 不带凭据
    h = hashlib.sha256(blob).hexdigest()
    same = (h == lh and len(blob) == len(local))
    ok = ok and same
    print('  匿名下载 : %d 字节  sha256 %s' % (len(blob), h))
    print('  比对结果 :', '逐字节一致 OK' if same else '*** 不一致 ***')

print()
if rel['draft']:
    print('!! 该 Release 仍是 draft=true，对外不可见，需要 PATCH draft=false')
print('总结:', 'Release 公开可见，附件匿名下载校验通过' if ok else '存在问题，见上')
sys.exit(0 if ok else 1)
