## OpenRA 简体中文汉化补丁 (SPDX-License-Identifier: GPL-3.0-or-later)
## 中文译文:OpenRA_simplified_chinese 项目贡献;原始英文文案版权归 OpenRA 项目 (GPL-3.0) 所有。
## player.yaml
options-tech-level =
    .infantry-only = 仅步兵
    .low = 低
    .medium = 中
    .no-superweapons = 无超级武器
    .unrestricted = 不限制

checkbox-kill-bounties =
    .label = 击杀奖励
    .description = 玩家击杀敌方单位可获得资金奖励

checkbox-redeployable-mcvs =
    .label = 可重新部署的移动建造车
    .description = 允许建造厂收起为移动建造车

checkbox-reusable-engineers =
    .label = 可重复使用的工程师
    .description = 工程师占领建筑后仍留在战场上

notification-insufficient-funds = 资金不足。
notification-new-construction-options = 有新的建造项目。
notification-cannot-deploy-here = 无法在此展开。
notification-low-power = 电力不足。
notification-base-under-attack = 基地遭受攻击。
notification-ally-under-attack = 我方盟友遭受攻击。
notification-silos-needed = 需要储存罐。

## world.yaml
notification-game-saved = 游戏已保存。

options-starting-units =
    .mcv-only = 仅移动建造车
    .light-support = 轻型支援
    .heavy-support = 重型支援

resource-minerals = 珍贵矿物

map-generator-classic = 地图生成器
map-generator-clear = 清除地形

## Faction
faction-allies =
    .name = 盟军

faction-england =
    .name = 英国
    .description = 英国：反间谍
     特殊单位：英国间谍
     特殊单位：机动黑幕发生器

faction-france =
    .name = 法国
    .description = 法国：欺骗
     特殊能力：可建造伪装建筑
     特殊单位：相位运输车

faction-germany =
    .name = 德国
    .description = 德国：超时空科技
     特殊能力：高级超时空传送
     特殊单位：超时空坦克

faction-soviet =
    .name = 苏联

faction-russia =
    .name = 俄国
    .description = 俄国：电磁武器
     特殊单位：磁暴坦克
     特殊单位：电击兵

faction-ukraine =
    .name = 乌克兰
    .description = 乌克兰：爆破
     特殊能力：伞降炸弹
     特殊单位：自爆卡车

faction-random =
    .name = 任意
    .description = 随机国家
     游戏开始时随机选择一个国家

faction-randomallies =
    .name = 盟军
    .description = 随机盟军国家
     游戏开始时随机选择一个盟军国家

faction-randomsoviet =
    .name = 苏联
    .description = 随机苏联国家
     游戏开始时随机选择一个苏联国家

## aircraft.yaml
actor-badr-name = 獾式运输机

actor-mig =
    .name = 米格战机
    .description =
    快速对地攻击机。
      对建筑与车辆强
      对步兵与飞行器弱

actor-yak =
    .name = 雅克攻击机
    .description =
    装备双联机枪的攻击机。
      对步兵与轻装甲强
      对坦克与飞行器弱

actor-tran =
    .name = 支努干运输机
    .description =
    快速步兵运输直升机。
      无武装

actor-heli =
    .name = 长弓武装直升机
    .description =
    装备多用途导弹的武装直升机。
      对建筑、车辆与飞行器强
      对步兵弱

actor-hind =
    .name = 雌鹿武装直升机
    .description =
    装备双联链式机炮的武装直升机。
      对步兵与轻装甲强
      对坦克与飞行器弱

actor-u2-name = 侦察机

actor-mh60 =
    .name = 黑鹰武装直升机
    .description =
    装备双联链式机炮的武装直升机。
      对步兵与轻装甲强
      对坦克与飞行器弱

## civilian.yaml
actor-c10-name = 科学家
actor-tecn-name = 技工
actor-tecn2-name = 技工
actor-v01-name = 教堂
actor-v19-name = 抽油机
actor-v19-husk-name = 残骸（抽油机）
actor-barl-name = 爆炸桶
actor-brl3-name = 爆炸桶
actor-v25-name = 教堂
actor-lhus-name = 灯塔
actor-windmill-name = 风车

