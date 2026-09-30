# 更新日志

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
