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

与汉化组译名对齐相关的一次性脚本、比对报告与提取数据，在
[`../tools/rasc-ref/`](../tools/rasc-ref/README.md)（参考仓库需自行从 Gitee 克隆）。

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
                               --version 1.4.0 --engine playtest-20261026 \
                               --dry-run          # 先看要改哪些
```

注意事项：

- `.ttf` / `.ttc` / `.otf` 会被显式排除——**补丁一律不分发字体**（授权原因）。
- 所有 `.ftl` 写入时会自动加上 SPDX 许可头。
- 该脚本会**清空并重拷 `files/`**，运行前请确认工作区没有未提交的手工改动。
- 只想改一两个文件时，也可以直接改 `manifest.json` 里对应条目的 `size` / `sha256`。
- `manifest.json` 的 `stats` 三项由脚本**按固定口径重算**，不要再手填：
  `fluentMessages` = 非地图 `.ftl` 的顶层消息数（不含 `-term` 与属性）；
  `installerTitles` = `*-content/installer/*.yaml` 的顶层节点数；
  `mapBriefings` = 含 `briefing` 的 `maps/*/map.ftl` 个数。
  口径在 1.4.0 统一过一次，因此**与 1.3.1 及更早的数字不可直接比较**。

## 引擎升级:把译文迁到新版英文目录

OpenRA 每个 playtest 都会改 Fluent 目录，而**键名对不上时引擎不回退英文，而是把键名直接画到界面上**。
所以引擎一升级就要重做一版载荷，旧载荷不能直接套。

`tools/port_translations.py` 把这件事变成机械操作：**结构取新版英文，取值取旧译文**。

```bash
# 1) 旧版英文基线:从上游 tag 稀疏取出需要的文件(别下拉整个仓库)
git clone --filter=blob:none --no-checkout --depth 1 --branch <旧tag> https://github.com/OpenRA/OpenRA.git openra-old
cd openra-old && git sparse-checkout init --no-cone
printf 'mods/**/fluent/**\nmods/**/installer/**\nmods/**/chrome/**\nmods/**/maps/**/*.yaml\nmods/**/maps/**/*.lua\nmods/**/mod.yaml\nmods/**/missions.yaml\n' > .git/info/sparse-checkout
git checkout && cd ..

# 2) 生成译文底稿 + 四份报告
python tools/port_translations.py \
    --old-english "openra-old/mods" \
    --old-payload "上一版/files/mods" \
    --new-english "C:/Program Files/OpenRA (playtest)/mods" \
    --out "stage/patched/mods" \
    --font-from "common|FreeSans.ttf,common|FreeSansBold.ttf" --font-to "common|SimHei.ttf"

# 3) 按报告补译,再用译表回灌
python tools/port_translations.py ... --translations new.tsv --fix fix.tsv