## decoration.yaml
actor-ice01-name = 浮冰
actor-ice02-name = 浮冰
actor-ice03-name = 浮冰
actor-ice04-name = 浮冰
actor-ice05-name = 浮冰
actor-utilpol1-name = 电线杆
actor-utilpol2-name = 电线杆
actor-tanktrap1-name = 反坦克桩
actor-tanktrap2-name = 反坦克桩

## defaults.yaml
notification-unit-lost = 单位损失。
notification-airborne-unit-lost = 空中单位损失。
notification-naval-unit-lost = 海军单位损失。
notification-unit-promoted = 单位晋升。
notification-primary-building-selected = 已选定主建筑。
notification-structure-captured = 建筑已被占领。
notification-unit-stolen = 单位被窃取。

meta-vehicle-generic-name = 车辆
meta-infantry-generic-name = 步兵
meta-civinfantry-name = 平民
meta-ship-generic-name = 舰船
meta-neutralplane-generic-name = 飞机
meta-helicopter-generic-name = 直升机
meta-basicbuilding-generic-name = 建筑
meta-techbuilding-name = 民用建筑
meta-ammobox-name = 弹药箱
meta-civfield-name = 农田

meta-civhaystackorigloo =
    .winter-name = 圆顶雪屋
    .summer-name = 草垛

meta-tree-name = 树
meta-treehusk-name = 树（已烧毁）
meta-box-name = 箱子
meta-husk-generic-name = 被摧毁的车辆
meta-planehusk-generic-name = 被摧毁的飞机
meta-helicopterhusk-generic-name = 被摧毁的直升机
meta-bridge-name = 桥梁
meta-rock-name = 岩石

meta-crate =
    .name = 补给箱
    .generic-name = 补给箱

meta-mine-name = 地雷

## fakes.yaml
actor-fpwr =
    .name = 伪装发电厂
    .generic-name = 发电厂
    .description = 外观与发电厂相同。

actor-tenf =
    .name = 伪装盟军兵营
    .generic-name = 盟军兵营
    .description = 外观与盟军兵营相同。

actor-syrf =
    .name = 伪装造船厂
    .generic-name = 造船厂
    .description = 外观与造船厂相同。

actor-spef =
    .name = 伪装潜艇船坞
    .generic-name = 潜艇船坞
    .description = 外观与潜艇船坞相同。

actor-weaf =
    .name = 伪装战车工厂
    .generic-name = 战车工厂
    .description = 外观与战车工厂相同。

actor-domf =
    .name = 伪装雷达站
    .generic-name = 雷达站
    .description = 外观与雷达站相同。

actor-fixf =
    .name = 伪装维修厂
    .generic-name = 维修厂
    .description = 外观与维修厂相同。

actor-fapw =
    .name = 伪装高级发电厂
    .generic-name = 高级发电厂
    .description = 外观与高级发电厂相同。

actor-atef =
    .name = 伪装盟军科技中心
    .generic-name = 盟军科技中心
    .description = 外观与盟军科技中心相同。

actor-pdof =
    .name = 伪装超时空传送仪
    .generic-name = 超时空传送仪
    .description =
    外观与超时空传送仪相同。
    最多只能建造一座。

actor-mslf =
    .name = 伪装导弹发射井
    .generic-name = 导弹发射井
    .description =
    外观与导弹发射井相同。
    最多只能建造一座。

actor-facf =
    .name = 伪装建造厂
    .generic-name = 建造厂
    .description = 外观与建造厂相同。

