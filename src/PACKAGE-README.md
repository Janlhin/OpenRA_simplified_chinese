# OpenRA 简体中文汉化补丁

> 本文是**发布包内**的说明，解释这个 zip 里每个文件是什么、怎么装、怎么还原。
> 源码、开发文档与版本历史在仓库主页 <https://github.com/Janlhin/OpenRA_simplified_chinese>。

给 **[OpenRA](https://www.openra.net/)**（`playtest-20261026`）加上简体中文的补丁：
红警 / 泰伯利亚黎明 / 沙丘 2000 三个模组的界面、单位与建筑名称、任务目标，以及全部战役简报。

- 只改**文本**：不含游戏本体、美术、音频；**不碰 `map.yaml`**，所以联机与录像不受影响。
- **自带中文字体**（Noto Sans SC 两个字重），不依赖你的系统有没有中文字体。
- 覆盖前逐文件校验 SHA-256，先备份再写，可一键完全还原。
- 全程本地运行，不联网。

> 非官方社区作品，与 OpenRA 项目无隶属关系。许可证 [GPL-3.0-or-later](LICENSE)。

---

## 三分钟装好

**系统要求**：Windows 10 / 11 + 系统自带的 PowerShell 5.1（不用另装任何东西）。

1. 把 zip 解压到一个**英文路径**下，例如 `D:\OpenRA_CN`。
2. **关闭 OpenRA**。
3. **右键 `setup.ps1` → 使用 PowerShell 运行**，在菜单里输入 `1` 回车。
   - 自动探测 OpenRA 安装目录（注册表 + `Program Files\OpenRA*`），找不到会提示你指定。
   - 装在 `C:\Program Files` 时会弹一次 UAC。
   - 引擎版本不是 `playtest-20261026` 会先警告，再问你是否继续。
4. 启动游戏，界面即为中文。

`setup.ps1` 是**唯一入口**：安装 / 还原 / 卸载校验 / 预演都在同一个菜单里，
不用记参数，也不用找第二个脚本。

### 命令行（等价用法）

```bat
setup.ps1 -Target "C:\Program Files\OpenRA (playtest)"
setup.ps1 -DryRun                 :: 只预览，不写任何文件
setup.ps1 -Uninstall              :: 还原英文
setup.ps1 -Verify                 :: 校验是否已卸干净
setup.ps1 -FontPath "D:\你的字体.ttf"   :: 换字体
```

### 参数表

`setup.ps1` 把参数原样透传给 `bin\install.ps1`，两者等价：

| 参数 | 说明 |
|---|---|
| `-Target <dir>` | OpenRA 安装目录，省略则自动探测 |
| `-FontPath <file>` | 换字体（`.ttf` / `.ttc`）。省略时先用包内 `fonts\`，包内缺失才查本机 `simhei.ttf` → `Deng.ttf` → `msyh.ttc` → `simsun.ttc` |
| `-SkipFont` | 不部署字体（引擎已配好中文字体时用） |
| `-DryRun` | 预演，不写任何文件 |
| `-Force` | 引擎版本不匹配也不再询问 |
| `-Yes` | 全程不交互 |
| `-NoVerify` | 跳过载荷 SHA-256 校验 |
| `-Uninstall` | 从最近一次备份还原 |
| `-Verify` | 校验「汉化是否已卸载干净」 |

## 这个 zip 里有什么

解压后**顶层 9 项**（6 个文件 + 3 个目录），连子目录一共 **218 个文件**：

```
OpenRA_simplified_chinese\
├─ setup.ps1                     ← 右键 → 使用 PowerShell 运行
├─ README.md                     ← 你正在看的
├─ 安装说明.txt                   ← 同一份说明的记事本版
├─ 安装说明.md                    ← 同一份说明的 Markdown 版
├─ LICENSE                       ← 补丁的 GPL-3.0
├─ LICENSE-OFL.txt               ← 字体的 SIL OFL 1.1
├─ bin\
│   ├─ install.ps1               ← 全部安装逻辑
│   └─ manifest.json             ← 清单：版本 + 208 条哈希 + 字体哈希
├─ fonts\
│   ├─ NotoSansSC-Regular.ttf    ← 正文字体（约 10 MB）
│   └─ NotoSansSC-Bold.ttf       ← 标题/粗体（约 10 MB）
└─ files\
    └─ mods\                     ← 208 个中文文本，覆盖到游戏的 mods\
```

| 项 | 它到底干什么 | 谁在用 | 能删吗 |
|---|---|---|---|
| `setup.ps1` | **唯一入口**。右键「使用 PowerShell 运行」出中文菜单；带参数时原样透传给 `bin\install.ps1` | 玩家 | 删了只能手动安装 |
| `bin\install.ps1` | 全部逻辑：找游戏、判版本、校验哈希、备份、提权、部署字体、还原 | `setup.ps1` 调用 | **不能删** |
| `bin\manifest.json` | 补丁的身份证：版本、适配的引擎、208 个载荷的 `{path,size,sha256}`、字体清单 | 安装器校验用 | **不能删** |
| `files\mods\` | 208 个中文文本，目录结构与游戏 `mods\` 完全一致（见下节） | 安装器覆盖进游戏 | **不能删**（删了等于空包） |
| `fonts\NotoSansSC-Regular.ttf` | 正文字体，装进 `mods\common\` | 安装器 | **不能删**（删了回退系统字体，系统也没有就装不了） |
| `fonts\NotoSansSC-Bold.ttf` | 粗体/标题字体，同上 | 安装器 | 同上 |
| `README.md` | 本文件：每个文件是什么、怎么装、怎么还原、常见问题 | 玩家 | 可以删，但建议留着 |
| `安装说明.txt` / `安装说明.md` | 安装步骤（纯文本版，记事本直接看；Markdown 版内容相同） | 玩家 | 可以删 |
| `LICENSE` / `LICENSE-OFL.txt` | 补丁的 GPL-3.0；随包字体的 SIL OFL 1.1 | 法律 | **不能删**（合规） |

`bin\` 里两个文件互相依赖，别单独挪动——`setup.ps1` 按相对路径找它们。

研发资产（`tools/`、`docs/`、`.github/`、`CONTRIBUTING.md`、`CHANGELOG.md` 等）
只留在仓库里，**不进发布包**。

## `files\mods\` 里到底装了什么

它是一棵**覆盖树**：`files\mods\ra\fluent\rules.ftl` 的意思是"覆盖到
`<游戏目录>\mods\ra\fluent\rules.ftl`"。路径跟游戏一模一样，不是随便建的目录。

8 个目录各管一摊：

| 目录 | 管哪些文字 | 缺了的后果 |
|---|---|---|
| `common\` | 三个游戏共用的界面、快捷键、通用提示、作弊面板 | 主菜单与设置变英文 |
| `ra\` | 红警：界面、单位/建筑名、快捷键、剧情、**战役简报** | 红警中英混杂 |
| `cnc\` | 泰伯利亚黎明：同上 | 同上 |
| `d2k\` | 沙丘 2000：同上 | 同上 |
| `ra-content\` `cnc-content\` `d2k-content\` | 内容安装向导里列出的下载源名称、光盘提示 | 装游戏本体那一步是英文 |
| `common-content\` | 内容安装器的公共文案 | 同上 |

里面只有 6 种东西，一句话就能记住：

| 文件名 | 是什么 |
|---|---|
| `fluent\*.ftl` | **文案本体**（界面、单位、技能、快捷键、剧情、作弊面板） |
| `maps\<地图>\map.ftl` | 每张战役地图的**简报正文与任务目标** |
| `maps\<地图>\rules.yaml` | 极少数没法走 Fluent 的地图内文字（倒计时） |
| `*-content\installer\*.yaml` | 安装源标题（Steam 版 / 光盘版…） |
| `chrome\*.yaml` | 写死在界面 yaml 里的文字（建服对话框） |
| `mod.yaml` | **不是文案**：把字体指向中文字体、声明加载哪些 `.ftl` |

> `files\` 里**没有一份 `map.yaml`**，这是故意的。地图 UID = `SHA1(map.yaml + *.bin + *.lua + map.png)`，
> 改了 `map.yaml` 就会让打了补丁的玩家与没打补丁的玩家**地图哈希不一致**（无法同局），
> 旧录像也会因为找不到对应地图而播不出来。所以任务列表里的 `Allies 01`、`GDI 06` 保持英文。

每一个文件的完整清单（208 行，含大小与作用）见文末 **[附录 A](#附录-a全部-208-个文件清单)**。

## 手动安装（不运行脚本）

适用：不想跑脚本，或公司电脑用组策略禁掉了 PowerShell。

**顺序不能错**：`files\` 里的 `mod.yaml` 已经指向 `common|NotoSansSC-Regular.ttf` 与
`common|NotoSansSC-Bold.ttf`，所以「先覆盖文本、后放字体」会让引擎读不到字体文件——
那是**启动就报错**，不是变方块。

1. **备份**：把 `<游戏目录>\mods` 整个复制一份到别处。
2. **先放字体**：把本包 `fonts\` 里的两个文件复制到 `<游戏目录>\mods\common\`：

   ```bat
   copy "fonts\NotoSansSC-Regular.ttf" "<游戏目录>\mods\common\"
   copy "fonts\NotoSansSC-Bold.ttf"    "<游戏目录>\mods\common\"
   ```

3. **再覆盖文本**：把本包 `files\mods\` 的内容按同名路径覆盖到 `<游戏目录>\mods\`
   （208 个文件，其中 12 个是新增：`common\fluent\ingame-debug.ftl` + 11 个 `d2k\maps\*\map.ftl`）。
4. 启动游戏。

自检一条就够：`<游戏目录>\mods\common\` 下有没有那两个 `NotoSansSC-*.ttf`。

**不要改 `mod.yaml`**——补丁里的 `mod.yaml` 已经指向正确的字体名，手改反而会改坏。
**更不要动 `map.yaml`**（理由见上一节）。

完整步骤（含还原、常见问题）见 **[安装说明.md](安装说明.md)**。

## 让 AI 助手帮你装

把 [安装说明.md](安装说明.md) 里「让 AI 助手帮你装」那段整段复制给能在你电脑上执行命令的助手。
那段提示词要求它：先校验 `mods\ra\mod.yaml` 的 `Version` 是否为 `playtest-20261026`、
先备份整个 `mods`、按结构覆盖 `files\mods`、复制两个字体、**不碰 `map.yaml` 与 `mod.yaml`**，
最后报告 208 个文件是否到位。`Program Files` 需要管理员权限，它可能会要你点一次 UAC。

## 中文字体：随包自带

OpenRA 默认字体 `common|FreeSans.ttf` **没有中文字形**，不换字体所有中文都是方块。
本补丁的 `mod.yaml` 指向两个随包字体：

| 文件 | 用途 |
|---|---|
| `fonts\NotoSansSC-Regular.ttf` | 正文（`Tiny` / `Small` / `Regular`） |
| `fonts\NotoSansSC-Bold.ttf` | 标题与强调（`*Bold` / `Title`） |

- 安装时复制到 `<游戏目录>\mods\common\`，**不依赖本机有没有中文字体**，英文版 Windows 也能显示中文。
- 字体是 **Noto Sans SC 全量字形**（SIL OFL 1.1，允许随包分发），用 `fonttools` 从上游可变字体
  固化成 Regular / Bold 两个静态实例，**没有删掉任何字**；许可全文见 `LICENSE-OFL.txt`。
- 想换字体：`setup.ps1 -FontPath "D:\你的字体.ttf"`，安装器会把两处引用都改成它。
- 包内 `fonts\` 缺失时（比如有人只拷了 `files\`）安装器才会回退到系统字体；系统也没有就**直接中止**，
  不会装出"启动就报错"的半成品。这是安装器的兜底逻辑，**手动安装只拷这两个自带字体，不碰系统字体**。

## 卸载与还原

所有被覆盖的文件都备份到 `<OpenRA 目录>\_zhcn-backup\<时间戳>\`，并附 `backup.json` 记录清单。

- 右键 `setup.ps1` →「使用 PowerShell 运行」→ 菜单输入 `2`：还原全部文件、删掉新增的两个字体，并顺手清掉补丁以前留下的字体。
- 有多份备份时，安装器自动挑**最早的那份「真正的安装前快照」**：已经还原过的（名字带 `.已还原`）
  和重复安装时生成的（里面存的其实是译文）都会被跳过，并在屏幕上说明跳过了哪一份。
- 想指定用哪一份：`setup.ps1 -Uninstall -Backup 20261030-180424`
  （值可以是备份目录名，也可以是完整路径）。
- 备份目录不会被自动删除（还原后改名成 `*.已还原`），方便反复折腾。
- 如果提示「没有可用的备份」，说明英文原件已经不在备份里了（多半是反复覆盖安装过）：
  按提示用同版本的 OpenRA 安装包重新覆盖 `mods\` 目录即可。

### 卸载后校验

还原之后想确认「到底卸干净没有」，`setup.ps1` → 菜单输入 `3`（等价于 `-Verify`）。
它按 `manifest.json` 里 208 个载荷的 SHA-256 逐文件比对安装目录：

**全部不一致 → 已彻底卸载（英文原版）；还有哈希一致的 → 列出来告诉你哪些没卸掉。**

字体残留（`mods\common\NotoSansSC-*.ttf`，以及 1.4.x 遗留的 `simhei.ttf`）也会提示。
退出码 0 = 干净，1 = 仍有残留。

## 覆盖范围

| 界面 | 状态 |
|---|---|
| 主菜单、设置（显示 / 音频 / 操作 / 快捷键 / 高级 / 游戏性） | 已汉化 |
| 单人、遭遇战、多人房间、服务器列表与提示 | 已汉化 |
| 游戏内指令（攻击移动 / 护卫 / 散开 / 强制移动 / 四种姿态） | 已汉化 |
| 观战统计、录像播放器、地图编辑器 | 已汉化 |
| 全部快捷键说明 | 已汉化 |
| 内容安装向导与「内容管理」（含 20 条安装源名称） | 已汉化 |
| 三个阵营的单位、建筑、防御、超级武器名称与说明 | 已汉化 |
| 战役任务目标与任务内对话（ra / cnc / d2k） | 已汉化 |
| **战役简报正文（每关开始前的长篇简报，140 份）** | 已汉化 |
| **战役分组名（「盟军战役 / GDI 战役 / 阿特雷德斯战役」等 16 个）** | 已汉化 |
| 遭遇战设置、地图生成器、阵营说明 | 已汉化 |
| 地图内硬编码文本（3 处倒计时、1 处任务提示） | 已汉化 |
| 地图元数据里的地图标题（任务列表显示的 `Allies 01` 等） | **未汉化，见上文说明** |

统计：**3,036 条 Fluent 文案 + 20 条安装源名称 + 140 份战役简报 + 16 个战役分组名 + 若干地图内文本**，
共 **208 个载荷文件**、595 KB；整包 218 个文件（字体解压后约 20 MB，zip 约 12.4 MB）。

## 引擎升级后请注意

Fluent **不会**在缺键时回退英文，而是把键名直接显示出来（界面上出现
`options-game-speed.normal` 这种字样）。因此：

- 本补丁只适配 `playtest-20261026`。引擎升级后请**先卸载本补丁**再更新，
  否则会看到上面那种「键名原样显示」。
- 等补丁发布对应新引擎的版本后再装；适配方式见
  仓库的 `CONTRIBUTING.md`（在 GitHub 上，不在本包内）。

## 已知问题

- **字号观感**：Noto Sans SC 的行高与 OpenRA 原字体不同，个别 UI 缩放档位下文字可能偏高或偏挤。
  要微调就改 `mods\<模组>\mod.yaml` 的 `Fonts:` 段（`Size` 加 1~2），或 `mods\common\metrics.yaml`。
- 只做了 Windows 脚本；Linux / macOS 用户可手动把 `files/` 覆盖到安装目录，再把 `fonts/` 里的
  两个 TTF 放进 `mods/common/`。
- `setup.ps1` 依赖 PowerShell。若目标机器被组策略禁用脚本，请走上面的「手动安装」。

## 附录 A：全部 208 个文件清单

<!-- INVENTORY:BEGIN 由 tools/build_readme_inventory.py 生成,勿手改 -->

共 **208 个文件**、595 KB，按内容分成 16 类。每一类一句话说清它是什么：

| 类别 | 数量 | 是什么 | 举例 |
|---|---|---|---|
| 界面文案 | 8 | 菜单、设置、按钮、提示等界面文字 | `cnc-content\fluent\chrome.ftl` |
| 通用文案 | 1 | 通用提示、错误信息、单位类别、协议名 | `common\fluent\common.ftl` |
| 战役界面 | 3 | 战役选择、任务列表、通关与失败提示 | `cnc\fluent\campaign.ftl` |
| 模组信息 | 3 | 模组名与描述、阵营介绍（启动器里显示） | `cnc\fluent\cnc.ftl` |
| 单位与建筑 | 4 | 单位与建筑名称、说明、技能与武器提示 | `cnc\fluent\rules.ftl` |
| 快捷键 | 4 | 快捷键说明（设置 → 快捷键页） | `cnc\fluent\hotkeys.ftl` |
| 作弊面板 | 1 | 作弊菜单（上游把 Debug 改名成了 Cheats） | `common\fluent\ingame-debug.ftl` |
| 剧情脚本 | 3 | 剧情脚本里上屏的对白与旁白 | `cnc\fluent\lua.ftl` |
| 战役简报 | 146 | 「cnc64gdi01」的简报正文与任务目标 | `cnc\maps\cnc64gdi01\map.ftl` |
| 战役分组名 | 3 | 任务列表左侧的分组标题（如「阿特雷德斯战役」） | `cnc\missions.yaml` |
| 地图硬编码 | 3 | 地图规则里写死的文字（倒计时、任务提示） | `ra\maps\allies-02\rules.yaml` |
| 地图脚本 | 1 | 地图脚本里上屏的一句文字 | `ra\maps\allies-13\allies13.lua` |
| 界面硬编码 | 2 | 写死在界面 yaml 里的文字（建服对话框等） | `cnc\chrome\multiplayer-createserver.yaml` |
| 安装源标题 | 19 | 内容安装向导里列出的下载源名称（Steam / 光盘版…） | `cnc-content\installer\covertops.yaml` |
| 安装器文案 | 1 | 内容安装向导的公共文字（下一步、取消、来源） | `common-content\fluent\content.ftl` |
| 模块声明 | 6 | **不是文案**：字体指向 + 声明加载哪些 .ftl | `cnc-content\mod.yaml` |

### `common\` — 三个游戏共用（6 个）

| 文件（相对 `files\mods\`） | 大小 | 作用 |
|---|---|---|
| `common\fluent\chrome.ftl` | 30.8 KB | 菜单、设置、按钮、提示等界面文字 |
| `common\fluent\common.ftl` | 34.7 KB | 通用提示、错误信息、单位类别、协议名 |
| `common\fluent\hotkeys.ftl` | 9.0 KB | 快捷键说明（设置 → 快捷键页） |
| `common\fluent\ingame-debug.ftl` | 1.7 KB | 作弊菜单（上游把 Debug 改名成了 Cheats） |
| `common\fluent\rules.ftl` | 1.7 KB | 单位与建筑名称、说明、技能与武器提示 |
| `common\chrome\multiplayer-createserver.yaml` | 4.5 KB | 写死在界面 yaml 里的文字（建服对话框等） |

### `ra\` — 红色警戒（78 个）

| 文件（相对 `files\mods\`） | 大小 | 作用 |
|---|---|---|
| `ra\fluent\campaign.ftl` | 1.8 KB | 战役选择、任务列表、通关与失败提示 |
| `ra\fluent\chrome.ftl` | 2.0 KB | 菜单、设置、按钮、提示等界面文字 |
| `ra\fluent\hotkeys.ftl` | 614 B | 快捷键说明（设置 → 快捷键页） |
| `ra\fluent\lua.ftl` | 20.1 KB | 剧情脚本里上屏的对白与旁白 |
| `ra\fluent\ra.ftl` | 769 B | 模组名与描述、阵营介绍（启动器里显示） |
| `ra\fluent\rules.ftl` | 29.5 KB | 单位与建筑名称、说明、技能与武器提示 |
| `ra\maps\allies-01\map.ftl` | 521 B | 「allies-01」的简报正文与任务目标 |
| `ra\maps\allies-02\map.ftl` | 656 B | 「allies-02」的简报正文与任务目标 |
| `ra\maps\allies-03a\map.ftl` | 543 B | 「allies-03a」的简报正文与任务目标 |
| `ra\maps\allies-03b\map.ftl` | 543 B | 「allies-03b」的简报正文与任务目标 |
| `ra\maps\allies-04\map.ftl` | 607 B | 「allies-04」的简报正文与任务目标 |
| `ra\maps\allies-05a\map.ftl` | 775 B | 「allies-05a」的简报正文与任务目标 |
| `ra\maps\allies-05b\map.ftl` | 596 B | 「allies-05b」的简报正文与任务目标 |
| `ra\maps\allies-05c\map.ftl` | 596 B | 「allies-05c」的简报正文与任务目标 |
| `ra\maps\allies-06a\map.ftl` | 450 B | 「allies-06a」的简报正文与任务目标 |
| `ra\maps\allies-06b\map.ftl` | 450 B | 「allies-06b」的简报正文与任务目标 |
| `ra\maps\allies-07\map.ftl` | 629 B | 「allies-07」的简报正文与任务目标 |
| `ra\maps\allies-08a\map.ftl` | 539 B | 「allies-08a」的简报正文与任务目标 |
| `ra\maps\allies-08b\map.ftl` | 539 B | 「allies-08b」的简报正文与任务目标 |
| `ra\maps\allies-09a\map.ftl` | 535 B | 「allies-09a」的简报正文与任务目标 |
| `ra\maps\allies-10a\map.ftl` | 452 B | 「allies-10a」的简报正文与任务目标 |
| `ra\maps\allies-10b\map.ftl` | 449 B | 「allies-10b」的简报正文与任务目标 |
| `ra\maps\allies-13\map.ftl` | 512 B | 「allies-13」的简报正文与任务目标 |
| `ra\maps\ant-01\map.ftl` | 638 B | 「ant-01」的简报正文与任务目标 |
| `ra\maps\ant-03\map.ftl` | 530 B | 「ant-03」的简报正文与任务目标 |
| `ra\maps\bomber-john\map.ftl` | 733 B | 「bomber-john」的简报正文与任务目标 |
| `ra\maps\drop-zone-battle-of-tikiaki\map.ftl` | 241 B | 「drop-zone-battle-of-tikiaki」的简报正文与任务目标 |
| `ra\maps\drop-zone-w\map.ftl` | 252 B | 「drop-zone-w」的简报正文与任务目标 |
| `ra\maps\drop-zone\map.ftl` | 241 B | 「drop-zone」的简报正文与任务目标 |
| `ra\maps\evacuation\map.ftl` | 614 B | 「evacuation」的简报正文与任务目标 |
| `ra\maps\exodus\map.ftl` | 452 B | 「exodus」的简报正文与任务目标 |
| `ra\maps\fall-of-greece-1-personal-war\map.ftl` | 548 B | 「fall-of-greece-1-personal-war」的简报正文与任务目标 |
| `ra\maps\fall-of-greece-2-evacuation\map.ftl` | 542 B | 「fall-of-greece-2-evacuation」的简报正文与任务目标 |
| `ra\maps\fort-lonestar\map.ftl` | 890 B | 「fort-lonestar」的简报正文与任务目标 |
| `ra\maps\in-the-nick-of-time\map.ftl` | 620 B | 「in-the-nick-of-time」的简报正文与任务目标 |
| `ra\maps\infiltration\map.ftl` | 467 B | 「infiltration」的简报正文与任务目标 |
| `ra\maps\intervention\map.ftl` | 578 B | 「intervention」的简报正文与任务目标 |
| `ra\maps\monster-tank-madness\map.ftl` | 710 B | 「monster-tank-madness」的简报正文与任务目标 |
| `ra\maps\mousetrap\map.ftl` | 689 B | 「mousetrap」的简报正文与任务目标 |
| `ra\maps\negotiations\map.ftl` | 611 B | 「negotiations」的简报正文与任务目标 |
| `ra\maps\oil-spill\map.ftl` | 258 B | 「oil-spill」的简报正文与任务目标 |
| `ra\maps\production-disruption\map.ftl` | 557 B | 「production-disruption」的简报正文与任务目标 |
| `ra\maps\proving-grounds\map.ftl` | 698 B | 「proving-grounds」的简报正文与任务目标 |
| `ra\maps\sarin-gas-1-crackdown\map.ftl` | 626 B | 「sarin-gas-1-crackdown」的简报正文与任务目标 |
| `ra\maps\sarin-gas-2-down-under\map.ftl` | 635 B | 「sarin-gas-2-down-under」的简报正文与任务目标 |
| `ra\maps\sarin-gas-3-controlled-burn\map.ftl` | 575 B | 「sarin-gas-3-controlled-burn」的简报正文与任务目标 |
| `ra\maps\shock-therapy\map.ftl` | 665 B | 「shock-therapy」的简报正文与任务目标 |
| `ra\maps\siberian-conflict-1-fresh-tracks\map.ftl` | 536 B | 「siberian-conflict-1-fresh-tracks」的简报正文与任务目标 |
| `ra\maps\siberian-conflict-3-wasteland\map.ftl` | 470 B | 「siberian-conflict-3-wasteland」的简报正文与任务目标 |
| `ra\maps\situation-critical\map.ftl` | 674 B | 「situation-critical」的简报正文与任务目标 |
| `ra\maps\soviet-01\map.ftl` | 440 B | 「soviet-01」的简报正文与任务目标 |
| `ra\maps\soviet-02a\map.ftl` | 410 B | 「soviet-02a」的简报正文与任务目标 |
| `ra\maps\soviet-02b\map.ftl` | 410 B | 「soviet-02b」的简报正文与任务目标 |
| `ra\maps\soviet-03\map.ftl` | 407 B | 「soviet-03」的简报正文与任务目标 |
| `ra\maps\soviet-04a\map.ftl` | 467 B | 「soviet-04a」的简报正文与任务目标 |
| `ra\maps\soviet-04b\map.ftl` | 467 B | 「soviet-04b」的简报正文与任务目标 |
| `ra\maps\soviet-05\map.ftl` | 470 B | 「soviet-05」的简报正文与任务目标 |
| `ra\maps\soviet-06a\map.ftl` | 509 B | 「soviet-06a」的简报正文与任务目标 |
| `ra\maps\soviet-06b\map.ftl` | 509 B | 「soviet-06b」的简报正文与任务目标 |
| `ra\maps\soviet-07\map.ftl` | 554 B | 「soviet-07」的简报正文与任务目标 |
| `ra\maps\soviet-08a\map.ftl` | 521 B | 「soviet-08a」的简报正文与任务目标 |
| `ra\maps\soviet-08b\map.ftl` | 521 B | 「soviet-08b」的简报正文与任务目标 |
| `ra\maps\soviet-09\map.ftl` | 461 B | 「soviet-09」的简报正文与任务目标 |
| `ra\maps\soviet-10\map.ftl` | 494 B | 「soviet-10」的简报正文与任务目标 |
| `ra\maps\soviet-11a\map.ftl` | 383 B | 「soviet-11a」的简报正文与任务目标 |
| `ra\maps\soviet-11b\map.ftl` | 383 B | 「soviet-11b」的简报正文与任务目标 |
| `ra\maps\soviet-13a\map.ftl` | 356 B | 「soviet-13a」的简报正文与任务目标 |
| `ra\maps\soviet-13b\map.ftl` | 356 B | 「soviet-13b」的简报正文与任务目标 |
| `ra\maps\soviet-soldier-volkov-n-chitzkoi\map.ftl` | 659 B | 「soviet-soldier-volkov-n-chitzkoi」的简报正文与任务目标 |
| `ra\maps\survival01\map.ftl` | 450 B | 「survival01」的简报正文与任务目标 |
| `ra\maps\survival02\map.ftl` | 394 B | 「survival02」的简报正文与任务目标 |
| `ra\maps\top-o-the-world\map.ftl` | 848 B | 「top-o-the-world」的简报正文与任务目标 |
| `ra\missions.yaml` | 1.0 KB | 任务列表左侧的分组标题（如「阿特雷德斯战役」） |
| `ra\mod.yaml` | 7.2 KB | **不是文案**：字体指向 + 声明加载哪些 .ftl |
| `ra\maps\allies-02\rules.yaml` | 1.6 KB | 地图规则里写死的文字（倒计时、任务提示） |
| `ra\maps\allies-10a\rules.yaml` | 1.5 KB | 地图规则里写死的文字（倒计时、任务提示） |
| `ra\maps\allies-13\allies13.lua` | 11.8 KB | 地图脚本里上屏的一句文字 |
| `ra\maps\allies-13\rules.yaml` | 894 B | 地图规则里写死的文字（倒计时、任务提示） |

### `cnc\` — 泰伯利亚黎明（47 个）

| 文件（相对 `files\mods\`） | 大小 | 作用 |
|---|---|---|
| `cnc\fluent\campaign.ftl` | 781 B | 战役选择、任务列表、通关与失败提示 |
| `cnc\fluent\chrome.ftl` | 31.9 KB | 菜单、设置、按钮、提示等界面文字 |
| `cnc\fluent\cnc.ftl` | 443 B | 模组名与描述、阵营介绍（启动器里显示） |
| `cnc\fluent\hotkeys.ftl` | 597 B | 快捷键说明（设置 → 快捷键页） |
| `cnc\fluent\lua.ftl` | 5.4 KB | 剧情脚本里上屏的对白与旁白 |
| `cnc\fluent\rules.ftl` | 32.0 KB | 单位与建筑名称、说明、技能与武器提示 |
| `cnc\chrome\multiplayer-createserver.yaml` | 4.8 KB | 写死在界面 yaml 里的文字（建服对话框等） |
| `cnc\maps\cnc64gdi01\map.ftl` | 474 B | 「cnc64gdi01」的简报正文与任务目标 |
| `cnc\maps\eviction-notice\map.ftl` | 450 B | 「eviction-notice」的简报正文与任务目标 |
| `cnc\maps\funpark01\map.ftl` | 338 B | 「funpark01」的简报正文与任务目标 |
| `cnc\maps\gdi01\map.ftl` | 500 B | 「gdi01」的简报正文与任务目标 |
| `cnc\maps\gdi02\map.ftl` | 432 B | 「gdi02」的简报正文与任务目标 |
| `cnc\maps\gdi03\map.ftl` | 423 B | 「gdi03」的简报正文与任务目标 |
| `cnc\maps\gdi04a\map.ftl` | 433 B | 「gdi04a」的简报正文与任务目标 |
| `cnc\maps\gdi04b\map.ftl` | 433 B | 「gdi04b」的简报正文与任务目标 |
| `cnc\maps\gdi04c\map.ftl` | 417 B | 「gdi04c」的简报正文与任务目标 |
| `cnc\maps\gdi05a\map.ftl` | 467 B | 「gdi05a」的简报正文与任务目标 |
| `cnc\maps\gdi05b\map.ftl` | 467 B | 「gdi05b」的简报正文与任务目标 |
| `cnc\maps\gdi05c\map.ftl` | 467 B | 「gdi05c」的简报正文与任务目标 |
| `cnc\maps\gdi06\map.ftl` | 356 B | 「gdi06」的简报正文与任务目标 |
| `cnc\maps\gdi07\map.ftl` | 387 B | 「gdi07」的简报正文与任务目标 |
| `cnc\maps\gdi08a\map.ftl` | 459 B | 「gdi08a」的简报正文与任务目标 |
| `cnc\maps\gdi08b\map.ftl` | 400 B | 「gdi08b」的简报正文与任务目标 |
| `cnc\maps\gdi09\map.ftl` | 445 B | 「gdi09」的简报正文与任务目标 |
| `cnc\maps\nod01\map.ftl` | 437 B | 「nod01」的简报正文与任务目标 |
| `cnc\maps\nod02a\map.ftl` | 453 B | 「nod02a」的简报正文与任务目标 |
| `cnc\maps\nod02b\map.ftl` | 453 B | 「nod02b」的简报正文与任务目标 |
| `cnc\maps\nod03a\map.ftl` | 395 B | 「nod03a」的简报正文与任务目标 |
| `cnc\maps\nod03b\map.ftl` | 395 B | 「nod03b」的简报正文与任务目标 |
| `cnc\maps\nod04a\map.ftl` | 396 B | 「nod04a」的简报正文与任务目标 |
| `cnc\maps\nod04b\map.ftl` | 399 B | 「nod04b」的简报正文与任务目标 |
| `cnc\maps\nod05\map.ftl` | 422 B | 「nod05」的简报正文与任务目标 |
| `cnc\maps\nod06a\map.ftl` | 605 B | 「nod06a」的简报正文与任务目标 |
| `cnc\maps\nod06b\map.ftl` | 605 B | 「nod06b」的简报正文与任务目标 |
| `cnc\maps\nod06c\map.ftl` | 426 B | 「nod06c」的简报正文与任务目标 |
| `cnc\maps\nod07a\map.ftl` | 484 B | 「nod07a」的简报正文与任务目标 |
| `cnc\maps\nod07b\map.ftl` | 484 B | 「nod07b」的简报正文与任务目标 |
| `cnc\maps\nod07c\map.ftl` | 513 B | 「nod07c」的简报正文与任务目标 |
| `cnc\maps\nod08a\map.ftl` | 467 B | 「nod08a」的简报正文与任务目标 |
| `cnc\maps\nod08b\map.ftl` | 467 B | 「nod08b」的简报正文与任务目标 |
| `cnc\maps\nod09\map.ftl` | 383 B | 「nod09」的简报正文与任务目标 |
| `cnc\maps\nod10a\map.ftl` | 399 B | 「nod10a」的简报正文与任务目标 |
| `cnc\maps\nod10b\map.ftl` | 416 B | 「nod10b」的简报正文与任务目标 |
| `cnc\maps\the-tiberium-strain\map.ftl` | 499 B | 「the-tiberium-strain」的简报正文与任务目标 |
| `cnc\maps\twist-of-fate\map.ftl` | 519 B | 「twist-of-fate」的简报正文与任务目标 |
| `cnc\missions.yaml` | 404 B | 任务列表左侧的分组标题（如「阿特雷德斯战役」） |
| `cnc\mod.yaml` | 6.2 KB | **不是文案**：字体指向 + 声明加载哪些 .ftl |

### `d2k\` — 沙丘 2000（50 个）

| 文件（相对 `files\mods\`） | 大小 | 作用 |
|---|---|---|
| `d2k\fluent\campaign.ftl` | 541 B | 战役选择、任务列表、通关与失败提示 |
| `d2k\fluent\chrome.ftl` | 2.3 KB | 菜单、设置、按钮、提示等界面文字 |
| `d2k\fluent\d2k.ftl` | 538 B | 模组名与描述、阵营介绍（启动器里显示） |
| `d2k\fluent\hotkeys.ftl` | 631 B | 快捷键说明（设置 → 快捷键页） |
| `d2k\fluent\lua.ftl` | 7.9 KB | 剧情脚本里上屏的对白与旁白 |
| `d2k\fluent\rules.ftl` | 29.6 KB | 单位与建筑名称、说明、技能与武器提示 |
| `d2k\maps\atreides-01a\map.ftl` | 695 B | 「atreides-01a」的简报正文与任务目标 |
| `d2k\maps\atreides-01b\map.ftl` | 695 B | 「atreides-01b」的简报正文与任务目标 |
| `d2k\maps\atreides-02a\map.ftl` | 605 B | 「atreides-02a」的简报正文与任务目标 |
| `d2k\maps\atreides-02b\map.ftl` | 605 B | 「atreides-02b」的简报正文与任务目标 |
| `d2k\maps\atreides-03a\map.ftl` | 590 B | 「atreides-03a」的简报正文与任务目标 |
| `d2k\maps\atreides-03b\map.ftl` | 590 B | 「atreides-03b」的简报正文与任务目标 |
| `d2k\maps\atreides-04\map.ftl` | 509 B | 「atreides-04」的简报正文与任务目标 |
| `d2k\maps\atreides-05\map.ftl` | 791 B | 「atreides-05」的简报正文与任务目标 |
| `d2k\maps\atreides-06a\map.ftl` | 530 B | 「atreides-06a」的简报正文与任务目标 |
| `d2k\maps\atreides-06b\map.ftl` | 530 B | 「atreides-06b」的简报正文与任务目标 |
| `d2k\maps\atreides-07\map.ftl` | 534 B | 「atreides-07」的简报正文与任务目标 |
| `d2k\maps\atreides-08\map.ftl` | 603 B | 「atreides-08」的简报正文与任务目标 |
| `d2k\maps\atreides-09a\map.ftl` | 570 B | 「atreides-09a」的简报正文与任务目标 |
| `d2k\maps\atreides-09b\map.ftl` | 570 B | 「atreides-09b」的简报正文与任务目标 |
| `d2k\maps\harkonnen-01a\map.ftl` | 503 B | 「harkonnen-01a」的简报正文与任务目标 |
| `d2k\maps\harkonnen-01b\map.ftl` | 512 B | 「harkonnen-01b」的简报正文与任务目标 |
| `d2k\maps\harkonnen-02a\map.ftl` | 425 B | 「harkonnen-02a」的简报正文与任务目标 |
| `d2k\maps\harkonnen-02b\map.ftl` | 425 B | 「harkonnen-02b」的简报正文与任务目标 |
| `d2k\maps\harkonnen-03a\map.ftl` | 419 B | 「harkonnen-03a」的简报正文与任务目标 |
| `d2k\maps\harkonnen-03b\map.ftl` | 419 B | 「harkonnen-03b」的简报正文与任务目标 |
| `d2k\maps\harkonnen-04\map.ftl` | 515 B | 「harkonnen-04」的简报正文与任务目标 |
| `d2k\maps\harkonnen-05\map.ftl` | 389 B | 「harkonnen-05」的简报正文与任务目标 |
| `d2k\maps\harkonnen-06a\map.ftl` | 554 B | 「harkonnen-06a」的简报正文与任务目标 |
| `d2k\maps\harkonnen-06b\map.ftl` | 554 B | 「harkonnen-06b」的简报正文与任务目标 |
| `d2k\maps\harkonnen-07\map.ftl` | 689 B | 「harkonnen-07」的简报正文与任务目标 |
| `d2k\maps\harkonnen-08\map.ftl` | 995 B | 「harkonnen-08」的简报正文与任务目标 |
| `d2k\maps\harkonnen-09a\map.ftl` | 536 B | 「harkonnen-09a」的简报正文与任务目标 |
| `d2k\maps\harkonnen-09b\map.ftl` | 536 B | 「harkonnen-09b」的简报正文与任务目标 |
| `d2k\maps\ordos-01a\map.ftl` | 536 B | 「ordos-01a」的简报正文与任务目标 |
| `d2k\maps\ordos-01b\map.ftl` | 536 B | 「ordos-01b」的简报正文与任务目标 |
| `d2k\maps\ordos-02a\map.ftl` | 347 B | 「ordos-02a」的简报正文与任务目标 |
| `d2k\maps\ordos-02b\map.ftl` | 347 B | 「ordos-02b」的简报正文与任务目标 |
| `d2k\maps\ordos-03a\map.ftl` | 458 B | 「ordos-03a」的简报正文与任务目标 |
| `d2k\maps\ordos-03b\map.ftl` | 410 B | 「ordos-03b」的简报正文与任务目标 |
| `d2k\maps\ordos-04\map.ftl` | 593 B | 「ordos-04」的简报正文与任务目标 |
| `d2k\maps\ordos-05\map.ftl` | 590 B | 「ordos-05」的简报正文与任务目标 |
| `d2k\maps\ordos-06a\map.ftl` | 467 B | 「ordos-06a」的简报正文与任务目标 |
| `d2k\maps\ordos-06b\map.ftl` | 455 B | 「ordos-06b」的简报正文与任务目标 |
| `d2k\maps\ordos-07\map.ftl` | 556 B | 「ordos-07」的简报正文与任务目标 |
| `d2k\maps\ordos-08\map.ftl` | 660 B | 「ordos-08」的简报正文与任务目标 |
| `d2k\maps\ordos-09a\map.ftl` | 395 B | 「ordos-09a」的简报正文与任务目标 |
| `d2k\maps\ordos-09b\map.ftl` | 395 B | 「ordos-09b」的简报正文与任务目标 |
| `d2k\missions.yaml` | 607 B | 任务列表左侧的分组标题（如「阿特雷德斯战役」） |
| `d2k\mod.yaml` | 6.2 KB | **不是文案**：字体指向 + 声明加载哪些 .ftl |

### `ra-content\` — 红警内容安装器（11 个）

| 文件（相对 `files\mods\`） | 大小 | 作用 |
|---|---|---|
| `ra-content\fluent\chrome.ftl` | 1.1 KB | 菜单、设置、按钮、提示等界面文字 |
| `ra-content\installer\aftermath.yaml` | 3.1 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `ra-content\installer\allies95.yaml` | 4.6 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `ra-content\installer\cnc95.yaml` | 295 B | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `ra-content\installer\counterstrike.yaml` | 1.0 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `ra-content\installer\downloads.yaml` | 5.4 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `ra-content\installer\firstdecade.yaml` | 10.8 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `ra-content\installer\origin.yaml` | 20.5 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `ra-content\installer\soviet95.yaml` | 4.9 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `ra-content\installer\steam.yaml` | 20.8 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `ra-content\mod.yaml` | 10.5 KB | **不是文案**：字体指向 + 声明加载哪些 .ftl |

### `cnc-content\` — 泰伯利亚黎明内容安装器（9 个）

| 文件（相对 `files\mods\`） | 大小 | 作用 |
|---|---|---|
| `cnc-content\fluent\chrome.ftl` | 976 B | 菜单、设置、按钮、提示等界面文字 |
| `cnc-content\installer\covertops.yaml` | 376 B | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `cnc-content\installer\downloads.yaml` | 625 B | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `cnc-content\installer\firstdecade.yaml` | 9.1 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `cnc-content\installer\gdi95.yaml` | 4.8 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `cnc-content\installer\nod95.yaml` | 4.6 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `cnc-content\installer\origin.yaml` | 17.8 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `cnc-content\installer\steam.yaml` | 17.4 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `cnc-content\mod.yaml` | 8.1 KB | **不是文案**：字体指向 + 声明加载哪些 .ftl |

### `d2k-content\` — 沙丘 2000 内容安装器（5 个）

| 文件（相对 `files\mods\`） | 大小 | 作用 |
|---|---|---|
| `d2k-content\fluent\chrome.ftl` | 794 B | 菜单、设置、按钮、提示等界面文字 |
| `d2k-content\installer\d2k.yaml` | 21.0 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `d2k-content\installer\downloads.yaml` | 38.2 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `d2k-content\installer\gruntmods.yaml` | 18.6 KB | 内容安装向导里列出的下载源名称（Steam / 光盘版…） |
| `d2k-content\mod.yaml` | 2.5 KB | **不是文案**：字体指向 + 声明加载哪些 .ftl |

### `common-content\` — 内容安装器公共部分（2 个）

| 文件（相对 `files\mods\`） | 大小 | 作用 |
|---|---|---|
| `common-content\fluent\chrome.ftl` | 2.4 KB | 菜单、设置、按钮、提示等界面文字 |
| `common-content\fluent\content.ftl` | 242 B | 内容安装向导的公共文字（下一步、取消、来源） |

> 这份清单由 `tools/build_readme_inventory.py` 从 `manifest.json` 生成,改载荷后重跑一次即可；CI 会校验两者一致。

<!-- INVENTORY:END -->

## 致谢

| 对象 | 说明 |
|---|---|
| [OpenRA](https://www.openra.net/) 项目 | 游戏引擎与全部原始英文文案。本补丁只做翻译，不改游戏逻辑 |
| OpenRA 汉化组（Gitee [CastleJing](https://gitee.com/CastleJing)） | 红警 [RASC](https://gitee.com/CastleJing/OpenRA_rasc) 与泰伯利亚黎明 [TDSC](https://gitee.com/CastleJing/OpenRA_tdsc)。本补丁的单位与建筑名称对齐了他们的译法共识（`移动建造车` → `移动基地车`、`长弓` → `长弓武装直升机`） |
| [Noto Sans SC](https://github.com/notofonts/noto-cjk) | 随包中文字体，Google / Adobe 出品，SIL OFL 1.1 |
| 所有贡献者 | 提交译文修正、报告方块字与漏翻问题的人，见仓库的 CHANGELOG |

## 反馈与许可

- 发现译文问题、方块字、漏翻，或想帮忙翻译 → 到仓库提 issue / PR：
  <https://github.com/Janlhin/OpenRA_simplified_chinese>。
- 许可证：本补丁以 **GPL-3.0-or-later** 发布（全文见包内 `LICENSE`），译文派生自 OpenRA 项目。
- 随包字体 Noto Sans SC 以 **SIL OFL 1.1** 分发（全文见包内 `LICENSE-OFL.txt`）。
