# 更新日志

## 1.5.4 — 2026-11-01（本地构建，未发布）

**入口全面改成 `.ps1`：`setup.cmd` 删除，仓库与发布包里不再有任何 `.bat` / `.cmd`。**

- `src/setup.ps1` 取代 `setup.cmd`：只做参数转发（不带参数 → `-Menu`），用**当前正在运行的解释器**
  起子进程，PS5 / PS7 混用不会串台。退出码原样透传；非 0 时提示"组策略可能封了脚本"并停住。
- 代价写清楚了：Windows 对 `.ps1` 的默认动词是 `Edit`，**双击只会打开记事本**，
  必须右键 →「使用 PS 运行」。文档里所有"双击"已改成这个说法。
  恢复双击体验的两条路（`.lnk` 垫片 / 单文件 exe）记在 `docs/MAINTAINING.md`，暂不做。
- CI 守卫从"只允许存量 setup.cmd"收紧为**零例外**：出现任何 `.bat` / `.cmd` 直接失败。
- 同步更新 README / 包内 README / 安装说明 / ANATOMY / MAINTAINING / CONTRIBUTING / issue 模板。

**验证**：`setup.ps1 -DryRun` 与 `-Uninstall` 的转发、退出码、菜单入口在假目标目录上跑通；
`build_release --verify` 通过，包内顶层由 `setup.ps1` 取代 `setup.cmd`，其余 8 项不变。
载荷与译文零改动。

## 1.5.3 — 2026-10-30（本地构建，未发布）

**仓库结构整理 + 过期表述修正，载荷与译文一个字未改。**

起因是清点仓库时发现两件事：根目录把"打包源、玩家文档、项目文档、许可"全平铺在一起（13 个文件），
以及 1.5.0 改为随包字体后，有 6 处文档仍在说"不分发字体 / 从系统复制 simhei"。

结构：

- 新增 `src/`：`setup.cmd`、`install.ps1`、`manifest.json`、`PACKAGE-README.md`、
  `安装说明.txt/.md` 全部归位，**要打进包的东西集中在一处**；打包时按 `PACKAGE_LAYOUT`
  映射回包根与 `bin/`。
- `CONTRIBUTING.md`、`CHANGELOG.md` 移入 `docs/`；`tools/rasc-ref/` 归档到
  `docs/archive/rasc-ref/`（23 个文件 / 379 KB，代码零引用，保留作为译名对齐的证据链）。
- 根目录从 13 项降到 5 个文件（`README.md`、`LICENSE`、`LICENSE-OFL.txt`、`.gitattributes`、`.gitignore`）。

文案（都是 1.5.0 之后的遗留错）：

- `ANATOMY` / `MAINTAINING` / `CONTRIBUTING` / `build_manifest.py` 里"不分发字体"改为
  "字体在 `fonts/`，由安装器单独部署，不进载荷"；`mod.yaml` 的字体示例从 `SimHei.ttf`
  改为 `NotoSansSC-Regular/Bold.ttf`。
- `install.ps1` 的说明文字仍写引擎版本 `playtest-20260222` → 改为 `playtest-20261026`。
- issue 模板里的安装方式 `install.bat` → `setup.cmd`。

工具：

- `build_release` / `build_manifest` / `verify_manifest` / `build_readme_inventory` 的路径常量
  全部改到 `src/`；`build_release` 的 `collect()` 去重（同一文件同时出现在白名单与映射表时
  之前会写两遍）。
- `check_links` 跳过 `src/PACKAGE-README.md`、`src/安装说明.md`：它们的链接是**包内相对路径**，
  在仓库里解析必然是假死链；包内链接由 `build_release --verify` 的 `check_package_links()` 单独校验。

**验证**：`build_release --verify` 通过（218 文件 / 12.4 MB）；仓库布局与包布局**各跑一遍**
安装→卸载，`ra/fluent/rules.ftl` 中文行 689 → 0、字体删净；其余 CI 五步全过。

## 1.5.2 — 2026-10-30（本地构建，未发布）