## husks.yaml
actor-2tnk-husk-name = 残骸（中型坦克）
actor-3tnk-husk-name = 残骸（重型坦克）
actor-4tnk-husk-name = 残骸（猛犸坦克）
actor-harv-fullhusk-name = 残骸（采矿车）
actor-harv-emptyhusk-name = 残骸（采矿车）
actor-mcv-husk-name = 残骸（移动基地车）
actor-mgg-husk-name = 残骸（机动裂缝产生器）
actor-tran-husk-name = 支努干运输机
actor-tran-husk1-name = 残骸（支努干运输机）
actor-tran-husk2-name = 残骸（支努干运输机）
actor-badr-husk-name = 獾式运输机
actor-mig-husk-name = 米格战机
actor-yak-husk-name = 雅克攻击机
actor-heli-husk-name = 长弓武装直升机
actor-hind-husk-name = 雌鹿武装直升机
actor-u2-husk-name = 残骸（侦察机）
actor-mh60-husk-name = 黑鹰武装直升机

## infantry.yaml
notification-building-infiltrated = 建筑已被渗透。

actor-dog =
    .name = 军犬
    .generic-name = 犬
    .description =
    反步兵单位。
    可以侦测间谍。
      对步兵强
      对车辆与飞行器弱

actor-e1 =
    .name = 步枪兵
    .description =
    通用步兵。
      对步兵强
      对车辆与飞行器弱

actor-e2 =
    .name = 掷弹兵
    .description =
    携带手榴弹的步兵。
      对建筑与步兵强
      对车辆与飞行器弱

actor-e3 =
    .name = 导弹兵
    .description =
    反坦克 / 防空步兵。
      对车辆与飞行器强
      对步兵弱

actor-e4 =
    .name = 火焰兵
    .description =
    高级反建筑单位。
      对步兵与建筑强
      对车辆与飞行器弱

actor-e6 =
    .name = 工程师
    .description =
    渗透并占领
    敌方建筑。
      无武装

actor-spy =
    .disguisetooltip-name = 间谍
    .disguisetooltip-generic-name = 步兵
    .description =
    渗透敌方建筑以获取情报或
    实施破坏。具体效果取决于
    被渗透的建筑。
    攻击时会失去伪装。
    可以侦测间谍。
      对步兵强
      对车辆与飞行器弱
      特殊能力：伪装

actor-spy-england-disguisetooltip-name = 英国间谍

actor-e7 =
    .name = 谭雅
    .description =
    精英特种步兵，装备双持手枪
    与 C4 炸药。
    最多只能建造一名。
      对步兵与建筑强
      对车辆与飞行器弱
      特殊能力：用 C4 摧毁建筑

actor-medi =
    .name = 医疗兵
    .description =
    治疗附近的步兵。
      无武装

actor-mech =
    .name = 机械师
    .description =
    维修附近的车辆，并通过"占领"
    残骸使其恢复可用状态。
      无武装

actor-einstein-name = 爱因斯坦教授
actor-delphi-name = 特工德尔菲
actor-chan-name = 科学家
actor-gnrl-name = 将军

actor-thf =
    .name = 劫持者
    .description =
    窃取敌方资金。
    劫持敌方车辆。
      无武装

actor-shok =
    .name = 磁暴步兵
    .description =
    装备便携式磁暴线圈的精英步兵。
      对步兵与车辆强
      对飞行器弱

actor-zombie =
    .name = 僵尸
    .description =
    行动缓慢、以近身搏斗攻击的亡灵。

actor-ant =
    .name = 巨型蚂蚁
    .generic-name = 蚂蚁
    .description =
    受辐射影响而异常巨大的昆虫。

actor-fireant-name = 火焰蚁
actor-scoutant-name = 侦察蚁
actor-warriorant-name = 兵蚁

## misc.yaml
notification-sonar-pulse-ready = 声呐脉冲就绪。

actor-moneycrate-name = 金钱箱
actor-healcrate-name = 治疗箱
actor-wcrate-name = 木箱
actor-scrate-name = 钢箱
actor-camera-name = （向拥有者揭示区域）
actor-camera-paradrop-name = （支援技能代理相机）
actor-camera-spyplane-name = （支援技能代理相机）
actor-sonar-name = （支援技能代理相机）
actor-flare-name = 照明弹
actor-mine-name = 矿石矿场
actor-gmine-name = 宝石矿场
actor-railmine-name = 废弃矿场
actor-quee-name = 蚁后
actor-lar1-name = 蚂蚁幼虫
actor-lar2-name = 蚂蚁幼虫群
actor-mpspawn-name = （多人游戏出生点）
actor-waypoint-name = （脚本行为路径点）
actor-ctflag-name = 旗帜

