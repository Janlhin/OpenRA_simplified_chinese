# 参与贡献

感谢愿意帮忙。这个仓库只做一件事:**把 OpenRA 的界面与剧情文案翻成中文**。
它只包含文本文件,不分发游戏素材,也不分发字体。

> 只是来玩这个汉化的?看 [README.md](README.md) 就够了。
> 想知道仓库里每个文件干什么用,看 [docs/ANATOMY.md](docs/ANATOMY.md);
> 想了解载荷怎么生成、发布流程与 CI,看 [docs/MAINTAINING.md](docs/MAINTAINING.md)。

## 环境准备

1. 一份英文原版 OpenRA 安装目录,例如 `C:\Program Files\OpenRA (playtest)`(下称"原版目录")。
2. 一份装好本补丁的安装目录(下称"汉化目录"),用于对照与试跑。
3. Python 3(跑校验脚本,不需要任何第三方库)。

## 最常见的改动:修一句译文

1. 直接在 `files/` 下找到对应的 `.ftl`,改掉译文。
   文件路径与游戏安装目录一一对应,例如 `files/mods/ra/fluent/rules.ftl` → `<安装目录>/mods/ra/fluent/rules.ftl`。
2. 跑三个自检(三个都要过):

   ```bash
   python tools/verify_manifest.py          # 载荷与 manifest.json 逐字节一致
   python tools/lint_ftl.py files/mods      # BOM / 换行 / 缩进 / 花括号
   python tools/struct_check_maps.py files/mods
   ```

3. 因为改了字节,必须同步哈希:

   ```bash
   python tools/build_manifest.py --original "C:\Program Files\OpenRA (playtest)" \
                                  --patched  "C:\Users\你\OpenRA-CN"
   ```

   也可以只改 `manifest.json` 里那一个文件的 `size` / `sha256`,但用脚本更不容易出错。
4. 提 PR,在描述里写清"改了哪个模组的哪句话、为什么"。

> CI 会在 Linux 上重跑上面第 2 步的三个检查(并额外做文档链接检查与字体分发守卫),任一失败都会挡下 PR。
> 注意 `files/**` 在 `.gitattributes` 里标了 `-text`,**不要在编辑器里让它自动转换换行**,
> 否则哈希会对不上。

## 较大的改动:适配新的引擎版本

OpenRA 升级会带来新键、删改旧键。Fluent **不会**在缺键时回退英文,而是把键名直接显示出来,
所以必须"以新版英文为骨架重新合并":

1. 用新的英文原版目录 diff 出改动清单并重建载荷:

   ```bash
   python tools/build_manifest.py --original "<新版原版目录>" --patched "<新版汉化目录>" \
                                  --version 1.3.1 --engine playtest-20XXXXXX --dry-run   # 先看要改哪些
   ```

2. 逐个 `.ftl` 合并:以新版英文的键序为准,把已有译文搬过去,新键补译,删掉的键删掉。
   用 `python tools/validate_ftl.py <原版 mods> <汉化 mods> <相对路径...>` 可以逐键比对。
3. 别忘了同步 `README.md` 与 `CHANGELOG.md` 里的版本号、条数与载荷文件数。

## 翻译规范

- **不改键名**,不动 `{ $变量 }`、`{ -术语 }`、`{ $n -> ... }` 复数选择器和 `<(...)>` 这类标记。
- 多行取值保持缩进(4 空格)与段落间空行;不要用制表符。
- 只改译文,不要顺手重排整个文件(会让 diff 失去意义)。
- 术语保持一致,优先沿用现有翻译。核心对照:

  | 游戏 | 术语 |
  |---|---|
  | 红色警戒 | Allies 盟军、Soviet 苏联、Ore Truck 采矿车、Tesla Coil 磁暴线圈、Iron Curtain 铁幕装置、Chronosphere 超时空传送仪、Gap Generator 黑幕发生器、Mammoth Tank 猛犸坦克 |
  | 泰伯利亚黎明 | Tiberium 泰伯利亚、GDI 全球防御组织、Nod 兄弟会、Commando 特种兵、Orca 奥卡、Obelisk of Light 光明方尖碑、Ion Cannon 离子炮 |
  | 沙丘 2000 | Spice 香料、Solaris 索拉里斯、Mentat 门塔特、Harvester 采集车、Carryall 搬运机、Ornithopter 扑翼机、Wind Trap 风阱、Starport 星港、Sietch 穴地、Sardaukar 萨杜卡、Deviator 变节者 |

## 会被拒绝的改动

- 把字体（`.ttf` / `.ttc` / `.otf`）或任何游戏素材放进 `files/`——授权原因,补丁一律不分发。
- 修改键名、删键、把 `##` 注释与 SPDX 头去掉。
- 只改译文却不更新 `manifest.json` 里的 `size` / `sha256`。
- 用机器翻译粗糙地批量替换、明显不通顺的句子。

## 开发脚本一览

| 脚本 | 作用 |
|---|---|
| `tools/verify_manifest.py` | 载荷 ↔ manifest 一致性(CI 必跑) |
| `tools/lint_ftl.py` | Fluent 文件规范(CI 必跑) |
| `tools/struct_check_maps.py` | 地图 .ftl 结构;给两个参数时与英文原版比对键集合 |
| `tools/check_links.py` | Markdown 相对链接与锚点(CI 必跑) |
| `tools/audit_coverage.py` | 覆盖率审计:列出还差哪些没翻,并说明哪些是故意不改的 |
| `tools/validate_ftl.py` | 与英文原文逐键比对占位符 / 复数选择器 |
| `tools/check_yaml_fluent_refs.py` | yaml 里引用的消息键是否都能解析(支持与原版差分) |
| `tools/check_font_glyphs.py` | 检查某个字体是否覆盖所需汉字 |
| `tools/build_manifest.py` | 维护者:diff 原版与汉化目录,重建 `files/` 与 `manifest.json` |
| `tools/build_release.py` | 维护者:构建发布包 zip(确定性,`--verify` 会解压自校验) |

脚本的调用示例、CI 的五步检查、以及端到端验证记录,都在 [docs/MAINTAINING.md](docs/MAINTAINING.md)。
