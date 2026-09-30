# 仓库解剖（ANATOMY）

这份文档只回答一个问题：**仓库里每个文件是干什么的、由谁读取。** 它是一份静态参考，不含操作步骤。

| 文档 | 读者 | 回答的问题 |
|---|---|---|
| [README.md](../README.md) | 玩家 | 怎么装、怎么卸、覆盖了什么 |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | 贡献者 | 想改一句译文，该怎么动手 |
| **本文档** | 好奇的人 / 新维护者 | 每个文件是什么、起什么作用 |
| [MAINTAINING.md](MAINTAINING.md) | 维护者 | 怎么重建载荷、怎么发布、CI 与验证 |

> 相对路径以仓库根目录（`README.md` 所在处）为基准；本文档位于 `docs/`，因此向上引用根目录文件时写 `../`。

---

## 一分钟看懂：这个补丁是怎么工作的

它是个**覆盖式补丁**，不是整包分发游戏——`files/` 里全是文本文件，安装时按目录结构盖到 OpenRA 安装目录上。

```
双击 install.bat
   └─ install.ps1（总调度）
        ├─ 读 manifest.json           ← 版本、适配引擎版本、196 个载荷文件的 SHA-256
        ├─ 探测 OpenRA 安装目录        ← 注册表 + Program Files\OpenRA*
        ├─ 逐文件校验 SHA-256          ← 与 manifest.json 比对，不一致就中止
        ├─ 备份被覆盖的文件            ← <OpenRA 目录>\_zhcn-backup\<时间戳>\
        ├─ 覆盖 files/ 到 mods/        ← 汉化生效
        └─ 复制本机中文字体            ← 落到 mods/common/，并同步改写 mod.yaml 的字体引用
```

四个关键设计：**只覆盖文本**、**安装前先校验哈希**、**覆盖前先备份**、**不分发字体**（安装时从你本机复制）。

---

## 目录总览

```
OpenRA_simplified_chinese/
├─ README.md / CONTRIBUTING.md / CHANGELOG.md / LICENSE
├─ install.bat / uninstall.bat / verify-uninstall.bat
├─ install.ps1
├─ manifest.json
├─ files/                             载荷：覆盖树的根
│   └─ mods/{common,ra,cnc,d2k,common-content,ra-content,cnc-content,d2k-content}/
├─ tools/                             8 个 Python 脚本（纯标准库）
├─ docs/
│   ├─ ANATOMY.md                     本文档
│   └─ MAINTAINING.md                 维护者操作手册
├─ .github/
│   ├─ workflows/validate.yml         CI
│   ├─ ISSUE_TEMPLATE/bug_report.md
│   └─ pull_request_template.md
├─ .gitattributes
└─ .gitignore
```

共 **220 个文件**，其中 `files/` 载荷 **196 个**。

---

## 根目录的 11 个文件

| 文件 | 作用 | 谁读取 |
|---|---|---|
| `install.bat` | 双击入口。纯 ASCII + CRLF（避免代码页乱码），只做一件事：调用 `install.ps1` | 玩家 |
| `uninstall.bat` | 双击还原入口 → `install.ps1 -Uninstall` | 玩家 |
| `verify-uninstall.bat` | 双击「卸载校验」入口 → `install.ps1 -Verify` | 玩家 |
| `install.ps1` | **安装/卸载/校验的全部逻辑**：目录探测、版本校验、SHA-256 校验、备份、UAC 提权、字体复制、`-DryRun`、还原、校验。Windows PowerShell 5.1 语法，UTF-8 **带 BOM**（否则 PS 5.1 会把中文读成乱码） | `install.bat` 等三个 bat |
| `manifest.json` | **补丁的身份证**：`version`、`engineVersion`、`repository`、`font`、`stats`，以及 196 条 `{path, size, sha256}` | `install.ps1`、CI、`tools/verify_manifest.py` |
| `README.md` | 玩家文档 | 玩家 |
| `CONTRIBUTING.md` | 贡献者文档：改译文流程、翻译规范、术语表、会被拒绝的改动 | 贡献者 |
| `CHANGELOG.md` | 版本历史 | 所有人 |
| `LICENSE` | GPL-3.0-or-later 全文 | 法律 |
| `.gitattributes` | 行尾规则。**`files/** -text` 是关键**：载荷必须逐字节保真，否则别的平台检出时改写换行会让 `manifest.json` 的哈希集体失效。`*.bat` / `*.ps1` 声明 CRLF | git |
| `.gitignore` | 挡掉 `*.zip`（发布产物）、`_zhcn-backup/`（安装时生成的备份）、`Thumbs.db` / `.DS_Store`、`.vscode/` / `.idea/` | git |

## `.github/`

