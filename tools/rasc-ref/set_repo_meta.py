# -*- coding: utf-8 -*-
"""用本机 git 凭据（Windows 凭据管理器）调用 GitHub API，补全仓库的
description / homepage / topics。token 全程只在内存中，不会被打印。

用法: python set_repo_meta.py [--dry-run]
"""
import json
import subprocess
import sys
import urllib.error
import urllib.request

OWNER_REPO = 'Janlhin/OpenRA_simplified_chinese'
DESCRIPTION = ('OpenRA（红警/泰伯利亚黎明/沙丘 2000）简体中文汉化补丁，'
               '覆盖界面、单位建筑名、任务目标与全部战役简报')
HOMEPAGE = 'https://github.com/Janlhin/OpenRA_simplified_chinese'
TOPICS = ['openra', 'chinese', 'translation', 'localization',
          'red-alert', 'tiberian-dawn', 'dune-2000', 'fluent']


def get_token():
    """通过 git credential fill 取本机已保存的 github 凭据。"""
    inp = 'protocol=https\nhost=github.com\n\n'
    p = subprocess.run(['git', 'credential', 'fill'], input=inp,
                       capture_output=True, text=True)
    if p.returncode != 0:
        return None, 'git credential fill 失败: ' + (p.stderr or '').strip()
    for line in p.stdout.splitlines():
        if line.startswith('password='):
            return line[len('password='):].strip(), None
    return None, '凭据管理器里没有 github.com 的 token'


def api(method, url, token, payload=None):
    data = json.dumps(payload).encode('utf-8') if payload is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header('Authorization', 'Bearer ' + token)
    req.add_header('Accept', 'application/vnd.github+json')
    req.add_header('User-Agent', 'openra-zh-cn-meta')
    if data:
        req.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status, json.loads(r.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8', 'replace')
        return e.code, body


def main():
    dry = '--dry-run' in sys.argv
    print('目标仓库:', OWNER_REPO)
    print('  description:', DESCRIPTION)
    print('  homepage   :', HOMEPAGE)
    print('  topics     :', ' '.join(TOPICS))
    if dry:
        print('(dry-run，未调用 API)')
        return 0

    token, err = get_token()
    if not token:
        print('[错误]', err)
        print('提示:在 GitHub 网页端手动设置，或先 git push 一次登录凭据。')
        return 2
    print('已取到本机 GitHub 凭据（不回显）')

    base = 'https://api.github.com/repos/' + OWNER_REPO
    code, resp = api('PATCH', base, token,
                     {'description': DESCRIPTION, 'homepage': HOMEPAGE})
    if code != 200:
        print('[失败] PATCH 仓库信息 HTTP', code)
        print(resp if isinstance(resp, str) else json.dumps(resp, ensure_ascii=False)[:500])
        return 1
    print('OK  description ->', resp.get('description'))
    print('OK  homepage    ->', resp.get('homepage'))

    code, resp = api('PUT', base + '/topics', token, {'names': TOPICS})
    if code != 200:
        print('[失败] PUT topics HTTP', code)
        print(resp if isinstance(resp, str) else json.dumps(resp, ensure_ascii=False)[:500])
        return 1
    print('OK  topics      ->', ' '.join(resp.get('names', [])))
    return 0


if __name__ == '__main__':
    sys.exit(main())