## ships.yaml
actor-ss =
    .name = 潜艇
    .description =
    装备鱼雷的潜航反舰单位。
    可以侦测其他潜艇。
      对海军单位强
      对地面单位与飞行器弱
      特殊能力：下潜

actor-msub =
    .name = 弹道导弹潜艇
    .description =
    潜航的反地攻城单位，具备对空
    能力。
    可以侦测其他潜艇。
      对建筑、地面单位与飞行器强
      对海军单位弱
      特殊能力：下潜

actor-dd =
    .name = 导弹驱逐舰
    .description =
    快速多用途舰船。
    可以侦测潜艇。
      对海军单位、车辆与飞行器强
      对步兵弱

actor-ca =
    .name = 重型巡洋舰
    .description =
    速度极慢的远程舰船。
      对建筑与地面单位强
      对海军单位与飞行器弱

actor-lst =
    .name = 运兵船
    .description =
    通用海军运输船。
    可运载步兵与坦克
      无武装

actor-pt =
    .name = 猎潜艇
    .description =
    轻型侦察与支援舰船。
    可以侦测潜艇。
      对海军单位强
      对地面单位与飞行器弱

## structures.yaml
notification-construction-complete = 建造完成。
notification-unit-ready = 单位就绪。
notification-unable-to-build-more = 无法建造更多。
notification-unable-to-comply-building-in-progress = 无法执行。建造正在进行中。
notification-repairing = 正在维修。
notification-unit-repaired = 单位维修完成。
notification-select-target = 选择目标。
notification-insufficient-power = 电力不足。
notification-reinforcements-have-arrived = 增援已抵达。
notification-abomb-prepping = 原子弹准备中。
notification-abomb-ready = 原子弹就绪。
notification-abomb-launch-detected = 侦测到原子弹发射。
notification-iron-curtain-charging = 铁幕充能中。
notification-iron-curtain-ready = 铁幕就绪。
notification-chronosphere-charging = 超时空传送仪充能中。
notification-chronosphere-ready = 超时空传送仪就绪。
notification-satellite-launched = 卫星已发射。
notification-credits-stolen = 资金被窃取。
notification-spy-plane-ready = 侦察机就绪。

actor-mslo =
    .name = 核弹发射井
    .description =
    提供原子弹。
    需要电力才能运作。
    最多只能建造一座。
      特殊能力：原子弹
    .nukepower-name = 原子弹
    .nukepower-description = 向目标位置发射一枚
    毁灭性的原子弹。

actor-gap =
    .name = 裂缝产生器
    .description =
    用黑幕遮蔽敌方的视野。
    需要电力才能运作。

actor-spen =
    .name = 潜艇母港
    .description =
    生产并维修潜艇
    与运输舰。

actor-syrd =
    .name = 造船厂
    .description =
    生产并维修舰船
    与运输舰。

actor-iron =
    .name = 铁幕装置
    .description =
    让一组单位暂时
    变为无敌。
    需要电力才能运作。
    最多只能建造一座。
      特殊能力：无敌
    .grantexternalconditionpower-ironcurtain-name = 无敌
    .grantexternalconditionpower-ironcurtain-description = 让一组单位获得无敌状态
    持续 20 秒。

actor-pdox =
    .name = 超时空传送仪
    .description =
    把一组单位传送到地图
    另一处，效果短暂。
    需要电力才能运作。
    最多只能建造一座。
      特殊能力：超时空传送
    .chronoshiftpower-chronoshift-name = 超时空传送
    .chronoshiftpower-chronoshift-description = 把一组单位传送到地图
    另一处，持续 20 秒。
    .chronoshiftpower-advancedchronoshift-name = 高级超时空传送
    .chronoshiftpower-advancedchronoshift-description = 把一大组单位传送到地图
    另一处，持续 20 秒。