| 文件 | 作用 |
|---|---|
| `workflows/validate.yml` | CI。`push` / `pull_request` 时在 Linux 上跑四步：载荷↔清单一致、Fluent 规范、地图文案结构、载荷中不得出现字体。详见 [MAINTAINING.md](MAINTAINING.md#ci) |
| `ISSUE_TEMPLATE/bug_report.md` | 报 bug 的模板 |
| `pull_request_template.md` | 提 PR 的模板 |

---

## `files/` 载荷

`files/` 是一棵**覆盖树**：路径与 OpenRA 安装目录的 `mods/` 一一对应，安装时直接盖上去。
它由 8 个「mod 包」组成——对应引擎里 4 个可玩模组 + 4 个内容安装包。

| 包 | 文件数 | 装的是什么 |
|---|---|---|
| `common/` | 5 | 三个模组**共用**的文案：`fluent/{common,chrome,hotkeys,rules}.ftl` + 建服默认服务器名 |
| `ra/` | 78 | 红色警戒本体：`mod.yaml`(字体) + `missions.yaml`(战役分组名) + `fluent/`×6 + `maps/`×70 |
| `cnc/` | 47 | 泰伯利亚黎明本体：同上 + `chrome/multiplayer-createserver.yaml` + `maps/`×38 |
| `d2k/` | 39 | 沙丘 2000 本体：同上 + `maps/`×31 |
| `common-content/` | 2 | 「内容下载向导」共用界面：`fluent/chrome.ftl` + `fluent/content.ftl` |
| `ra-content/` | 11 | 红警的内容源：`installer/`×9（下载源标题）+ `fluent/chrome.ftl` + `mod.yaml`(字体) |
| `cnc-content/` | 9 | 泰伯利亚黎明的内容源：`installer/`×7 + `fluent/chrome.ftl` + `mod.yaml` |
| `d2k-content/` | 5 | 沙丘 2000 的内容源：`installer/`×3 + `fluent/chrome.ftl` + `mod.yaml` |

> `*-content` 容易被忽略但很关键：游戏启动时那个 **"Install Content" 对话框不属于主模组**，
> 而是这 4 个独立包，各自有 `Fonts:` 段和自己的 `fluent/`。漏掉它们会表现为
> 「主界面是中文，但内容安装向导仍是英文、甚至按钮显示成方块」。

### `.ftl` 的六类文件与加载时机

载荷里 162 个 `.ftl` 分六类。**加载时机分两档，这点最容易误判**：

| 文件（共 162 个） | 覆盖什么 | 何时加载 |
|---|---|---|
| `fluent/chrome.ftl` ×8 | 界面外壳：按钮、菜单、对话框、设置页 | `mod.yaml` 的 `FluentMessages` —— **常驻** |
| `fluent/common.ftl` ×1 | 通用词条 | 常驻 |
| `fluent/hotkeys.ftl` ×4 | 快捷键名称 | 常驻 |
| `fluent/rules.ftl` ×4 | 单位、建筑、武器的名称与描述 | 常驻 |
| `fluent/{ra,cnc,d2k}.ftl` ×3 | 该模组的独有条目 | 常驻 |
| `fluent/lua.ftl` ×3 | 战役目标与过场台词 | ⚠️ **不常驻**，见下 |
| `fluent/campaign.ftl` ×3 | 战役浏览界面 | ⚠️ **不常驻**，见下 |
| `maps/<地图>/map.ftl` ×135 | 单张地图的简报正文与难度选项 | 该地图被加载时 |

**`lua.ftl` 与 `campaign.ftl` 不在 `mod.yaml` 的 `FluentMessages` 里**——这不是配置遗漏，
而是引擎的设计：每张**战役地图**的 `map.yaml` 自带一行加载清单，形如

```
FluentMessages: ra|fluent/lua.ftl, ra|fluent/campaign.ftl, map.ftl
```

也就是说，战役目标与台词是**跟着地图**加载的。所以这两个文件必须留在载荷里，
否则战役里的目标提示与台词不会被加载（会退化成显示消息键名）。

另有两处模组差异值得记住：

- **ra 复用** `common|fluent/{common,chrome,hotkeys,rules}.ftl`；
- **cnc / d2k 不加载 common 的 `chrome.ftl`**，各自有 `cnc|fluent/chrome.ftl` / `d2k|fluent/chrome.ftl`
  （所以 `cnc/fluent/chrome.ftl` 有 514 条，远比 common 的大）。

### 少数非 `.ftl` 载荷（共 34 个）

绝大多数文字都走 Fluent，只有少数上屏文本硬编码在 yaml / lua 里，必须直接改值：

| 文件 | 改了什么 |
|---|---|
| `mods/<mod>/mod.yaml` ×6 | `Fonts:` 段 → `common|SimHei.ttf`（`common/` 没有 mod.yaml，它不直接渲染界面） |
| `mods/<mod>/missions.yaml` ×3 | 战役浏览器里的分组名（16 个，如「盟军战役」） |
| `mods/<mod>/chrome/multiplayer-createserver.yaml` ×2 | 建服对话框的默认服务器名 |
| `mods/*-content/installer/*.yaml` ×19 | 内容下载源标题（30 条，如 `C&C The Ultimate Collection`） |
| `mods/ra/maps/*/rules.yaml` ×3 | 3 张地图的 `CountdownText` 倒计时 |
| `mods/ra/maps/allies-13/allies13.lua` ×1 | 全库唯一一处脚本上屏文本 |

### 为什么绝大多数只改 `.ftl`

> 地图 UID = `SHA1(map.yaml + *.bin + *.lua + map.png)`，**`.ftl` 不参与计算**。

所以改 `.ftl` 不影响联机兼容性；一旦改 `map.yaml` / `*.lua`，该地图的 UID 就变了，
打了补丁与没打补丁的玩家**无法同局**，旧录像也会因为找不到地图而无法播放。

这就是「任务列表里的关卡名（`Allies 01` 等 144 处 `map.yaml` 的 `Title`）**故意不翻**」的原因——
它是本项目最核心的设计约束。少数确实改了的地图文件（3 处倒计时 + 1 处脚本文本）是权衡后的例外。

---

## `tools/` 8 个脚本

纯标准库，任意平台可跑。分两类——**只有前 4 个进 CI**：

### CI / 发布必跑

| 脚本 | 作用 |
|---|---|
| `verify_manifest.py` | `files/` 载荷 ↔ `manifest.json` 是否逐字节一致（CI 第一道闸） |
| `lint_ftl.py` | Fluent 规范：BOM / 换行 / 缩进 / 花括号。**载荷里出现 CRLF 即视为错误并返回退出码 1** |
| `struct_check_maps.py` | 地图 `.ftl` 结构自检：键集合、空值、掉到第 0 列的值行 |
| `build_manifest.py` | 维护者用：diff 英文原版与汉化目录，**重建 `files/` 与全部哈希** |

### 开发审计（需要游戏本体或字体，CI 不跑）

| 脚本 | 作用 |
|---|---|
| `audit_coverage.py` | 覆盖率审计：对比原版与汉化目录，列出还没翻的地方及原因 |
| `check_yaml_fluent_refs.py` | yaml 里 `[FluentReference]` 引用的消息键能否解析；可传英文原版做**差分** |
| `validate_ftl.py` | 与英文原文**逐键**比对（占位符、复数选择器是否一致） |
| `check_font_glyphs.py` | 字体字形覆盖检查——看会不会出现方块字 |

调用示例见 [MAINTAINING.md](MAINTAINING.md#校验工具-cli-备忘)。

---

## 译文基线

红警与泰伯利亚黎明的单位、建筑名称，以 OpenRA 汉化组的
[RASC](https://gitee.com/CastleJing/OpenRA_rasc) / [TDSC](https://gitee.com/CastleJing/OpenRA_tdsc) 为参考共识
（如 `移动建造车` → `移动基地车`、`长弓` → `长弓武装直升机`）。

⚠️ 这两个仓库是 2020 年的 **pre-Fluent** 版本：中文直接内嵌在 `mods/<mod>/rules/*.yaml` 的
`Tooltip: Name:` 里，**没有任何 `.ftl`**，因此**不能直接套用**，只能按英文 actor ID 锚定、取译法字面。

沙丘 2000 没有公开的汉化组仓库（TDSC / D2KSC 只是「计划名」），维持本项目既有译法。
其余术语（香料 / 索拉里斯 / 门塔特 / 泰伯利亚 / 特种兵 / 光明方尖碑 …）见
[CONTRIBUTING.md](../CONTRIBUTING.md#翻译规范) 的术语表。

---

## `manifest.json` 在校验链中的位置

它是整个仓库的**单一事实来源**，同时被三处读取：

| 读取方 | 用途 |
|---|---|
| `install.ps1` | 安装前逐文件校验 SHA-256；显示版本与适配引擎版本；`-Verify` 时比对卸载是否干净 |
| `.github/workflows/validate.yml` | 通过 `verify_manifest.py` 确认载荷未被改动 |
| `CONTRIBUTING.md` 里的贡献流程 | 改了译文就必须同步更新对应条目的 `size` / `sha256`，否则 CI 会被挡下 |

因此任何**改动载荷字节**的操作（哪怕只改一行译文、或把 CRLF 转成 LF）都必须重算哈希。
这一点是新手最容易踩的坑。