**修复：卸载可能"看起来没效果"** —— 载荷与译文未变，只改还原逻辑。

现象：在已经汉化过的目录上又装了一次补丁，之后再卸载，界面还是中文，而且
`_zhcn-backup` 里会多出一个 `.已还原.已还原.已还原` 的目录。

两处原因，都要修：

- 卸载用 `Sort-Object Name -Descending` 挑"最新备份"，**不认 `.已还原` 标记**。
  还原后目录名只是追加后缀，排序位置不变，于是每次都挑中同一份；而这份备份是在
  已汉化的树上生成的，里面存的就是译文 —— 还原当然"没效果"。
- 在已汉化的目录上再装一次时，安装器会把**译文当成"原件"备份下来**，这种备份从此
  无法用于还原，还会顶掉真正可用的旧备份。

改动：

- 挑选备份时跳过名字带 `.已还原` 的；再校验内容，**含 `same` 条目或抽样与载荷逐字节相同**
  的一律判为"重复安装快照"并跳过，屏幕上说明跳过了哪一份。
- 安装时若目标文件已与载荷一致，记为 `same` 并**不再复制进备份**（不再污染备份），
  汇总里显示"已是译文 N 个"。
- 新增 `-Backup <目录名或路径>`，手动指定用哪一份还原。
- 全部备份都不可用时**明确报错退出**（退出码 1）并给出下一步，而不是挑一份译文快照假装成功。
- 还原时顺带清理本补丁遗留的字体（`NotoSansSC-*.ttf` / `simhei.ttf`），只删这几个已知名字。
- 还原标记改成 `.已还原` / `.已还原-2`，不再叠成 `.已还原.已还原...`。

**验证**（在 `playtest-20261026` 的完整副本上）：
干净基线装→卸，`ra/fluent/rules.ftl` 中文行 689 → 0，两个字体被删除；
重复安装后再卸，自动跳过译文快照、改用第一份备份还原回英文；
全部备份耗尽时，报"没有可用的备份"并退出 1。

## 1.5.1 — 2026-10-30（本地构建，未发布）

**只改文档与打包，载荷 208 个文件逐字节未变** —— 装过 1.5.0 的人不需要重装。

