# rasc-ref ——「汉化组译名对齐」工作目录

这里放的是把 `ra` / `cnc` 的单位与建筑名，对齐到 OpenRA 汉化组（Gitee `CastleJing`）
**RASC / TDSC** 译法时用到的脚本与产物。

**参考仓库本身不在本目录**——它们体积大（合计约 75 MB）且属于他人作品，不应复制进本仓库。
需要时按下面命令自己克隆。

## 先克隆参考仓库

```bash
git clone https://gitee.com/CastleJing/OpenRA_rasc   # 红警（约 49 MB）
git clone https://gitee.com/CastleJing/OpenRA_tdsc   # 泰伯利亚黎明（约 26 MB）
```

两个仓库都是 2020 年的 **pre-Fluent** 版本：中文直接内嵌在 `mods/<mod>/rules/*.yaml` 的
`Tooltip: Name:` 里，**没有任何 `.ftl`**。所以不能直接套用，只能按英文 actor ID 锚定、取译法字面。

对齐的结论也写在 [CHANGELOG](../../CHANGELOG.md) 的 1.3.1 一节里（沙丘 2000 无公开的汉化组仓库，
维持本项目既有译法）。

## 对齐工作（主线）

| 文件 | 作用 |
|---|---|
| `extract_rasc.py` | 从参考仓库的 yaml 中抽出全部中文记录 → `rasc_translations.json` |
| `compare_rasc_ours.py`、`compare2.py` | 把抽出的译名与我们的 `.ftl` 逐条比对，输出差异报告 |
| `align_mod.py` | **最终对齐脚本**：按块解析、只取本体 actor 的 `Tooltip.Name`，把 `.name` 与残骸名换成全称。注意其中两个坑——键名正则必须非贪心、写回必须 `newline='\n'` |
| `fix_typo.py` | 一次性修正 `支奴干` → `支努干`（CH-47 的标准译名） |

产物（都能由上面的脚本重新生成）：

| 文件 | 内容 |
|---|---|
| `rasc_translations.json` | 从 RASC / TDSC 抽出的中文条目（307 KB） |
| `rasc_alignment_report.md`、`rasc_name_alignment.md`、`rasc_vs_ours.md` | 三份比对报告 |

## 顺带存放的运维脚本

这些不是对齐工作本身，而是同一轮整理仓库时用到的脚本，放在这里以免散失。
其中三个已经是仓库的正式工具（`tools/check_links.py`、`tools/build_release.py`、`tools/build_manifest.py`）。

| 文件 | 作用 |
|---|---|
| `scan_folder.py` | 只读盘点：目录结构 / 体积 / 垃圾候选 / 双副本差异 |
| `recon_encoding.py` | 改 `.ps1` / `.bat` 之前侦察 BOM 与换行（改错会让中文乱码） |
| `recompute_manifest.py` | 全量重算 `manifest.json` 的 `size` / `sha256` |
| `rename_repo.py`、`rename_ftl.py` | 全局改仓库名，字节级替换（保住各文件编码与换行，新旧名等长则体积不变） |
| `apply_cleanup.py`、`patch_manifest.py` | 只改一两个文件时的定点修复 |
| `inventory.py` | 清点仓库内容，生成「每个文件干什么用」的素材 |
| `set_repo_meta.py` | 用本机 git 凭据设置仓库 description / homepage / topics |
| `create_release.py`、`verify_release.py` | 创建 GitHub Release 并上传附件；独立复核附件能否匿名下载且逐字节一致 |
| `build_release.py` | 与本仓库正式工具 [`../build_release.py`](../build_release.py) 相同，此处保留副本 |

> 全部只依赖 Python 标准库。`set_repo_meta.py` / `create_release.py` / `verify_release.py`
> 会用 `git credential fill` 取本机凭据，token 只在内存中使用、不落盘也不回显。

## 维护者提示

- 参考仓库是他人作品，**不要**把它们的整份内容复制进本仓库。
- `rasc_translations.json` 是从参考仓库派生的**译法参考数据**，不改变 `files/` 下译文本身的
  许可归属（仍是 GPL-3.0-or-later）。