# 4) 重建载荷(见上一节)
python tools/build_manifest.py --original "…" --patched "stage/patched" --version x.y.z --engine playtest-xxxxxxxx
```

四份报告各管一类问题：

| 报告 | 含义 | 处理方式 |
|---|---|---|
| `port_untranslated.tsv` | 新版新增的键 | 逐条翻译，写成 `new.tsv` 回灌 |
| `port_changed.txt` | 英文原文改过（附旧译文） | **必须逐条复核**，改成 `fix.tsv` 或直接编辑底稿 |
| `port_placeholder.txt` | 占位符 / 复数选择器与英文不一致 | 必须改，否则引擎判为不匹配 |
| `port_manual.txt` | 非 `.ftl` 且新旧英文不同 | 人工处理；本项目通常是 `d2k/missions.yaml` 的战役分组标题 |

注意：

- `--old-payload` 用**上一版 release 的 `files/mods`**（带 SPDX 头的载荷），不要用汉化后的安装目录。
- 工具只负责"哪些还没翻"，**不判断译文是否仍然准确**——英文改过的地方要人看。
- 新地图的 `map.ftl` 会以"新增键"的形式出现，照常翻译即可。

## 仓库与发布

- **远端**：<https://github.com/Janlhin/OpenRA_simplified_chinese>（`origin`，默认分支 `main`）
- `manifest.json` 的 `repository` 字段已填。
- `LICENSE` 的版权行是 `Copyright (C) 2026 OpenRA_simplified_chinese contributors`，
  若想挂到个人名下可自行改。

日常更新（**改了载荷就必须先重算哈希**，否则 CI 会挡下）：

```bash
python tools/build_manifest.py --original "…" --patched "…"   # 重建载荷与哈希
python tools/build_readme_inventory.py     # README 附录 A 的 208 行清单跟着重生成
python tools/lint_ftl.py files/mods
python tools/struct_check_maps.py files/mods
git add -A && git commit -m "..." && git push
```

> 包内 README（`PACKAGE-README.md`，包里叫 `README.md`）的「附录 A 全部文件清单」**不要手改**——
> 它由 `build_readme_inventory.py` 从 `manifest.json` 渲染，CI 用 `--check` 断言两者一致；
> 改了载荷忘了重跑，CI 会直接挡下。

## 发新版本

1. 改版本号：`manifest.json` 的 `version` / `releaseDate`（或用
   `build_manifest.py --version x.y.z --date YYYY-MM-DD` 连带重算），并在 `CHANGELOG.md` 顶部加一节。
2. 若动过 `files/`，按上节重建载荷与哈希。
3. 构建发布包：`python tools/build_release.py --verify`
   （产出 `dist/OpenRA_simplified_chinese-x.y.z.zip`，并打印 SHA-256——写进 Release 说明）
4. 打 tag 并推送：`git tag -a vX.Y.Z -m "…" && git push origin vX.Y.Z`
5. 在 GitHub 上以该 tag 创建 Release，把 `dist/*.zip` 作为附件上传；说明直接抄
   `CHANGELOG.md` 对应版本那一节。

### 发布包里放什么

`build_release.py` 默认走**白名单**，只打玩家需要的文件：

```
setup.cmd / README.md / 安装说明.txt / 安装说明.md / LICENSE / LICENSE-OFL.txt
bin/install.ps1   bin/manifest.json      ← 仓库里在根目录，打包时按 PACKAGE_LAYOUT 收进 bin/
fonts/NotoSansSC-Regular.ttf  fonts/NotoSansSC-Bold.ttf / files/**
```

`tools/`、`docs/`、`.github/`、`CONTRIBUTING.md`、`CHANGELOG.md`、`.gitattributes`
都留在仓库里，不进包——C 端解压后应该只看到一个入口、一份说明和 `files/`。
要打全量快照（复现问题、存档给协作者）用 `--dev`，输出 `*-dev.zip`。

包是**确定性**的（zip 时间戳取自 `manifest.json` 的 `releaseDate`），同一份仓库内容重复构建
得到字节一致的 zip。`--verify` 会在解压出的包上做**包内自校验**（不再依赖 `tools/`）：
入口文件是否齐全、包内 `manifest.json` 是否与仓库一致、208 个载荷的 size/sha256 是否对得上、
`files/` 里有没有多余文件。

### 随包字体怎么来的

`fonts/` 里两个 TTF 是 **Noto Sans SC 全量字形**，由上游可变字体固化而来（不是子集化，
字形一个都不删）：

```bash
# 上游只发可变字体
curl -LO "https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf"
curl -Lo LICENSE-OFL.txt "https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssc/OFL.txt"

pip install fonttools
python -m fontTools.varLib.instancer "NotoSansSC[wght].ttf" wght=400 --update-name-table -o fonts/NotoSansSC-Regular.ttf
python -m fontTools.varLib.instancer "NotoSansSC[wght].ttf" wght=700 --update-name-table -o fonts/NotoSansSC-Bold.ttf

# 换字体后必须重算 manifest 的 font.bundled（size + sha256），再跑：
python tools/check_font_coverage.py
```

- 字体**不进 `files/`**：`files/` 是覆盖树，还要逐字节进哈希清单；CI 有守卫专门拦这件事。
- 载荷里 6 个 `mod.yaml` 的字体引用按上游顺序写死：上游 `FreeSans` 位 → Regular，
  上游 `FreeSansBold` 位 → Bold。改字体名时这两处要一起改，否则运行时会找不到文件。
- 换了字体或改了字号，先在 4 个 UI 缩放档位目测一遍行高（Noto 与 SimHei 的 ascender 不同）。

> 改白名单时记得同步 `RELEASE_FILES` / `RELEASE_DIRS` / `PACKAGE_LAYOUT`，以及 README 的
> 「包里有什么」表格。`PACKAGE_LAYOUT` 负责「仓库在根目录、包里收进 `bin\`」这种映射，
> 新增需要挪位的文件时改它，不要手工改 `install.ps1` 里的相对路径假设——
> 脚本会自己向上找 `files\`，仓库里直接跑和包内跑都能用。

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

`.github/workflows/validate.yml` 在 `push` / `pull_request` 时跑八步（Linux runner）：

1. `verify_manifest.py` —— 载荷与 `manifest.json` 逐字节一致；
2. `lint_ftl.py files/mods` —— Fluent 规范（BOM / 换行 / 缩进 / 花括号）；
3. `struct_check_maps.py files/mods` —— 地图文案结构自检；
4. `check_links.py .` —— Markdown 相对链接与锚点（`docs/` 引用根目录文件必须写 `../`）；
5. `build_readme_inventory.py --check` —— 包内 README 的附录 A 与 `manifest.json` 一致；
6. `check_font_coverage.py` —— 载荷里的每个字符，随包字体都画得出来；
7. 守卫：`files/` 中不得出现 `.ttf` / `.ttc` / `.otf`；
8. `build_release.py --verify` —— 打包自校验：入口齐全、`bin/manifest.json` 一致、
   载荷与字体的 size+sha256、**包内 Markdown 的相对链接必须落在包里**。

> 第 4 步只保证链接"在仓库里"能解析。README 一旦打进 zip，指向 `CONTRIBUTING.md` /
> `docs/` 的链接就会全变成死链，而仓库侧完全看不出来——所以第 8 步另做一次包内链接检查。
> 这也正是**仓库首页 `README.md` 与包内 `PACKAGE-README.md` 必须分开**的原因：读者不同，
> 能引用的文件也不同。

> 第 2 步对 **CRLF 换行**判错并返回退出码 1。`.gitattributes` 已声明 `files/** -text`（不转换换行），
> 所以载荷在本地就必须是 LF——不要用编辑器批量转换换行，否则 `manifest.json` 的哈希会全部失效。

## 端到端验证记录

安装脚本用 Windows PowerShell 5.1 语法编写（不依赖 PowerShell 7），
在 `playtest-20261026` 的完整安装副本上从零跑通（1.4.0，2026-10-30）：

| 验证项 | 结果 |
|---|---|
| `setup.cmd`（菜单 1）安装（208 文件 + 字体） | 通过，SHA-256 载荷校验通过 |
| `OpenRA.Utility.exe <mod> --check-yaml`（6 个模组） | 全部通过（退出码 0） |
| `OpenRA.Utility.exe <mod> --check-yaml mods/<mod>/maps/<地图>/map.yaml`（162 张地图） | 全部通过 |
| `--extract-chrome-strings` 界面键缺失检测 | 无缺失（无 `Adding` 行） |
| `check_yaml_fluent_refs.py` 与原版差分 | 0 个新出现的未解析键 |
| `validate_ftl.py` 逐键比对（174 个 `.ftl`） | 键、占位符、复数选择器全部一致 |
| `struct_check_maps.py` 地图文案结构校验（146 个 `map.ftl`） | 0 处问题 |
| `audit_coverage.py` 覆盖率审计 | 硬编码英文 0 处、脚本上屏英文 0 处；仅剩 26 条应保留的英文（品牌 / 缩写 / 键盘按键名）与 162 处地图元数据 |
| 字体引用可落地性 / 字形覆盖 | 全部存在，无缺字 |
| `-DryRun` 预演 | 确认零写入（整棵目录树重新哈希，0 差异） |
| `-Uninstall` 还原 | 2595 个文件逐字节一致，0 差异 |

> **验证命令的副作用**：`OpenRA.Utility.exe <mod> --extract-chrome-strings` 不是只读命令，
> 它会就地重写被加载的 chrome yaml（UTF-8 BOM 会丢）。只在**一次性的安装副本**上跑；
> 在实机目录上跑过之后再做 `-Uninstall` 的逐字节比对，会看到 `chrome/load-game-browser.yaml`
> 这类"内容不同"的假警报。

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
