# OpenRA 简体中文汉化补丁

[![validate](https://github.com/Janlhin/OpenRA_simplified_chinese/actions/workflows/validate.yml/badge.svg)](https://github.com/Janlhin/OpenRA_simplified_chinese)

给 **[OpenRA](https://www.openra.net/)**（`playtest-20261026`）加上简体中文的补丁：
红警 / 泰伯利亚黎明 / 沙丘 2000 三个模组的界面、单位与建筑名称、任务目标，以及全部战役简报。

- 只改**文本**：不含游戏本体、美术、音频；**不碰 `map.yaml`**，联机与录像不受影响。
- **自带中文字体**（Noto Sans SC 两个字重），不依赖系统有没有中文字体。
- 逐文件 SHA-256 校验、覆盖前备份、一键还原，全程不联网。

> 非官方社区作品，与 OpenRA 项目无隶属关系。许可证 [GPL-3.0-or-later](LICENSE)。

## 给玩家

下载 [Release](https://github.com/Janlhin/OpenRA_simplified_chinese/releases) 里的 zip，解压到英文路径，
双击 `setup.cmd`，菜单里选 `1`。三分钟装好。

发布包里每个文件是干什么的，见 **[src/PACKAGE-README.md](src/PACKAGE-README.md)**（它就是我们打进 zip 的那份
`README.md`，包含全部 208 个载荷文件的清单）；安装步骤与常见问题见 **[src/安装说明.md](src/安装说明.md)**。

> `src/PACKAGE-README.md` 是**发布包专用**的文档：里面的链接只指向 zip 内确实存在的文件。
> 仓库根目录的这份 README 面向读源码的人，两边不要互相复制。

## 仓库布局

| 路径 | 内容 |
|---|---|
| `src/` | **打包源**：`setup.cmd`、`install.ps1`、`manifest.json`、`PACKAGE-README.md`、`安装说明.txt/.md`。打包时按 `PACKAGE_LAYOUT` 映射进 zip 的根与 `bin/` |
| `files/mods/` | 208 个中文载荷（覆盖树，路径与游戏 `mods/` 一致） |
| `fonts/` | 随包字体 Noto Sans SC（Regular / Bold），**不进 `files/`** |
| `tools/` | 校验、载荷重建、发布打包、文档生成（**不进发布包**） |
| `docs/` | [架构](docs/ANATOMY.md)、[维护与发版](docs/MAINTAINING.md)、[贡献指南](docs/CONTRIBUTING.md)、[更新日志](docs/CHANGELOG.md)、`archive/` 历史资料（**不进发布包**） |
| `.github/` | CI（`workflows/validate.yml`）与 issue / PR 模板 |

根目录只剩 5 个文件：`README.md`、`LICENSE`、`LICENSE-OFL.txt`、`.gitattributes`、`.gitignore`。

## 提交前跑一遍

CI 会跑同样的检查，本地先跑能省一轮往返：

```bash
python tools/verify_manifest.py            # 载荷 ↔ src/manifest.json 逐字节一致
python tools/build_readme_inventory.py     # 改了载荷就先重生成包内 README 的附录 A
python tools/lint_ftl.py files/mods        # Fluent 规范（BOM / 换行 / 缩进 / 字面转义）
python tools/struct_check_maps.py files/mods
python tools/check_links.py .              # Markdown 链接与锚点
python tools/check_font_coverage.py        # 载荷里的字，随包字体都画得出来
python tools/build_release.py --verify     # 发布包自校验
```

## 文档

- [docs/ANATOMY.md](docs/ANATOMY.md) —— 仓库里每个文件做什么、载荷怎么构成
- [docs/MAINTAINING.md](docs/MAINTAINING.md) —— 校验工具、引擎升级怎么迁移译文、怎么发版
- [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) —— 翻译约定与提交流程
- [docs/CHANGELOG.md](docs/CHANGELOG.md) —— 每个版本改了什么
