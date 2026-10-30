# OpenRA 简体中文汉化补丁

[![validate](https://github.com/Janlhin/OpenRA_simplified_chinese/actions/workflows/validate.yml/badge.svg)](https://github.com/Janlhin/OpenRA_simplified_chinese/actions/workflows/validate.yml)

给 **[OpenRA](https://www.openra.net/)**（`playtest-20261026`）加上简体中文的轻量补丁。

- 覆盖 **红色警戒 (ra)**、**泰伯利亚黎明 (cnc)**、**沙丘 2000 (d2k)** 三个模组的界面、单位与建筑名称、
  任务目标，以及全部战役简报。
- 只包含**文本文件**：不打包游戏本体、不含美术或音频素材、**不分发字体**。
- 安装前逐文件校验 SHA-256，覆盖前自动备份，可一键完全还原。
- 只在本地运行，安装过程不联网。

> 非官方社区作品，与 OpenRA 项目无隶属关系。许可证 [GPL-3.0-or-later](LICENSE)。

---

## 快速开始

**系统要求**：Windows 10 / 11，用系统自带的 PowerShell 5.1（无需额外安装任何东西）。

1. 把 Release 中下载的 zip 解压到一个**英文路径**下，例如 `D:\OpenRA_CN`。
2. **关闭 OpenRA**。
3. 双击 **`setup.cmd`**，在菜单里输入 `1` 回车。
   - 自动探测 OpenRA 安装目录（注册表 + `Program Files\OpenRA*`）。找不到时会提示你用 `-Target` 指定。
   - 目标在 `C:\Program Files` 等受保护位置时，会自动弹出 UAC 提权窗口继续。
   - 若你的引擎版本不是 `playtest-20261026`，会先警告，再询问是否继续。
4. 启动游戏（例如 `C:\Program Files\OpenRA (playtest)\RedAlert.exe`），界面即为中文。

`setup.cmd` 是**唯一入口**：安装、还原、卸载校验、预演都在同一个菜单里，
不用记参数，也不用找第二个脚本。

### 命令行安装（等价用法）

```bat
setup.cmd -Target "C:\Program Files\OpenRA (playtest)"
setup.cmd -DryRun                 :: 只预览，不写任何文件
setup.cmd -Uninstall              :: 还原
setup.cmd -Verify                 :: 校验是否已卸干净
setup.cmd -FontPath "D:\NotoSansSC-Regular.ttf"   :: 指定中文字体
```

### 安装参数

`setup.cmd` 会把参数原样透传给 `bin\install.ps1`，两者等价：

| 参数 | 说明 |
|---|---|
| `-Target <dir>` | OpenRA 安装目录，省略则自动探测 |
| `-FontPath <file>` | 指定中文字体（`.ttf` / `.ttc`），省略则依次查找本机 `simhei.ttf` → `Deng.ttf` → `msyh.ttc` → `simsun.ttc` |
| `-SkipFont` | 不部署字体（引擎已配置中文字体时使用） |
| `-DryRun` | 预演，不写任何文件 |
| `-Force` | 引擎版本不匹配时不再询问，直接继续 |
| `-Yes` | 全程不交互 |
| `-NoVerify` | 跳过载荷 SHA-256 校验 |
| `-Uninstall` | 从最近一次备份还原 |
| `-Verify` | 校验「汉化是否已卸载干净」 |

## 手动安装（不运行脚本）

适用：不想跑脚本，或公司电脑用组策略禁掉了 PowerShell。

**顺序不能错**：补丁里的 `mod.yaml` 已经指向 `common|SimHei.ttf`，所以「先覆盖文本、后放字体」
会让引擎找不到字体文件——那是**启动就报错**，不是变方块。

1. **备份**：把 `<游戏目录>\mods` 整个复制一份到别处。
2. **先放字体**：`C:\Windows\Fonts\simhei.ttf` → `<游戏目录>\mods\common\simhei.ttf`。
   本机没有 `simhei.ttf` 就复制任意中文字体并**保持原文件名**，再把 6 个 `mod.yaml` 里的
   `common|SimHei.ttf` 改成那个名字。
3. **再覆盖文本**：把本包 `files\mods\` 的内容按同名路径覆盖到 `<游戏目录>\mods\`
   （208 个文件，其中 12 个是新增：`common\fluent\ingame-debug.ftl` + 11 个 `d2k\maps\*\map.ftl`）。
4. 启动游戏。

自检两条：`<游戏目录>\mods\common\simhei.ttf` 与
`<游戏目录>\mods\common\fluent\ingame-debug.ftl` 都存在。

完整步骤（含还原、常见问题）见 **[安装说明.md](安装说明.md)**。

## 让 AI 助手帮你装

把 [安装说明.md](安装说明.md) 里「让 AI 助手帮你装」那段整段复制给能在你电脑上执行命令的助手。
那段提示词要求它：先校验 `mods\ra\mod.yaml` 的 `Version` 是否为 `playtest-20261026`、先备份整个
`mods`、按结构覆盖 `files\mods`、复制字体、**不碰 `map.yaml` 与 `mod.yaml`**，最后报告 208 个
文件是否到位。`Program Files` 需要管理员权限，它可能会要你点一次 UAC。

## 覆盖范围

补丁针对三个可玩的游戏模组：**红色警戒 (ra)**、**泰伯利亚黎明 (cnc)**、**沙丘 2000 (d2k)**。

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
| 内容安装器的悬停提示、建服对话框的默认服务器名 | 已汉化 |
| 地图内硬编码文本（3 处倒计时、1 处任务提示） | 已汉化 |
| 地图元数据里的地图标题（任务列表条目显示的 `Allies 01` 等） | **未汉化，见下方说明** |

统计：**3,036 条 Fluent 文案 + 20 条安装源名称 + 140 份战役简报 + 16 个战役分组名 + 若干地图内文本**，
共 **208 个载荷文件**、约 595 KB。

### 为什么任务列表里的关卡名还是英文

任务列表里的每个条目显示的是**地图元数据**（`mods/<mod>/maps/<地图>/map.yaml` 的 `Title`），
共 162 处，例如 `Allies 01`、`GDI 06`、`Harkonnen 09a`。这些字段**故意不翻译**：

> 地图 UID = `SHA1(map.yaml + *.bin + *.lua + map.png)`。改动 `map.yaml` 会让打了补丁的玩家与
> 未打补丁的玩家**地图哈希不一致**（无法同局游戏），旧录像也会因为找不到对应地图而无法播放。
> 好消息是 `.ftl` 不参与 UID 计算，所以本补丁的译文不会影响联机兼容性。

## 中文字体：随包自带

OpenRA 的 `Fonts:` 配置默认指向 `common|FreeSans.ttf`，该字体**没有中文字形**，
不换字体的话所有中文都会变成方块。本补丁把 `mod.yaml` 指向两个随包字体：

| 文件 | 用途 |
|---|---|
| `fonts\NotoSansSC-Regular.ttf` | 正文（`Tiny` / `Small` / `Regular`） |
| `fonts\NotoSansSC-Bold.ttf` | 标题与强调（`*Bold` / `Title`） |

- 安装时把这两个文件复制到 `<游戏目录>\mods\common\`，**不依赖本机有没有中文字体**，
  英文版 / 精简版 Windows 也能直接显示中文。
- 字体是 **Noto Sans SC 全量字形**（SIL OFL 1.1，可随包分发），用 `fonttools` 从可变字体
  固化成 Regular / Bold 两个静态实例；许可全文见 `LICENSE-OFL.txt`。
- 想换成别的字体：`setup.cmd -FontPath "D:\你的字体.ttf"`，安装器会把两个引用都改成它。
- 包内 `fonts\` 缺失时（比如有人只拷了 `files\`），安装器会回退到系统字体；
  系统也没有中文字体时**直接中止**，不会装出一个启动就报错的半成品。

## 卸载与还原

所有被覆盖的文件都备份到 `<OpenRA 目录>\_zhcn-backup\<时间戳>\`，并附 `backup.json` 记录清单。

- 双击 `setup.cmd` → 菜单输入 `2`：还原全部文件、删除新增的字体文件。
- 也可以手动把备份目录里的文件复制回去。
- 备份目录不会被自动删除（还原后改名为 `*.已还原`），方便反复折腾。

### 卸载后校验

还原之后想确认「到底卸干净没有」，双击 `setup.cmd` → 菜单输入 `3`（等价于 `setup.cmd -Verify`）。
它会按 `manifest.json` 里 208 个载荷的 SHA-256 逐文件比对安装目录：

**全部不一致 → 已彻底卸载（英文原版）；仍有哈希一致的 → 列出来告诉你哪些没卸掉。**

字体残留（`mods/common/SimHei.ttf`）也会一并提示。退出码 0 表示干净、1 表示仍有残留。

## 包里有什么

发布包解压后只有 8 项，各管一件事：

| 路径 | 作用 | 谁读它 | 能删吗 |
|---|---|---|---|
| `setup.cmd` | **唯一入口**。双击出中文菜单（安装 / 还原 / 校验 / 预演）；带参数时原样透传 | 玩家 | 删了就只能手动安装 |
| `bin\install.ps1` | 全部逻辑：探测游戏目录、版本校验、SHA-256 校验、备份、UAC 提权、还原、字体部署 | `setup.cmd` 调用 | **不能删** |
| `bin\manifest.json` | 补丁的身份证：版本、适配引擎、208 个载荷的 `{path, size, sha256}`、字体清单 | `install.ps1`、CI | **不能删**（安装器靠它校验与判版本） |
| `files\mods\` | 208 个文本载荷，路径与游戏 `mods\` 一一对应（覆盖树） | `install.ps1` | **不能删** |
| `fonts\` | 随包中文字体：`NotoSansSC-Regular.ttf` / `-Bold.ttf`（各约 10 MB） | `install.ps1` | **不能删**（删了会回退系统字体，没有就装不了） |
| `README.md` | 本文件：文件作用、快速开始、手动安装、常见问题 | 玩家 | 可以，但建议留着 |
| `安装说明.txt` / `安装说明.md` | 同一份安装说明的两个版本（记事本 / Markdown） | 玩家 | 可以 |
| `LICENSE` / `LICENSE-OFL.txt` | 补丁的 GPL-3.0 与字体的 SIL OFL 1.1 | 法律 | **不能删**（合规） |

`bin\` 里是两个互相依赖的文件，别单独挪动：`setup.cmd` 按相对路径找它们。

研发资产（`tools/`、`docs/`、`.github/`、`CONTRIBUTING.md`、`CHANGELOG.md` 等）
只留在仓库里，**不进发布包**。

## 引擎升级后请注意

Fluent **不会**在缺失键时回退英文，而是把键名直接显示出来（例如界面上出现
`options-game-speed.normal` 这样的字样）。因此：

- 本补丁只适配 `playtest-20261026`。升级到更新的引擎后请**先卸载本补丁**，
  否则可能看到上面那种「键名原样显示」。
- 待补丁发布对应新引擎的版本后再安装；适配方式见
  [CONTRIBUTING.md](CONTRIBUTING.md#较大的改动适配新的引擎版本)。

## 已知问题

- 中文字号偏小：可编辑 `mods/<模组>/mod.yaml` 的 `Fonts:` 段把 `Size` 调大 1~2。
- 粗体被替换为同一字体（SimHei 无独立粗体），视觉上少了加粗层次。
- 只做了 Windows 脚本；Linux / macOS 用户可手动把 `files/` 覆盖到安装目录并配置 TTF 字体。

## 致谢

| 对象 | 说明 |
|---|---|
| [OpenRA](https://www.openra.net/) 项目 | 游戏引擎与全部原始英文文案。本补丁只做翻译，不改动游戏逻辑 |
| OpenRA 汉化组（Gitee [CastleJing](https://gitee.com/CastleJing)） | 红警 [RASC](https://gitee.com/CastleJing/OpenRA_rasc) 与泰伯利亚黎明 [TDSC](https://gitee.com/CastleJing/OpenRA_tdsc)。本补丁的单位与建筑名称，对齐了他们的译法共识（如 `移动建造车` → `移动基地车`、`长弓` → `长弓武装直升机`） |
| 字体作者 | 本补丁**不分发字体**，安装时复用**你本机**的中文字体（黑体 / 微软雅黑 / 等线 / 宋体，或你指定的[思源黑体](https://github.com/notofonts/noto-cjk) 等）。字体版权归各自作者 |
| 所有贡献者 | 提交译文修正、报告方块字与漏翻问题的人，见 [CHANGELOG.md](CHANGELOG.md) |

## 参与与许可

- 想帮忙翻译、或发现译文有问题 → 见 [CONTRIBUTING.md](CONTRIBUTING.md)。
- 想知道仓库里每个文件干什么用、载荷是怎么构建的、怎么发布 → 见
  [docs/ANATOMY.md](docs/ANATOMY.md) 与 [docs/MAINTAINING.md](docs/MAINTAINING.md)。
- 许可证：GPL-3.0-or-later，全文见 [LICENSE](LICENSE)。