actor-tsla =
    .name = 磁暴线圈
    .description =
    高级基地防御。
    需要电力才能运作。
    可以侦测隐形单位。
      对车辆与步兵强
      对飞行器弱

actor-agun =
    .name = 防空炮
    .description =
    对空基地防御。
    需要电力才能运作。
      对飞行器强
      对地面单位弱

actor-dome =
    .name = 雷达站
    .description =
    提供战场
    总览图。
    需要电力才能运作。

actor-pbox =
    .name = 机枪碉堡
    .description =
    带射击孔的固定防御设施，
    可派驻一名步兵。
    可以侦测隐形单位。
      对步兵与轻装甲强
      对坦克与飞行器弱

actor-hbox =
    .name = 伪装碉堡
    .description =
    带射击孔的伪装固定防御设施，
    可派驻一名步兵。
    可以侦测隐形单位。
      对步兵与轻装甲强
      对坦克与飞行器弱

actor-gun =
    .name = 反坦克炮塔
    .description =
    反装甲基地防御。
    可以侦测隐形单位。
      对车辆强
      对步兵与飞行器弱

actor-ftur =
    .name = 火焰喷射塔
    .description =
    反步兵基地防御。
    可以侦测隐形单位。
      对步兵与轻装甲强
      对坦克与飞行器弱

actor-sam =
    .name = 地对空导弹阵地
    .description =
    对空基地防御。
    需要电力才能运作。
      对飞行器强
      对地面单位弱

actor-atek =
    .name = 科技中心
    .description =
    提供盟军高级科技。
      特殊能力：GPS 卫星
    .gpspower-name = GPS 卫星
    .gpspower-description =
    揭示地图地形并提供战术信息。
    需要电力与雷达处于运作状态。

actor-weap =
    .name = 战车工厂
    .description =
    生产车辆。

actor-fact =
    .name = 建筑工厂
    .description =
    生产建筑。

actor-proc =
    .name = 矿石精炼厂
    .description =
    把矿石与宝石精炼
    成资金。

actor-silo =
    .name = 矿仓
    .description =
    储存多余的已精炼
    矿石与宝石。

actor-hpad =
    .name = 停机坪
    .description =
    生产并为直升机装弹。

actor-afld =
    .name = 战地机场
    .description =
    生产并为飞机装弹。
      特殊能力：侦察机
      特殊能力：伞兵
    .airstrikepower-spyplane-name = 侦察机
    .airstrikepower-spyplane-description = 揭示地图上的一块区域。
    .paratrooperspower-paratroopers-name = 伞兵
    .paratrooperspower-paratroopers-description = 一架獾式运输机把一支步兵小队空投到
    所选位置。
    .airstrikepower-parabombs-name = 伞降炸弹
    .airstrikepower-parabombs-description = 一架獾式运输机把带降落伞的炸弹投到
    所选位置。

actor-afld-ukraine-description =
    生产并为飞机装弹。
      特殊能力：侦察机
      特殊能力：伞兵
      特殊能力：伞降炸弹

actor-powr =
    .name = 发电厂
    .description =
    为其他建筑
    提供电力。

actor-apwr =
    .name = 大型发电厂
    .description =
    提供标准发电厂
    两倍的电力。

actor-stek =
    .name = 科技中心
    .description =
    提供苏联高级科技。

actor-barr =
    .name = 兵营
    .description =
    训练步兵单位。

actor-kenn =
    .name = 狗窝
    .description =
    训练攻击犬。

actor-tent =
    .name = 兵营
    .description =
    训练步兵。

actor-fix =
    .name = 维修平台
    .description =
    花费资金维修车辆。

actor-sbag =
    .name = 沙袋
    .description =
    阻挡步兵与轻型车辆。
       可被坦克碾压。

actor-fenc =
    .name = 铁丝网
    .description =
    阻挡步兵与轻型车辆。
       可被坦克碾压。

actor-brik =
    .name = 混凝土围墙
    .description =
    阻挡单位并拦下敌方火力。