起因是"README 说了有 8 项，可解压出来一堆 `files\` 里的东西不知道是什么"。原来那一节只列了顶层，
`files\` 里 208 个文件一句"文本载荷"带过，等于没解释。

- **README 重写**：顶层 9 项（6 文件 + 3 目录）逐项说明"干什么 / 谁在用 / 能删吗"；
  新增「`files\mods\` 里到底装了什么」，讲清覆盖树、8 个目录各管什么、6 种文件各是什么；
  新增**附录 A：全部 208 个文件清单**（每个文件一行，含大小与作用）。
- **仓库首页与包内 README 分开**：原来同一个 `README.md` 既当 GitHub 首页又打进 zip，
  结果包里 6 个链接（`CONTRIBUTING.md`、`CHANGELOG.md`、`docs/*`）指向 zip 里不存在的文件。
  现在仓库根是开发者向的 `README.md`，包内是 `PACKAGE-README.md`（打包时改名回 `README.md`），
  后者只引用包内确实存在的文件；`build_release.py --verify` 新增**包内死链检查**兜住这类问题。
- **清单不再手写**：`tools/build_readme_inventory.py` 从 `manifest.json` 渲染附录，
  `--check` 断言 README 与清单一致，CI 加了一步。以后改载荷忘了同步 README 会被直接挡下。
- 顺手修掉 1.5.0 遗留的过期表述：README 里"不分发字体""手动安装复制 simhei.ttf"
  "粗体被替换为同一字体"（现在有真粗体）、"8 项"计数；`安装说明.txt` 的 AI 提示词里
  `simhei.ttf 是否存在` 也改成两个 NotoSansSC 字体。

**校验**：`build_readme_inventory.py --check`（208）、链接与锚点、载荷↔清单、Fluent 规范、
地图结构、字体字符覆盖（1579 字）全部通过；`build_release.py --verify` 通过。

## 1.5.0 — 2026-10-30（本地构建，未发布）

**字体改为随包自带**，不再依赖本机装没装中文字体。

- 随包带 **Noto Sans SC 全量字形**（Regular / Bold 两个静态实例，各约 10 MB）。
  上游只发可变字体 `NotoSansSC[wght].ttf`，用 `fonttools varLib.instancer` 固定成
  `wght=400` / `wght=700` —— 只固定字重，**字形一个都不删**（不是子集化）。
  许可 SIL OFL 1.1，附 `LICENSE-OFL.txt`。
- 载荷里 6 个 `mod.yaml` 的字体引用，从"两处都写 `SimHei.ttf`"改为按上游
  `FreeSans` / `FreeSansBold` 的位置分别指向 `NotoSansSC-Regular.ttf` / `-Bold.ttf`。
  **这是本补丁第一次有真粗体**。其余 202 个载荷文件逐字节未变。
- 安装器字体逻辑改为三级：`-FontPath` > 包内 `fonts\` > 系统字体；
  **包内与系统都没有时直接中止**，修掉 1.4.x "只警告两句、装完游戏打不开"的缺陷。
  卸载时把两个字重一起删掉，`-Verify` 也会检查它们。
- 新增 `tools/check_font_coverage.py` 与 CI 一步：扫描载荷里出现的每个字符，
  断言随包字体都画得出来（当前 1579 个字符，两个字重全覆盖）。
- `build_release.py` 白名单加入 `fonts/**`、`LICENSE-OFL.txt`；`--verify` 增加字体哈希校验。
- 包体积 270 KB → **12.4 MB**（218 个文件）。字体本身占 21 MB，zip 后约 12 MB。

**校验**：`build_release.py --verify` 通过（字体 size+sha256、208 个载荷）；
在 `playtest-20261026` 的英文基线上安装 → `-Verify` → `-Uninstall` 后**逐字节还原**
（2595 文件，0 差异）；6 个模组 `--check-yaml` 退出码 0。

**未验证**：字体在小字号下的观感与行高对齐（Noto 的 ascender 与 SimHei 不同），
需要在 4 个 UI 缩放档位人眼确认——只能由维护者在本机看。

## 1.4.2 — 2026-10-30（本地构建，未发布）

只改「包的样子」，**译文与载荷一个字都没动**（208 个载荷文件与 1.4.1 逐字节相同）。

**布局：脚本收进 `bin\`**

解压后顶层只剩入口与说明，脚本与清单挪进 `bin\`：

```
setup.cmd
README.md / 安装说明.txt / 安装说明.md / LICENSE
bin\install.ps1   bin\manifest.json
files\            208 个文本载荷
```

`install.ps1` 不再假定自己与 `files\` 同级：它先看脚本目录，找不到 `files\` 就向上一级找，
所以仓库里直接跑、包内 `bin\` 里跑都能用。

**说明文件：改名 + 双版本**

- `INSTALL.txt` → **`安装说明.txt`**
- 新增 **`安装说明.md`**：同一份内容的 Markdown 版（有标题层级与表格，GitHub 上可读）

**README：逐文件说明**

「包里有什么」升级成一张表：每个文件的**作用 / 谁读它 / 能不能删**，
并新增「`bin\` 里两个文件别单独挪动」的提醒。

**打包**

白名单同步为 `setup.cmd` / `README.md` / `安装说明.txt` / `安装说明.md` / `LICENSE` /
`bin\install.ps1` / `bin\manifest.json` / `files\**`；`--verify` 同步改成检查
`bin\manifest.json` 与仓库一致、208 个载荷哈希、无多余文件。

**校验**

- `build_release.py --verify` 通过（215 个文件）
- 用打包后的目录在 `playtest-20261026` 完整副本上装 → 校验 → 还原，还原后逐字节一致
- CI 四项本地复跑通过

## 1.4.1 — 2026-10-30

只改「怎么装」，**译文一个字都没动**：载荷 208 个文件与 1.4.0 逐字节相同，哈希未变。

**入口合并：三个 bat → 一个 `setup.cmd`**

- `install.bat` / `uninstall.bat` / `verify-uninstall.bat` 删掉，合并为 `setup.cmd`。
  双击出中文菜单（安装 / 还原 / 卸载校验 / 预演），全部逻辑仍在 `install.ps1`。
- `setup.cmd` 保持**纯 ASCII + CRLF**（bat 里放中文会因代码页乱码）；带参数时原样透传给
  `install.ps1`，所以 `setup.cmd -Uninstall` 与原来的 `uninstall.bat` 等价。
- `install.ps1` 新增 `-Menu`；`-Uninstall` / `-DryRun` 结束时补 `exit 0`，避免菜单里返回码漂移。

**新增 `INSTALL.txt`（给玩家的纯文本，UTF-8 + BOM + CRLF，记事本直接看）**

含四段：三步装好 / **手动安装** / **让 AI 助手帮你装** / 常见问题。

文件名刻意用 ASCII：`安装说明.txt` 在资源管理器 / 7-Zip 里没问题，但老的命令行 `unzip`
不认 zip 的 UTF-8 名称标志，解出来会是 `իëÞúà޻¦µÄ.txt` 这样的乱码。

手动安装强调了一个容易踩的坑：补丁的 `mod.yaml` 已经指向 `common|SimHei.ttf`，所以必须
**先放字体、再覆盖文本**——顺序反了不是"变方块"，而是引擎启动时读不到字体文件、**直接报错退出**。

**发布包瘦身：258 → 213 个文件**

`build_release.py` 改为**白名单**打包，发布包只含：

```
setup.cmd / install.ps1 / manifest.json / INSTALL.txt / LICENSE / files/**
```

`tools/`、`docs/`、`.github/`、`CONTRIBUTING.md`、`CHANGELOG.md`、`.gitattributes` 不再进包
（原来解压出来是一堆 `.py`）。要全量快照用 `--dev`，输出 `*-dev.zip`。
体积 387 KB → **260 KB**。

`--verify` 同时改为**包内自校验**（不再依赖 `tools/`）：入口文件是否齐全、包内 `manifest.json`
是否与仓库一致、208 个载荷的 size/sha256、`files/` 里有没有多余文件。

**校验**

- `build_release.py --verify` 通过（213 个文件 / 260 KB），包内 208 个载荷 size+sha256 全对。
- 在 `playtest-20261026` 的完整副本上跑「菜单 → 预演 → 安装 → 卸载校验 → 还原」：
  安装 208 文件 + 字体正常，`-DryRun` 零写入，还原后与英文原版**逐字节一致**（2595 文件，0 差异）。
- CI 四项本地复跑通过（载荷↔清单、Fluent 规范、地图结构、Markdown 链接）。

## 1.4.0 — 2026-10-30

适配 **OpenRA `playtest-20261026`**。上游这次改动不小：新增 164 条文案、改写 18 处英文原文、
删掉整个 `ts`（泰伯利亚之日）模组、沙丘 2000 补上了阿特雷德斯与奥多斯两条战役的后半段（11 张新地图）。
旧版 1.3.1 的载荷是照着 `playtest-20260222` 的目录写的，**直接套到新引擎上不会回退成英文，而是显示原始键名**，
所以必须重做一版。

**迁移做法**

- 三方合并：`base` = 旧版英文（`playtest-20260222` 源码）、`ours` = 1.3.1 译文、`theirs` = 新版英文。
  译文按 key 精确迁移，**文件结构一律取新版**——新增、删除、重排的消息都跟着上游走，
  不会出现「译文带进旧版已删键」的情况。
- 全新翻译 164 条（见下）；英文原文变了的 18 处逐条复核后改写译文。

**新增译文**

- **作弊面板**（`common/fluent/ingame-debug.ftl`，29 条）：瞬间建造、随处建造、无限电力、
  显示单位路径 / HPF 叠加层 / 战斗几何、给予 $20,000 等。新引擎把 `Debug` 菜单正式改名为 `Cheats`，
  相关条目（`menu-game-info.debug`、`checkbox-debug-menu.label`）一并改为「作弊」。
- **OpenRA 论坛账号关联**（`common` / `cnc` 各 47 条）：关联/解除关联账号、用户名密码输入、
  认证失败、封禁、登录尝试超限等提示。
- **存档与载入浏览器**（`Load Game` / `Choose Save` / 存档不兼容 / 创建日期 / 时长 / 玩家数量）。
- **地图预览可见性**（所有人可见 / 仅地图选择器可见 / 隐藏）与分辨率「预设」。
- **d2k 新增 11 关战役简报**（`atreides-06a/06b/07/08/09a/09b`、`ordos-06b/07/08/09a/09b`）
  与 10 条任务目标（`starport-destroyed`、`its-a-trap`、`mercenary-leader` 等）。
- 快捷键 3 条（快速存档、隐藏界面、隐藏额外界面）、`ra` 的 `meta-mine`（地雷）、
  作弊通知（`notification-cheat-enabled/disabled`）。

**跟随英文原文修正的旧译文**

- d2k 单位说明的强弱项：`Artillery` → `Rocket Artillery`（火炮 → 火箭炮）、
  `Vehicles` → `Tanks`（车辆 → 坦克）、破坏者新增「对车辆强 / 摧毁建筑与车辆」。
- d2k 百科「视野」项：三轮摩托、突袭三轮摩托 `Small → Large`（小 → 大），变节者 `Large → Medium`（大 → 中）。
- 重型工厂升级描述里上游删掉了「维修台」，译文同步删除。
- 出生点标签新增占位符：`label-available-spawn` / `label-disabled-spawn` 现为
  「可用的出生点 { $spawn }」「已禁用的出生点 { $spawn }」（旧译文缺占位符会被引擎判为不匹配）。
- 开发者命令说明由「对所选单位的拥有者」改为「对本地玩家」。
- `Save game` → `Save Game`（仅大小写，译文不变）、`cnc` 主菜单标题 `Main Menu` → 「主菜单」。

**引擎侧变动（已确认不影响本补丁）**

- `ts` / `ts-content` 两个包从 playtest 中移除，本补丁原本未覆盖，载荷无需处理。
- 三个模组的 `FluentMessages` 都新增了 `common|fluent/ingame-debug.ftl`；
  `cnc` 改用自身的 `cnc|chrome/ingame-debug.yaml`，`ra` 新增 `common|chrome/load-game-browser.yaml`。
  `mod.yaml` 一律以新版英文为底稿重新生成（再替换字体引用），旧补丁的 `mod.yaml` 不可复用。
- 字体仍为 `FreeSans.ttf` / `FreeSansBold.ttf`，安装脚本照旧替换为系统中文字体。

**统计口径**

`manifest.json` 的 `stats` 改由 `tools/build_manifest.py` 自动重算（口径写在脚本与
[MAINTAINING](MAINTAINING.md) 里），不再手填。因此本版数字与旧版**不可直接比较**：

| 项 | 1.3.1（手填） | 1.4.0（自动重算） |
|---|---|---|
| Fluent 文案 | 2,504 | **3,036**（非地图 `.ftl` 的顶层消息数） |
| 安装源名称 | 30 | **20**（`installer/*.yaml` 的顶层节点数） |
| 战役简报 | 129 | **140** |
| 载荷文件 | 196 | **208** |

**校验**

- 载荷 208 个文件，`verify_manifest.py` 0 问题；`lint_ftl.py` 174 个 `.ftl` 0 问题；
  `struct_check_maps.py` 146 个 `map.ftl` 0 问题。
- 引擎侧：6 个模组 `--check-yaml` 全部退出码 0；`--extract-chrome-strings` 无缺失键；
  **162 张地图**逐张 `--check-yaml` 全部通过；`check_yaml_fluent_refs.py` 差分 0 个新出现的未解析键；
  `validate_ftl.py` 174 个文件逐键（占位符、选择器）全部一致。
- 安装脚本：`-DryRun` 零写入；完整安装 → `-Uninstall` 还原后与英文原版**逐字节一致**
  （2595 个文件，0 差异）。

## 1.3.1 — 2026-09-30

把**红警 / 泰伯利亚黎明**的单位与建筑显示名，对齐到 OpenRA 汉化组（CastleJing）的
**RASC / TDSC** 译文共识全称。d2k（沙丘 2000）的汉化组 D2KSC 未公开，无法对齐，维持既有译文。

**做法**

- 克隆汉化组 `OpenRA_rasc`（红警）、`OpenRA_tdsc`（泰伯利亚黎明）作参考基线；按英文单位 ID 锚定，
  逐个比对我们的 `ra/cnc/fluent/rules.ftl` 的 `.name`。
- 仅替换**匹配到汉化组本体词条**的显示名；残骸（`husk`）短名一并补全为全称。红警用 `残骸（X）` 包装、
  泰伯利亚黎明用 `X（已摧毁）` 包装，两种包装形式都用「子串替换」统一处理（如 `雌鹿` → `雌鹿武装直升机`、
  `残骸（移动建造车）` → `残骸（移动基地车）`、`移动建造车（已摧毁）` → `移动基地车（已摧毁）`）。
- 用脚本按块隔离解析、只取本体 actor 的 `Tooltip.Name`，规避了「把 `.Husk` 残骸条目误当本体名」
  与「诱饵建筑名被占位名污染」两个提取坑。

**改动量**

- `ra`：`actor-*.name` 50 处 + 残骸名 7 处
- `cnc`：`actor-*.name` 32 处 + 残骸名 10 处
- 共 99 处对齐到汉化组全称（如 机场→战地机场、长弓→长弓武装直升机、移动建造车→移动基地车、
  磁暴坦克→磁能坦克、黑幕发生器→裂缝产生器、兵营合并为通用名等）

**刻意保留**

- **诱饵建筑**（`伪装发电厂`/`伪装兵营`…）保留「伪装」二字，比汉化组的「发电厂模型」更直观，未强制改。
- 此前 `支奴干` → `支努干` 的错别字修复（11 处）当时未入 manifest，本次哈希一并修正。

**校验**

- 载荷 196 个文件，manifest 哈希全部重算并校验一致（0 问题）
- Fluent 语法检查：**0 问题**（`tools/lint_ftl.py` 退出码 0）

**一致性修复（仓库体检）**

- 4 个载荷 `.ftl` 由 CRLF 归一化为 LF（`ra/fluent/lua.ftl`、`ra/maps/allies-05{a,b,c}/map.ftl`）——
  它们原本是 162 个 `.ftl` 里仅有的 CRLF，会让 CI 的「Fluent 文件规范」一步失败（`lint_ftl.py` 退出码 1）。
- `install.ps1` 的窗口标题不再写死版本，改为从 `manifest.json` 动态读（原写死 `v1.3.0`，与清单不符）。
- `verify-uninstall.bat` 改为**纯 ASCII + CRLF**，与 `install.bat`/`uninstall.bat` 统一（原含中文、且为 LF）。
- 文档残留旧版本号修正：`README.md`（`1.2.0`）、`CONTRIBUTING.md`（`1.3.0`）、
  `tools/build_manifest.py` 用法示例（`1.3.0`）→ `1.3.1`。
- **文档按读者拆分**：`README.md` 重写为纯玩家向（安装 / 参数 / 覆盖范围 / 卸载 / 已知问题）；
  新增 `docs/ANATOMY.md`（逐文件职责、`.ftl` 六类与**加载时机**、`tools/` 脚本分工）与
  `docs/MAINTAINING.md`（载荷生成、发布流程、CI、验证记录、CLI 备忘）；
  `CONTRIBUTING.md` 保持贡献者向并加上文档互链；README 补充「致谢」小节
  （OpenRA 项目、汉化组 RASC/TDSC、字体作者与所有贡献者）。
- **仓库名对齐真实仓库**：项目里 168 个文件（162 个 `.ftl` 的 SPDX 头注释 + `README.md` / `LICENSE` /
  `manifest.json` / `tools/build_manifest.py` / `docs/*`）由 `OpenRA-simplified-chinese` 统一改为
  GitHub 上的实际仓库名 **`OpenRA_simplified_chinese`**；`manifest.json` 的 `repository` 填为
  <https://github.com/Janlhin/OpenRA_simplified_chinese>，162 个载荷文件的哈希随之重算。
- **新增 CI 第 5 步**：`tools/check_links.py` 校验 Markdown 的相对链接与锚点——此前 `docs/` 下把
  `../README.md` 写成 `README.md` 会静默指向不存在的文件，现在会在 PR 上被挡下。脚本 8 → 9 个。
- README 顶部启用 CI 徽章（`validate` 工作流）。
- **`tools/build_release.py` 入库**：确定性打包发布包（zip 时间戳取自 `manifest.json` 的
  `releaseDate`，同一份内容重复构建字节一致），`--verify` 会解压到临时目录并重跑四项校验。
  脚本 9 → 10 个。
- **首个 Release 已发布**：`v1.3.1`，附件 `OpenRA_simplified_chinese-1.3.1.zip`（296 KB）。

## 1.3.0 — 2026-09-30

一次**全量查漏补缺**：写了一个覆盖率审计工具，把"还没翻的地方"逐类扫出来并全部补齐。
载荷从 187 个文件增加到 196 个（580 KB），版本号 1.2.0 → 1.3.0。

**审计方法**（新工具 `tools/audit_coverage.py`）

对比英文原版与汉化目录，分四类输出：① Fluent 条目里仍无汉字的；② `.ftl` 之外可能上屏的硬编码
英文（按字段归类）；③ `.lua` 脚本里直接上屏的英文字面量；④ 已知且故意不改的（附原因）。

**本轮修复的 6 类残留**

1. 红色警戒 `allies-02` / `allies-04` / `allies-05a` 的**难度下拉**仍是英文（此前只译了简报，漏了难度块）
2. **战役分组名** 16 个（`Allied Campaign` / `GDI Campaign` / `阿特雷德斯战役`…）——任务浏览器里的大标题
3. 内容安装器的**悬停提示** 4 处（`The Remastered Collection doesn't include trailer.vqa.`）
4. 建服对话框**预填的服务器名** 2 处（`My OpenRA Server` → 我的 OpenRA 服务器）
5. 地图内硬编码**倒计时文本** 3 处（车队抵达 / 导弹抵达 / 沙林释放）
6. 地图脚本里直接上屏的硬编码英文 1 处（`allies13.lua` 的 `We're too late!`）

**审计结论**

- 硬编码英文：**0 处**；脚本上屏英文：**0 处**
- Fluent 里仅剩 26 条仍是英文，全部是应保留的：品牌与缩写（`OpenRA` / `GDI` / `Nod` / `HAL 9001` /
  `ID` / `MAX` / `APM`）与键盘按键名（`Alt` / `Ctrl` / `Shift` / `Esc` / `Home` / `WWW`…）
- 地图元数据里的地图标题 144 处**故意不改**：地图 UID = `SHA1(map.yaml + *.bin + *.lua + map.png)`，
  改动会让打了补丁的玩家与未打补丁的玩家地图哈希不一致、旧录像找不到地图。`.ftl` 不参与 UID 计算，
  所以译文本身不影响联机兼容性。

**注意（兼容性）**

第 5、6 项修改了 3 张地图的 `rules.yaml` / `allies13.lua`，这 3 张地图（`allies-02`、`allies-10a`、
`allies-13`）的 UID 因此变化：打了补丁后无法播放此前用英文版录制的这 3 关录像。其余 148 张地图不受影响。

## 1.2.0 — 2026-09-30

补齐最后一块：**129 份战役简报正文**（每关开始前读的那篇长文）。载荷从 52 个文件增加到 187 个
（其中 135 个是地图的 `map.ftl`），文案总量 2,504 条。

**新增翻译（156 条）**

- `ra/maps/*/map.ftl`（66 个文件 / 83 条）：战役简报、难度选项、若干单位名与特长描述
- `cnc/maps/*/map.ftl`（38 个文件 / 42 条）：战役简报、难度选项
- `d2k/maps/*/map.ftl`（31 个文件 / 31 条）：战役简报

**验证**

- 151 张地图全部通过引擎的 `--check-yaml mods/<mod>/maps/<地图>/map.yaml`
- 135 个 `map.ftl` 键集合 / 取值非空 / 行首缩进结构校验：0 处问题
- 新增工具 `tools/struct_check_maps.py`：不依赖第三方库的地图文案结构检查器

**仍然缺失**

- 少量硬编码在 yaml 里的地图标题与倒计时文本

## 1.1.0 — 2026-09-30

补齐 **泰伯利亚黎明** 与 **沙丘 2000** 的全部模组专属文案，并补上红色警戒遗留的单位与战役文案。
载荷从 38 个文件增加到 52 个，文案总量从 1,117 条增加到 2,348 条。

**新增翻译（共 1,231 条）**

- `d2k`（沙丘 2000，312 条）：chrome 23、rules 178、lua 94、campaign 5、d2k 4、hotkeys 8
  —— 单位/建筑名称与说明、任务目标、遭遇战选项、地图生成器
- `cnc`（泰伯利亚黎明，919 条）：chrome 514、rules 301、lua 81、campaign 9、cnc 7、hotkeys 7
  —— 含 cnc 专属的整套界面文案（三个模组各自有独立 chrome）
- `ra`（红色警戒，606 条）：rules 320（单位与建筑名）、lua 286（战役目标与任务内对话）

**术语表**（节选）

- 沙丘：香料 / 索拉里斯 / 门塔特 / 采集车 / 搬运机 / 扑翼机 / 风阱 / 星港 / 穴地 / 萨杜卡 / 变节者 / 死亡之手
- C&C：泰伯利亚 / 工程师 / 特种兵 / 奥卡 / 猛犸坦克 / 光明方尖碑 / Nod 之手 / 离子炮
- 红警：磁暴线圈 / 超时空传送仪 / 铁幕装置 / 猛犸坦克 / 谭雅 / 黑幕发生器 / 自爆卡车

**其它**

- 载荷生成改为「自动比对汉化副本与英文原版」得出改动清单，避免漏文件
- 明确排除字体文件，补丁包不含任何 `.ttf`

**仍然缺失**

- 战役简报正文（`mods/*/maps/*/map.ftl` 的 `briefing`，共 129 份）
- 少量硬编码在 yaml 里的地图标题与倒计时文本

## 1.0.0 — 2026-09-30

首个公开版本，适配 **OpenRA playtest-20260222**。

**翻译**

- 界面文案 1,117 条 Fluent 消息，覆盖 12 个 `.ftl`：
  - `mods/common/fluent/`：chrome(497)、common(325)、hotkeys(165)、rules(13)
  - `mods/ra/fluent/`：chrome、ra、campaign、hotkeys
  - `mods/{common,ra,cnc,d2k}-content/fluent/`：内容安装向导与"内容管理"共 63 条
- 安装源名称 30 条（`installer/*.yaml` 首行的 `ModSource.Title` / `ModDownload.Title`）
- 字体：7 个 `mod.yaml` 的 `Fonts:` 段由 `FreeSans` 改为 `common|SimHei.ttf`

**安装器**

- 自动探测安装目录（注册表 + 常见路径），支持 `-Target` 手动指定
- 引擎版本校验：不匹配时警告并要求确认（`-Force` 可跳过）
- 载荷 SHA-256 完整性校验（`-NoVerify` 可跳过）
- 逐文件备份到 `_zhcn-backup\<时间戳>\` 并生成 `backup.json`，支持一键还原
- `Program Files` 等受保护目录自动 UAC 提权
  
**已知缺失**

- 单位与建筑名称（`ra/rules.ftl`，约 320 条）
- 战役对话字幕（约 286 条）
- 战役地图标题与倒计时等硬编码在 yaml 中的文本（约 46 处）

> 注：以上三项已在 1.1.0 中补齐，仅剩战役简报正文（129 份）。
