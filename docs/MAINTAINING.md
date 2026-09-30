# 维护者文档

面向**仓库维护者**。各文档的分工：

| 文档 | 读者 | 回答的问题 |
|---|---|---|
| [README.md](../README.md) | 玩家 | 怎么装、怎么卸、覆盖了什么 |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | 贡献者 | 想改一句译文，该怎么动手 |
| [ANATOMY.md](ANATOMY.md) | 参考 | 每个文件是什么、`.ftl` 何时被加载 |
| **本文档** | 维护者 | 怎么重建载荷、怎么发布、CI 与验证 |

---

## 开始之前：先读 ANATOMY

仓库目录总览、每个文件的职责、`files/` 的 8 个 mod 包、`.ftl` 的六类文件与**加载时机**、
少数非 `.ftl` 载荷的清单、译文基线（汉化组 RASC / TDSC）——**全部在 [ANATOMY.md](ANATOMY.md)**，
本文档不重复。

维护时必须守住的三条硬约束：

1. **绝不把 `map.yaml`（地图标题）纳入载荷**——会改变地图 UID，破坏联机与录像兼容性
   （原理见 [ANATOMY](ANATOMY.md#为什么绝大多数只改-ftl)）。
2. **绝不把字体（`.ttf` / `.ttc` / `.otf`）放进 `files/`**——授权原因；CI 有专门的守卫步骤。
3. **改动任何载荷字节都必须重算哈希**——哪怕只是把 CRLF 转成 LF。

## 载荷与哈希怎么生成

用仓库自带的 `tools/build_manifest.py` 重建（diff 英文原版与汉化目录，自动收集文本文件）：

```bash
python tools/build_manifest.py --original "C:\Program Files\OpenRA (playtest)" \
                               --patched  "C:\Users\你\OpenRA-CN" \
                               --version 1.3.1 --engine playtest-20260222 \
                               --dry-run          # 先看要改哪些
```

注意事项：

- `.ttf` / `.ttc` / `.otf` 会被显式排除——**补丁一律不分发字体**（授权原因）。
- 所有 `.ftl` 写入时会自动加上 SPDX 许可头。
- 该脚本会**清空并重拷 `files/`**，运行前请确认工作区没有未提交的手工改动。
- 只想改一两个文件时，也可以直接改 `manifest.json` 里对应条目的 `size` / `sha256`。

## 仓库与发布

- **远端**：<https://github.com/Janlhin/OpenRA_simplified_chinese>（`origin`，默认分支 `main`）
- `manifest.json` 的 `repository` 字段已填。
- `LICENSE` 的版权行是 `Copyright (C) 2026 OpenRA_simplified_chinese contributors`，
  若想挂到个人名下可自行改。

日常更新（**改了载荷就必须先重算哈希**，否则 CI 会挡下）：

```bash
python tools/verify_manifest.py            # 或 tools/build_manifest.py 全量重建
python tools/lint_ftl.py files/mods
python tools/struct_check_maps.py files/mods
git add -A && git commit -m "..." && git push
```

## 发新版本

1. 改版本号：`manifest.json` 的 `version` / `releaseDate`，并在 `CHANGELOG.md` 顶部加一节。
2. 若动过 `files/`，按上节重建载荷与哈希。
3. 构建发布包：`python tools/build_release.py --verify`
   （产出 `dist/OpenRA_simplified_chinese-x.y.z.zip`，并打印 SHA-256——写进 Release 说明）
4. 打 tag 并推送：`git tag -a vX.Y.Z -m "…" && git push origin vX.Y.Z`
5. 在 GitHub 上以该 tag 创建 Release，把 `dist/*.zip` 作为附件上传；说明直接抄
   `CHANGELOG.md` 对应版本那一节。

`build_release.py` 打出的包是**确定性**的（zip 时间戳取自 `manifest.json` 的 `releaseDate`），
同一份仓库内容重复构建得到字节一致的 zip；`--verify` 会把包解压到临时目录并重跑四项校验。

想做成 `.exe` 安装包，可用 [Inno Setup](https://jrsoftware.org/isinfo.php) 打包 `files/`，
并在 `[Run]` 中调用 `install.ps1 -Target "{app}" -Yes`。

## 仓库信息（已设置）

- 描述：`OpenRA（红警/泰伯利亚黎明/沙丘 2000）简体中文汉化补丁，覆盖界面、单位建筑名、任务目标与全部战役简报`
- Topics：`openra` `chinese` `translation` `localization` `red-alert` `tiberian-dawn` `dune-2000` `fluent`
- 首个 Release：`v1.3.1`（2026-09-30），附件 `OpenRA_simplified_chinese-1.3.1.zip`
- CI 徽章已在 README 顶部启用：

```markdown
[![validate](https://github.com/Janlhin/OpenRA_simplified_chinese/actions/workflows/validate.yml/badge.svg)](https://github.com/Janlhin/OpenRA_simplified_chinese/actions/workflows/validate.yml)
```

## CI

`.github/workflows/validate.yml` 在 `push` / `pull_request` 时跑五步（Linux runner）：

1. `verify_manifest.py` —— 载荷与 `manifest.json` 逐字节一致；
2. `lint_ftl.py files/mods` —— Fluent 规范（BOM / 换行 / 缩进 / 花括号）；
3. `struct_check_maps.py files/mods` —— 地图文案结构自检；
4. `check_links.py .` —— Markdown 相对链接与锚点（`docs/` 引用根目录文件必须写 `../`）；
5. 守卫：`files/` 中不得出现 `.ttf` / `.ttc` / `.otf`。

> 第 2 步对 **CRLF 换行**判错并返回退出码 1。`.gitattributes` 已声明 `files/** -text`（不转换换行），
> 所以载荷在本地就必须是 LF——不要用编辑器批量转换换行，否则 `manifest.json` 的哈希会全部失效。

## 端到端验证记录

安装脚本用 Windows PowerShell 5.1 语法编写（不依赖 PowerShell 7），
在 `playtest-20260222` 的完整安装副本上从零跑通，并已在打包后的 zip 上复测：

| 验证项 | 结果 |
|---|---|
| `install.bat` 安装（196 文件 + 字体） | 通过，SHA-256 载荷校验通过 |
| `OpenRA.Utility.exe <mod> --check-yaml`（6 个模组） | 全部通过 |
| `OpenRA.Utility.exe <mod> --check-yaml mods/<mod>/maps/<地图>/map.yaml`（151 张地图） | 全部通过 |
| `--extract-chrome-strings` 界面键缺失检测 | 无缺失 |
| `check_yaml_fluent_refs.py` 与原版差分 | 0 个新出现的未解析键 |
| `validate_ftl.py` 逐键比对（196 个载荷文件） | 键、占位符、复数选择器全部一致 |
| `struct_check_maps.py` 地图文案结构校验（135 个 map.ftl） | 0 处问题 |
| `audit_coverage.py` 覆盖率审计 | 硬编码英文 0 处、脚本上屏英文 0 处；仅剩 26 条应保留的英文（品牌 / 缩写 / 键盘按键名）与 144 处地图元数据 |
| 字体引用可落地性 / 字形覆盖 | 全部存在，无缺字 |
| `-DryRun` 预演 | 确认零写入 |
| `-Uninstall` 还原 | 全部文件还原 + 新增文件删除，与原版逐字节一致 |

## 校验工具 CLI 备忘

```bash
# 译文与官方英文原文是否逐键一致（需要一份英文原版安装目录）
python tools/validate_ftl.py "C:\Program Files\OpenRA (playtest)\mods" "C:\OpenRA-CN\mods" \
    mods/common/fluent/chrome.ftl mods/ra/fluent/ra.ftl ...

# yaml 引用的消息键能否解析（给出第二个参数则只报告"原本能解析、现在解析不到"的键）
python tools/check_yaml_fluent_refs.py "C:\Program Files\OpenRA (playtest)\mods" \
                                       "C:\Users\你\OpenRA-CN\mods"

# 中文字体字形覆盖
python tools/check_font_glyphs.py "C:\Windows\Fonts\simhei.ttf" "安装游戏内容快速退出"

# 地图文案结构校验（135 个 map.ftl，不需要第三方库）
python tools/struct_check_maps.py "C:\Program Files\OpenRA (playtest)\mods" "C:\OpenRA-CN\mods"

# 引擎自带的静态检查（退出码 0 即通过）
OpenRA.Utility.exe ra --check-yaml
OpenRA.Utility.exe ra-content --check-yaml
OpenRA.Utility.exe ra --check-yaml mods/ra/maps/allies-01/map.yaml   # 逐张地图
OpenRA.Utility.exe ra --extract-chrome-strings    # 无 "Adding" 行 = 界面键无缺失
```