actor-cycl-name = 铁丝网路障
actor-barb-name = 带刺铁丝网
actor-wood-name = 木栅栏
actor-barracks-name = 步兵生产
actor-techcenter-name = 科技中心
actor-anypower-name = 任意发电设施

## vehicles.yaml
actor-v2rl =
    .name = V2火箭发射车
    .description =
    远程火箭炮兵。
      对步兵与建筑强
      对车辆与飞行器弱

actor-1tnk =
    .name = 轻型坦克
    .generic-name = 坦克
    .description =
    快速坦克；适合侦察。
      对轻装甲强
      对步兵、坦克与飞行器弱

actor-2tnk =
    .name = 中型坦克
    .generic-name = 坦克
    .description =
    盟军主战坦克。
      对车辆强
      对步兵与飞行器弱

actor-3tnk =
    .name = 重型坦克
    .generic-name = 坦克
    .description =
    装备双联火炮的苏联主战坦克。
      对车辆强
      对步兵与飞行器弱

actor-4tnk =
    .name = 猛犸坦克
    .generic-name = 坦克
    .description =
    体型庞大、行动缓慢但具备对空能力的坦克。
    可以碾压混凝土墙。
      对车辆、步兵与飞行器强
      对任何单位都不弱

actor-arty =
    .name = 自行火炮
    .description =
    远程火炮。
      对步兵与建筑强
      对车辆与飞行器弱

actor-harv =
    .name = 采矿车
    .generic-name = 采集车
    .description =
    采集矿石与宝石
    以供加工。
      无武装

actor-mcv =
    .name = 移动基地车
    .description =
    展开后成为建造厂。
      无武装

actor-jeep =
    .name = 突击侦察车
    .description =
    快速侦察与反步兵车辆。
    只能搭载一名步兵。
      对步兵强
      对车辆与飞行器弱

actor-apc =
    .name = 装甲运兵车
    .description =
    坚固的步兵运输车。
      对步兵与轻装甲强
      对坦克与飞行器弱

actor-mnly =
    .name = 布雷车
    .description =
    布设地雷以摧毁
    疏于防范的敌方单位。
    可以侦测地雷。
      无武装

actor-truk =
    .name = 补给车
    .description =
    把资金运送给其他玩家。
      无武装

actor-mgg =
    .name = 机动裂缝产生器
    .description =
    重新生成黑幕以遮蔽附近区域。
      无武装

actor-mrj =
    .name = 机动雷达干扰器
    .description =
    干扰附近的敌方雷达站，
    并使来袭导弹偏转。
      无武装

actor-ttnk =
    .name = 磁能坦克
    .generic-name = 坦克
    .description =
    装备磁暴线圈的坦克。
      对步兵、车辆与建筑强
      对飞行器弱

actor-ftrk =
    .name = 防空侦察车
    .description =
    装备防空炮的机动单位。
      对步兵、轻装甲与飞行器强
      对坦克弱

actor-dtrk =
    .name = 自爆卡车
    .description =
    装载已激活的核炸药的卡车，
    装甲极其薄弱。

actor-ctnk =
    .name = 超时空坦克
    .generic-name = 坦克
    .description =
    装备对地导弹。
    可传送到射程内的任意区域。
      对车辆与建筑强
      对步兵与飞行器弱
      特殊能力：可传送

actor-qtnk =
    .name = M.A.D.坦克
    .generic-name = 坦克
    .description =
    对附近的车辆与建筑
    造成震荡伤害。
      对车辆与建筑强
      对步兵与飞行器弱

actor-stnk =
    .name = 相位运兵车
    .description =
    轻装甲步兵运输车，可以
    隐形。装备对地导弹。
      对轻装甲强
      对步兵、坦克与飞行器弱

## Civilian Tech
actor-hosp =
    .name = 市民医院
    .captured-desc = 让步兵获得自我治疗能力。
    .capturable-desc = 占领后为步兵开启自我治疗。

actor-fcom =
    .name = 前哨站
    .captured-desc = 提供可建造区域。
    .capturable-desc = 占领后获得可建造区域。

