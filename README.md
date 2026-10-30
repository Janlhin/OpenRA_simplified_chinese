<div align="center">

# 🎮 OpenRA 简体中文汉化补丁

**红警 · 泰伯利亚黎明 · 沙丘 2000 —— 界面、单位、任务、简报，一次全中文**

[![validate](https://github.com/Janlhin/OpenRA_simplified_chinese/actions/workflows/validate.yml/badge.svg)](https://github.com/Janlhin/OpenRA_simplified_chinese/actions/workflows/validate.yml)
[![release](https://img.shields.io/github/v/release/Janlhin/OpenRA_simplified_chinese?label=release&color=2ea44f)](https://github.com/Janlhin/OpenRA_simplified_chinese/releases)
[![license](https://img.shields.io/badge/license-GPL--3.0--or--later-blue.svg)](LICENSE)
![platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D4)

</div>

> 🧩 非官方社区作品，与 OpenRA 项目无隶属关系。适配引擎 **`playtest-20261026`**。

---

## ✨ 它做了什么

| | 内容 |
|---|---|
| 🖥️ **界面** | 主菜单、设置六大页、单人 / 遭遇战 / 多人房间、服务器列表、观战、录像、地图编辑器 |
| 🪖 **单位与建筑** | 三个阵营的名称、说明、武器与技能提示（含超级武器） |
| 🎯 **任务** | 任务目标、任务内对话、**140 份战役简报**、16 个战役分组名 |
| ⌨️ **快捷键** | 设置 → 快捷键页的全部条目 |
| 💿 **内容安装器** | 安装向导的 20 条下载源名称、光盘提示 |
| 🐞 **作弊面板** | 上游把 `Debug` 更名为 `Cheats` 后的整套新文案 |

**三个"不做"**，避免踩坑：

- 🚫 **不碰 `map.yaml`** —— 地图 UID 会变，联机对不上、旧录像读不了
- 🚫 **不改游戏逻辑** —— 只换文本，不动 `.dll`、不动美术音频
- 🚫 **不联网** —— 安装、校验、还原全部本地完成

## 📥 三分钟装好

1. ⬇️ 到 **[Releases](https://github.com/Janlhin/OpenRA_simplified_chinese/releases)** 下载最新的 `OpenRA_simplified_chinese-x.y.z.zip`
2. 📂 解压到一个**英文路径**下，例如 `D:\OpenRA_CN`
3. 🛑 **关闭 OpenRA**
4. 🖱️ 双击 **`setup.cmd`** → 菜单输入 `1` → 回车

> 装在 `C:\Program Files` 会弹一次 UAC；引擎版本不匹配会先警告再询问。

命令行等价用法：

```bat
setup.cmd -Target "C:\Program Files\OpenRA (playtest)"   :: 指定目录
setup.cmd -DryRun        :: 只预览，不写任何文件
setup.cmd -Uninstall     :: 还原英文
setup.cmd -Verify        :: 校验是否卸干净
setup.cmd -FontPath "D:\你的字体.ttf"   :: 换字体
```

## 🧩 包里有什么

解压后**顶层 9 项**，连子目录共 218 个文件：

```text
OpenRA_simplified_chinese\
├─ 🖱️ setup.cmd                  ← 双击这个
├─ 📖 README.md                  ← 逐文件说明（含 208 行清单）
├─ 📄 安装说明.txt / .md           ← 三步装 / 手动装 / AI 装 / FAQ
├─ ⚖️ LICENSE / LICENSE-OFL.txt   ← 补丁 GPL、字体 OFL
├─ 📦 bin\  install.ps1 · manifest.json
├─ 🔤 fonts\ NotoSansSC-Regular.ttf · -Bold.ttf
└─ 📚 files\mods\                 ← 208 个中文文本（覆盖到游戏 mods\）
```

每个文件干什么、能不能删、属于哪一类，见 **[`src/PACKAGE-README.md`](src/PACKAGE-README.md)**
（它就是打进 zip 的那份 `README.md`，附全部 208 个载荷的清单与大小）。

## 🗺️ 覆盖范围

| 模块 | 状态 |
|---|---|
| 红色警戒 (ra) 界面 / 单位 / 战役 | ✅ 已汉化 |
| 泰伯利亚黎明 (cnc) 界面 / 单位 / 战役 | ✅ 已汉化 |
| 沙丘 2000 (d2k) 界面 / 单位 / 战役 | ✅ 已汉化 |
| 内容安装向导与「内容管理」 | ✅ 已汉化 |
| 地图元数据里的地图标题（`Allies 01` 等） | ❌ **故意不翻**（见下） |

> ❓ 为什么任务列表里的关卡名还是英文：
> 地图 UID = `SHA1(map.yaml + *.bin + *.lua + map.png)`。改 `map.yaml` 会让打了补丁的玩家与
> 没打补丁的玩家**地图哈希不一致**，旧录像也会读不出来。`.ftl` 不参与 UID 计算，所以译文不影响联机。

## 🧱 仓库结构

```text
.
├─ 📄 README.md                       你正在看的
├─ ⚖️ LICENSE · LICENSE-OFL.txt       补丁 GPL-3.0 / 字体 SIL OFL 1.1
├─ 📦 src\                            打包源（进 zip 的就是这里）
│   ├─ setup.cmd · install.ps1 · manifest.json
│   ├─ PACKAGE-README.md              包内 README 的源文件
│   └─ 安装说明.txt · 安装说明.md
├─ 📚 files\mods\                     208 个载荷（覆盖树）
├─ 🔤 fonts\                          Noto Sans SC 两个字重
├─ 🛠️ tools\                          校验、载荷重建、打包、文档生成
├─ 📘 docs\                           ANATOMY · MAINTAINING · CONTRIBUTING · CHANGELOG
│   └─ archive\rasc-ref\              译名对齐的历史资料（已归档）
└─ ⚙️ .github\                        CI 与 issue / PR 模板
```

| 想了解 | 去哪看 |
|---|---|
| 🗂️ 每个文件是什么、载荷怎么构成 | [`docs/ANATOMY.md`](docs/ANATOMY.md) |
| 🔧 怎么重建载荷、怎么发版、CI 有哪些门禁 | [`docs/MAINTAINING.md`](docs/MAINTAINING.md) |
| ✍️ 想改一句译文 | [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) |
| 🕒 每个版本改了什么 | [`docs/CHANGELOG.md`](docs/CHANGELOG.md) |

## 🛠️ 本地校验

CI 跑同样的八步，本地先跑能省一轮往返：

```bash
python tools/verify_manifest.py        # 载荷 ↔ src/manifest.json 逐字节一致
python tools/lint_ftl.py files/mods    # Fluent 规范（BOM/换行/缩进/字面转义）
python tools/struct_check_maps.py files/mods
python tools/check_links.py .          # Markdown 链接与锚点
python tools/build_readme_inventory.py --check   # 附录 A 与 manifest 一致
python tools/check_font_coverage.py    # 载荷里的每个字，随包字体都画得出来
python tools/build_release.py --verify # 打包自校验（含包内死链）
```

## ❓ 常见问题

<details>
<summary>🀄 界面还是英文 / 有方块？</summary>

英文 → 文本没覆盖成功，检查是否多套了一层 `mods\mods`；
方块 → 字体没生效，`mods\common\` 下应当有 `NotoSansSC-Regular.ttf` 与 `-Bold.ttf`。
完整排查见 [`src/安装说明.md`](src/安装说明.md)。
</details>

<details>
<summary>🔁 卸载了但还是中文？</summary>

1.5.2 之前确实会这样：卸载可能挑中"重复安装留下的译文快照"。现在会自动跳过这类备份，
并用最早那份真正的英文快照还原。重跑 `setup.cmd` → `2` 即可；也可
`setup.cmd -Uninstall -Backup <备份目录名>` 指定。
</details>

<details>
<summary>🌐 会影响联机或存档吗？</summary>

不改地图数据，联机兼容；存档在 `%APPDATA%\OpenRA`，补丁不碰。
但服务器若装了文件校验插件，理论上可能判定为改文件。
</details>

<details>
<summary>🛡️ 杀毒软件报毒？</summary>

安装器是未签名的脚本，部分杀软会提示。不放心就走 `安装说明` 里的**手动安装**，效果完全一样。
</details>

## ⚠️ 已知限制

- 🔤 字体用的是 **Noto Sans SC 全量字形**（约 20 MB），比系统黑体占空间，但换来"不依赖本机字体"
- 📐 字号观感：Noto 的行高与原 `FreeSans` 不同，个别 UI 缩放档位可能略挤，可在 `mod.yaml` 的 `Fonts:` 微调
- 🪟 只提供 Windows 脚本；Linux / macOS 可手动覆盖 `files/` 并把 `fonts/` 放进 `mods/common/`
- 🧭 只适配 `playtest-20261026`；引擎升级后请先卸载旧补丁再更新

## 🛣️ 后续计划

- [x] 🎨 随包自带中文字体，不再依赖本机
- [x] 🧯 安装器可回滚、可校验、卸载能挑对备份
- [ ] 📸 补一组界面截图，放到 README 顶部
- [ ] 🖋️ 可选主题字体（霞鹜文楷），做成独立附件
- [ ] 🧨 **入口全面改用 `.ps1`**：退役 `setup.cmd`，替代方案二选一（`.lnk` 双击垫片 / 单文件 exe）
- [ ] 📜 **约定落地**：不再新增 `.cmd` / `.bat`，CI 已加守卫；存量只剩 `setup.cmd` 一个转发器
- [ ] 🐧 Linux / macOS 的一页式手动安装文档
- [ ] 📝 术语表统一校对（借 `docs/archive/rasc-ref` 的对齐结果）

> 有想法欢迎开 issue；计划表只代表方向，不代表排期。

## 🙏 致谢

| | 贡献 |
|---|---|
| 🎮 [OpenRA](https://www.openra.net/) 项目 | 游戏引擎与全部原始英文文案。本补丁只做翻译，不改逻辑 |
| 🇨🇳 OpenRA 汉化组（Gitee [CastleJing](https://gitee.com/CastleJing)） | 红警 [RASC](https://gitee.com/CastleJing/OpenRA_rasc) 与泰伯利亚黎明 [TDSC](https://gitee.com/CastleJing/OpenRA_tdsc) 的译法共识，本项目单位与建筑名对齐其用词 |
| 🔤 [Noto Sans SC](https://github.com/notofonts/noto-cjk) | 随包中文字体，Google / Adobe 出品，SIL OFL 1.1 |
| 🐞 所有反馈者 | 提交译文修正、报告方块字与漏翻的人，见 [`docs/CHANGELOG.md`](docs/CHANGELOG.md) |

## 📄 许可

- 本补丁：**GPL-3.0-or-later**，全文见 [`LICENSE`](LICENSE)
- 随包字体 Noto Sans SC：**SIL OFL 1.1**，全文见 [`LICENSE-OFL.txt`](LICENSE-OFL.txt)
- 原始英文文案版权归 OpenRA 项目（GPL-3.0）所有

---

<div align="center">

⭐ 如果这个补丁让你玩得舒服一点，点个 Star 就是最好的支持

</div>
