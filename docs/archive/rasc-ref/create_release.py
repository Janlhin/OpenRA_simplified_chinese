# -*- coding: utf-8 -*-
"""创建 GitHub Release 并上传发布包附件。

token 通过 git credential fill 从本机凭据管理器取，只在内存中使用、不打印。
Release 说明取自 CHANGELOG.md 里对应版本的正文。

用法: python create_release.py [zip路径] [--dry-run]
"""
import json
import os
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request

sys.stdout.reconfigure(encoding='utf-8')

OWNER_REPO = 'Janlhin/OpenRA_simplified_chinese'
TAG = 'v1.3.1'
VERSION = '1.3.1'
RELEASE_NAME = '1.3.1 — 单位与建筑名对齐汉化组全称'
REPO_ROOT = r'C:\Users\Janlhin\Desktop\openra-zh-cn'
DEFAULT_ZIP = (r'C:\Users\Janlhin\WorkBuddy\2026-09-30-07-01-05\dist'
               r'\OpenRA_simplified_chinese-1.3.1.zip')
API = 'https://api.github.com'
UPLOADS = 'https://uploads.github.com'


def get_token():
    inp = 'protocol=https\nhost=github.com\n\n'
    p = subprocess.run(['git', 'credential', 'fill'], input=inp,
                       capture_output=True, text=True)
    if p.returncode != 0:
        return None, 'git credential fill 失败: ' + (p.stderr or '').strip()
    for line in p.stdout.splitlines():
        if line.startswith('password='):
            return line[len('password='):].strip(), None
    return None, '凭据管理器里没有 github.com 的 token'


def api(method, url, token, payload=None, raw=None, ctype='application/json'):
    data = raw if raw is not None else (
        json.dumps(payload).encode('utf-8') if payload is not None else None)
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header('Authorization', 'Bearer ' + token)
    req.add_header('Accept', 'application/vnd.github+json')
    req.add_header('User-Agent', 'openra-zh-cn-release')
    if data is not None:
        req.add_header('Content-Type', ctype)
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            return r.status, json.loads(r.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8', 'replace')
        try:
            return e.code, json.loads(body)
        except ValueError:
            return e.code, body


def changelog_body(zip_path):
    import hashlib
    blob = open(zip_path, 'rb').read()
    text = open(os.path.join(REPO_ROOT, 'CHANGELOG.md'), encoding='utf-8').read()
    start = text.find('## ' + VERSION)
    if start < 0:
        return '(CHANGELOG 里没有 %s 段落)' % VERSION
    nxt = text.find('\n## ', start + 1)
    section = text[start:nxt if nxt > 0 else len(text)].rstrip()
    section = section.replace('## ' + VERSION + ' — 2026-09-30', '', 1).strip()
    return ('## 安装\n\n'
            '下载下方 `%s`，解压到**英文路径**，关闭 OpenRA 后双击 `install.bat`。\n'
            '还原用 `uninstall.bat`；想确认卸干净了用 `verify-uninstall.bat`。\n'
            '详见 [README](https://github.com/%s#快速开始)。\n\n'
            '| 附件 | 大小 | SHA-256 |\n|---|---|---|\n| `%s` | %d 字节 | `%s` |\n\n'
            '包内自带 `tools/`，可用 `python tools/verify_manifest.py` 自行复核全部载荷哈希。\n\n'
            '---\n\n'
            % (os.path.basename(zip_path), OWNER_REPO, os.path.basename(zip_path),
               len(blob), hashlib.sha256(blob).hexdigest())) + section


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    zip_path = args[0] if args else DEFAULT_ZIP
    dry = '--dry-run' in sys.argv
    if not os.path.isfile(zip_path):
        print('[错误] 找不到发布包:', zip_path)
        return 2
    asset = os.path.basename(zip_path)
    body = changelog_body(zip_path)
    print('仓库    :', OWNER_REPO)
    print('tag     :', TAG)
    print('标题    :', RELEASE_NAME)
    print('附件    :', asset, '(%d 字节)' % os.path.getsize(zip_path))
    print('说明长度: %d 字符' % len(body))
    if dry:
        print('--- 说明预览 ---')
        print(body[:600] + ('\n...(略)' if len(body) > 600 else ''))
        return 0

    token, err = get_token()
    if not token:
        print('[错误]', err)
        return 2
    print('已取到本机 GitHub 凭据（不回显）')

    code, resp = api('POST', API + '/repos/' + OWNER_REPO + '/releases', token,
                     {'tag_name': TAG, 'name': RELEASE_NAME, 'body': body,
                      'draft': False, 'prerelease': False})
    if code == 422:
        print('Release 已存在，改为复用')
        code, resp = api('GET', API + '/repos/' + OWNER_REPO + '/releases/tags/' + TAG, token)
    if code not in (200, 201):
        print('[失败] 创建 Release HTTP', code)
        print(resp if isinstance(resp, str) else json.dumps(resp, ensure_ascii=False)[:600])
        return 1
    rel = resp
    print('OK  Release ->', rel['html_url'], '| id', rel['id'], '| tag', rel['tag_name'])

    existing = {a['name']: a for a in rel.get('assets', [])}
    if asset in existing:
        print('附件已存在，先删除旧的:', existing[asset]['name'])
        api('DELETE', API + '/repos/' + OWNER_REPO + '/releases/assets/'
            + str(existing[asset]['id']), token)

    with open(zip_path, 'rb') as fh:
        blob = fh.read()
    url = ('%s/repos/%s/releases/%d/assets?name=%s'
           % (UPLOADS, OWNER_REPO, rel['id'], urllib.parse.quote(asset)))
    code, resp = api('POST', url, token, raw=blob, ctype='application/zip')
    if code not in (200, 201):
        print('[失败] 上传附件 HTTP', code)
        print(resp if isinstance(resp, str) else json.dumps(resp, ensure_ascii=False)[:600])
        return 1
    print('OK  附件   ->', resp['name'], '|', resp['size'], '字节')
    print('     下载   ->', resp['browser_download_url'])
    return 0


if __name__ == '__main__':
    sys.exit(main())