actor-miss =
    .name = 科技中心
    .captured-desc = 提供视野范围。
    .capturable-desc = 占领后获得视野范围。

actor-bio =
    .name = 生物实验室
    .captured-desc = 提供生物实验室单位的前置条件。
    .capturable-desc = 占领后可生产生物实验室单位。

actor-oilb =
    .name = 油井
    .captured-desc = 提供额外资金。
    .capturable-desc =  占领后获得额外资金。

## misc.yaml
actor-powerproxy-parabombs =
    .name = 伞降炸弹（单次使用）
    .description =
    一架獾式运输机把带降落伞的炸弹
    投到指定位置。

actor-powerproxy-sonarpulse =
    .name = 声呐脉冲
    .description =
    短时间揭示附近所有
    潜艇的位置。

actor-powerproxy-paratroopers =
    .name = 伞兵
    .description =
    一架獾式运输机把一支步兵小队
    空投到地图任意位置。

## ai.yaml
bot-rush-ai =
    .name = 快攻 AI

bot-normal-ai =
    .name = 普通 AI

bot-turtle-ai =
    .name = 龟缩 AI

bot-naval-ai =
    .name = 海军 AI

## map-generators.yaml
label-random-map = 随机地图
label-clear-map-generator-option-tile = 地块
label-clear-map-generator-choice-tile-clear =
   .label = 空地
label-clear-map-generator-choice-tile-water =
   .label = 水域
label-clear-map-generator-choice-tile-empty =
   .label = 空白区域

label-ra-map-generator-option-seed = 随机种子

label-ra-map-generator-option-terrain-type = 地形类型
label-ra-map-generator-choice-terrain-type-lakes =
   .label = 湖泊
   .description = 开阔地形，分布中等大小的湖泊
label-ra-map-generator-choice-terrain-type-puddles =
   .label = 水塘
   .description = 开阔地形，分布小水塘
label-ra-map-generator-choice-terrain-type-gardens =
   .label = 庭园
   .description = 密集地形，含水塘、断崖与森林
label-ra-map-generator-choice-terrain-type-plots =
   .label = 田块
   .description = 稀疏地形，含水塘、断崖与森林
label-ra-map-generator-choice-terrain-type-plains =
   .label = 平原
   .description = 开阔地形，分布稀疏的树木与断崖
label-ra-map-generator-choice-terrain-type-parks =
   .label = 公园
   .description = 开阔地形，有轻度森林与偶尔的断崖
label-ra-map-generator-choice-terrain-type-woodlands =
   .label = 林地
   .description = 中等密度的森林，偶有断崖
label-ra-map-generator-choice-terrain-type-overgrown =
   .label = 荒野
   .description = 狭窄通道，密集森林与中等数量的断崖
label-ra-map-generator-choice-terrain-type-rocky =
   .label = 岩石
   .description = 中等数量的断崖与轻度森林
label-ra-map-generator-choice-terrain-type-mountains =
   .label = 山脉
   .description = 大量长断崖
label-ra-map-generator-choice-terrain-type-mountain-lakes =
   .label = 山中湖
   .description = 湖泊与大量长断崖
label-ra-map-generator-choice-terrain-type-oceanic =
   .label = 群岛
   .description = 被大洋分隔的小岛
label-ra-map-generator-choice-terrain-type-large-islands =
   .label = 大岛
   .description = 被大洋分隔的大岛
label-ra-map-generator-choice-terrain-type-continents =
   .label = 大陆
   .description = 大片陆地与水域
label-ra-map-generator-choice-terrain-type-wetlands =
   .label = 湿地
   .description = 陆地与水域的松散混合
label-ra-map-generator-choice-terrain-type-narrow-wetlands =
   .label = 窄湿地
   .description = 陆地与水域的紧密混合

label-ra-map-generator-option-symmetry = 对称方式
label-ra-map-generator-choice-mirror-none =
   .label = 无
label-ra-map-generator-choice-symmetry-mirror-horizontal =
   .label = 水平镜像
