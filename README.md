# OpenRA 简体中文汉化补丁

[![validate](https://github.com/Janlhin/OpenRA_simplified_chinese/actions/workflows/validate.yml/badge.svg)](https://github.com/Janlhin/OpenRA_simplified_chinese/actions/workflows/validate.yml)

给 **[OpenRA](https://www.openra.net/)**（`playtest-20260222`）加上简体中文的轻量补丁。

- 覆盖 **红色警戒 (ra)**、**泰伯利亚黎明 (cnc)**、**沙丘 2000 (d2k)** 三个模组的界面、单位与建筑名称、
  任务目标，以及全部战役简报。
- 只包含**文本文件**：不打包游戏本体、不含美术或音频素材、**不分发字体**。
- 安装前逐文件校验 SHA-256，覆盖前自动备份，可一键完全还原。
- 只在本地运行，安装过程不联网。

> 非官方社区作品，与 OpenRA 项目无隶属关系。许可证 [GPL-3.0-or-later](LICENSE)。

---

## 快速开始

**系统要求**：Windows + 系统自带的 Windows PowerShell 5.1（无需额外安装任何东西）。

1. 把 Release 中下载的 zip 解压到一个**英文路径**下，例如 `D:\OpenRA_simplified_chinese`。
2. **关闭 OpenRA**。
3. 双击 **`install.bat`**。
   - 自动探测 OpenRA 安装目录（注册表 + `Program Files\OpenRA*`）。找不到时会提示你用 `-Target` 指定。
   - 目标在 `C:\Program Files` 等受保护位置时，会自动弹出 UAC 提权窗口继续。
   - 若你的引擎版本不是 `playtest-20260222`，会先警告，再询问是否继续。
4. 启动游戏（例如 `C:\Program Files\OpenRA (playtest)\RedAlert.exe`），界面即为中文。

### 命令行安装

```bat
install.bat -Target "C:\Program Files\OpenRA (playtest)"
install.bat -DryRun                 :: 只预览，不写任何文件
install.bat -Uninstall              :: 还原
install.bat -FontPath "D:\NotoSansSC-Regular.ttf"   :: 指定中文字体
```

### 安装参数

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

## 覆盖范围

补丁针对三个可玩的游戏模组：**红色警戒 (ra)**、**泰伯利亚黎明 (cnc)**、**沙丘 2000 (d2k)**。

| 界面 | 状态 |
|---|---|
| 主菜单、设置（显示 / 音频 / 操作 / 快捷键 / 高级 / 游戏性） | 已汉化 |
| 单人、遭遇战、多人房间、服务器列表与提示 | 已汉化 |
| 游戏内指令（攻击移动 / 护卫 / 散开 / 强制移动 / 四种姿态） | 已汉化 |
| 观战统计、录像播放器、地图编辑器 | 已汉化 |
| 全部快捷键说明 | 已汉化 |
| 内容安装向导与「内容管理」（含 30 条安装源名称） | 已汉化 |
| 三个阵营的单位、建筑、防御、超级武器名称与说明 | 已汉化 |
| 战役任务目标与任务内对话（ra / cnc / d2k） | 已汉化 |
| **战役简报正文（每关开始前的长篇简报，129 份）** | 已汉化 |
| **战役分组名（「盟军战役 / GDI 战役 / 阿特雷德斯战役」等 16 个）** | 已汉化 |
| 遭遇战设置、地图生成器、阵营说明 | 已汉化 |
| 内容安装器的悬停提示、建服对话框的默认服务器名 | 已汉化 |
| 地图内硬编码文本（3 处倒计时、1 处任务提示） | 已汉化 |
| 地图元数据里的地图标题（任务列表条目显示的 `Allies 01` 等） | **未汉化，见下方说明** |

统计：**2,504 条 Fluent 文案 + 30 条安装源名称 + 129 份战役简报 + 16 个战役分组名 + 若干地图内文本**，
共 **196 个载荷文件**、约 581 KB。

### 为什么任务列表里的关卡名还是英文

任务列表里的每个条目显示的是**地图元数据**（`mods/<mod>/maps/<地图>/map.yaml` 的 `Title`），
共 144 处，例如 `Allies 01`、`GDI 06`、`Harkonnen 09a`。这些字段**故意不翻译**：

> 地图 UID = `SHA1(map.yaml + *.bin + *.lua + map.png)`。改动 `map.yaml` 会让打了补丁的玩家与
> 未打补丁的玩家**地图哈希不一致**（无法同局游戏），旧录像也会因为找不到对应地图而无法播放。
> 好消息是 `.ftl` 不参与 UID 计算，所以本补丁的译文不会影响联机兼容性。

## 中文字体：为什么安装时才复制

OpenRA 的 `Fonts:` 配置默认指向 `common|FreeSans.ttf`，该字体**没有中文字形**，
不换字体的话所有中文都会变成方块。本补丁的 `mod.yaml` 已把字体指向 `common|SimHei.ttf`，
安装脚本会把**你本机的**中文字体复制成那个文件：

- 好处：不必随包分发字体，避免字体授权问题；安装后完全不依赖网络。
- 如果本机字体不是 `simhei.ttf`，脚本会把 `mod.yaml` 里的引用同步改成实际文件名。
- 想换更好看的字体（例如[思源黑体](https://github.com/notofonts/noto-cjk)）：
  `install.bat -FontPath "D:\NotoSansSC-Regular.ttf"`。

## 卸载与还原

所有被覆盖的文件都备份到 `<OpenRA 目录>\_zhcn-backup\<时间戳>\`，并附 `backup.json` 记录清单。

- 双击 `uninstall.bat`，或 `install.bat -Uninstall`：还原全部文件、删除新增的字体文件。
- 也可以手动把备份目录里的文件复制回去。
- 备份目录不会被自动删除（还原后改名为 `*.已还原`），方便反复折腾。

### 卸载后校验

还原之后想确认「到底卸干净没有」，双击 `verify-uninstall.bat`（或 `install.bat -Verify`）。
它会按 `manifest.json` 里 196 个载荷的 SHA-256 逐文件比对安装目录：

**全部不一致 → 已彻底卸载（英文原版）；仍有哈希一致的 → 列出来告诉你哪些没卸掉。**

字体残留（`mods/common/SimHei.ttf`）也会一并提示。退出码 0 表示干净、1 表示仍有残留。

## 引擎升级后请注意

Fluent **不会**在缺失键时回退英文，而是把键名直接显示出来（例如界面上出现
`options-game-speed.normal` 这样的字样）。因此：

- 本补丁只适配 `playtest-20260222`。升级到更新的引擎后请**先卸载本补丁**，
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
