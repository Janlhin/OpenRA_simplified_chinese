## OpenRA 简体中文汉化补丁 (SPDX-License-Identifier: GPL-3.0-or-later)
## 中文译文:OpenRA_simplified_chinese 项目贡献;原始英文文案版权归 OpenRA 项目 (GPL-3.0) 所有。
## ingame-observer.yaml
label-economy-stats-harvesters-header = 采矿车
label-economy-stats-derricks-header = 石油钻井



## ingame-player.yaml
button-command-bar-force-move =
    .tooltip = 强制移动
    .tooltipdesc =
    所选单位会前往指定位置
     - 忽略目标的默认行为
     - 车辆会尝试碾压目标位置上的敌人
     - 直升机会在目标位置降落
     - 超时空坦克会朝目标位置瞬移

    左键点击图标,然后在目标上右键点击。
    下达命令时按住 <(Alt)> 可临时启用。

button-command-bar-force-attack =
    .tooltip = 强制攻击
    .tooltipdesc =
    所选单位会攻击指定单位或位置
     - 忽略目标的默认行为
     - 可以指定己方或友军单位
     - 远程炮兵单位会始终攻击该位置,
       忽略单位与建筑

    左键点击图标,然后在目标上右键点击。
    下达命令时按住 <(Ctrl)> 可临时启用。

button-command-bar-deploy =
    .tooltip = 展开
    .tooltipdesc =
    所选单位会执行其默认展开行为
     - 机动基地车会展开为建造厂
     - 建造厂会收起为机动基地车
     - 运输载具会卸下乘客
     - 自爆卡车与 MAD 坦克会自毁
     - 布雷车会布设地雷
     - 飞机会返回基地

    对所选单位立即生效。


button-top-buttons-beacon-tooltip = 放置信号标
button-top-buttons-sell-tooltip = 变卖
button-top-buttons-power-tooltip = 断电
button-top-buttons-repair-tooltip = 维修

button-production-types-building-tooltip = 建筑
button-production-types-defense-tooltip = 防御
button-production-types-infantry-tooltip = 步兵
button-production-types-vehicle-tooltip = 车辆
button-production-types-aircraft-tooltip = 飞行器
button-production-types-naval-tooltip = 海军