label-ra-map-generator-choice-symmetry-mirror-vertical =
   .label = 垂直镜像
label-ra-map-generator-choice-symmetry-mirror-diagonal-tl =
   .label = 对角镜像（左上）
label-ra-map-generator-choice-symmetry-mirror-diagonal-tr =
   .label = 对角镜像（右上）
label-ra-map-generator-choice-symmetry-mirror-2-rotations =
   .label = 旋转 2 次
label-ra-map-generator-choice-symmetry-mirror-3-rotations =
   .label = 旋转 3 次
label-ra-map-generator-choice-symmetry-mirror-4-rotations =
   .label = 旋转 4 次
label-ra-map-generator-choice-symmetry-mirror-5-rotations =
   .label = 旋转 5 次
label-ra-map-generator-choice-symmetry-mirror-6-rotations =
   .label = 旋转 6 次
label-ra-map-generator-choice-symmetry-mirror-7-rotations =
   .label = 旋转 7 次
label-ra-map-generator-choice-symmetry-mirror-8-rotations =
   .label = 旋转 8 次

label-ra-map-generator-option-shape = 边界形状
label-ra-map-generator-choice-shape-square =
   .label = 矩形
   .description = 可玩区域即整张地图
label-ra-map-generator-choice-shape-circle-mountain =
   .label = 群山环绕的圆
   .description = 可玩区域位于环形山脉之内
label-ra-map-generator-choice-shape-circle-water =
   .label = 环水的圆
   .description = 可玩区域是一座圆形岛屿

label-ra-map-generator-option-players = 玩家数

label-ra-map-generator-option-resources = 资源
label-ra-map-generator-choice-resources-none =
   .label = 无
label-ra-map-generator-choice-resources-low =
   .label = 低
label-ra-map-generator-choice-resources-medium =
   .label = 中
label-ra-map-generator-choice-resources-high =
   .label = 高
label-ra-map-generator-choice-resources-very-high =
   .label = 极高
label-ra-map-generator-choice-resources-full =
   .label = 满矿

label-ra-map-generator-option-buildings = 科技建筑
label-ra-map-generator-choice-buildings-none =
   .label = 无
   .description = 没有科技建筑
label-ra-map-generator-choice-buildings-standard =
   .label = 标准
   .description = 石油钻井、医院与通讯中心
label-ra-map-generator-choice-buildings-extra =
   .label = 额外
   .description = 石油钻井、医院、通讯中心、前线指挥所
label-ra-map-generator-choice-buildings-oil-only =
   .label = 仅石油
   .description = 只有石油钻井
label-ra-map-generator-choice-buildings-oil-rush =
   .label = 石油争夺
   .description = 大量石油钻井

label-ra-map-generator-option-density = 扩张机会
label-ra-map-generator-choice-density-players =
   .label = 随玩家数缩放
label-ra-map-generator-choice-density-area-and-players =
   .label = 随地图尺寸与玩家数缩放
label-ra-map-generator-choice-density-area-very-low =
   .label = 极低
label-ra-map-generator-choice-density-area-low =
   .label = 低
label-ra-map-generator-choice-density-area-medium =
   .label = 中
label-ra-map-generator-choice-density-area-high =
   .label = 高
label-ra-map-generator-choice-density-area-very-high =
   .label = 极高

label-ra-map-generator-option-roads = 道路
label-ra-map-generator-option-deny-walled-areas = 封锁围墙区域

label-ra-map-generator-option-civilian-density = 民用建筑密度
label-ra-map-generator-choice-civilian-density-default =
   .label = 默认
label-ra-map-generator-choice-civilian-density-none =
   .label = 无
label-ra-map-generator-choice-civilian-density-low =
   .label = 低
label-ra-map-generator-choice-civilian-density-medium =
   .label = 中
label-ra-map-generator-choice-civilian-density-high =
   .label = 高
label-ra-map-generator-choice-civilian-density-very-high =
   .label = 极高
label-ra-map-generator-choice-civilian-density-max =
   .label = 最大
