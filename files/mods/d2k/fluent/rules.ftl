## OpenRA 简体中文汉化补丁 (SPDX-License-Identifier: GPL-3.0-or-later)
## 中文译文:OpenRA_simplified_chinese 项目贡献;原始英文文案版权归 OpenRA 项目 (GPL-3.0) 所有。
## player.yaml
options-tech-level =
    .low = 低
    .medium = 中
    .no-powers = 无超级武器
    .unrestricted = 不限制

checkbox-automatic-concrete =
    .label = 自动铺设混凝土
    .description = 建筑下方会自动铺设混凝土地基

notification-insufficient-funds = 资金不足。
notification-new-construction-options = 有新的建造项目。
notification-cannot-deploy-here = 无法在此展开。
notification-low-power = 电力不足。
notification-base-under-attack = 基地遭受攻击。
notification-ally-under-attack = 我方盟友遭受攻击。
notification-harvester-under-attack = 采集车遭受攻击。
notification-silos-needed = 需要香料仓。
notification-no-room-for-new-unit = 没有空间容纳新单位。
notification-cannot-build-here = 无法在此建造。
notification-one-of-our-buildings-has-been-captured = 我们的一座建筑被占领。

## world.yaml
notification-game-saved = 游戏已保存。

dropdown-map-worms =
    .label = 沙虫
    .description = 沙虫在战场上游荡，会吞噬毫无防备的部队

options-starting-units =
    .mcv-only = 仅移动建造车
    .light-support = 轻型支援
    .heavy-support = 重型支援
    .carryall = 移动建造车 + 搬运机

resource-spice = 香料

faction-random =
    .name = 任意
    .description = 随机家族
    游戏开始时随机选择一个家族

faction-atreides =
    .name = 阿特雷德斯
    .description = 阿特雷德斯家族
    高贵的阿特雷德斯家族来自水行星卡拉丹，
    依靠他们的扑翼机来确保制空权。
    他们与弗雷曼人结盟——那是沙丘上令人畏惧的
    土著战士，能在战斗中悄然潜行而不会被发现。

    家族特性：
        - 主战坦克在速度与耐久之间较为均衡

    特殊单位：
        - 掷弹兵
        - 弗雷曼战士
        - 音波坦克

    超级武器：
        - 空袭

faction-harkonnen =
    .name = 哈克南
    .description = 哈克南家族
    邪恶的哈克南家族为夺取香料控制权不择手段。
    他们依靠蛮力与原子武器来达成目标：
    财富，以及摧毁阿特雷德斯家族。

    家族特性：
        - 主战坦克更耐久，但移动速度更慢

    特殊单位：
        - 萨杜卡
        - 毁灭者

    超级武器：
        - 死亡之手导弹

faction-ordos =
    .name = 奥多斯
    .description = 奥多斯家族
    来自冰封星球西格玛·德拉科尼斯四号星的奥多斯家族阴险狡诈，
    以财富、贪婪与背信弃义著称。他们常常借助雇佣兵、破坏活动
    以及被禁的伊克斯科技来取得优势。

    家族特性：
        - 三轮摩托被突袭三轮摩托取代
        - 主战坦克更快，但耐久更低

    特殊单位：
        - 突袭三轮摩托
        - 隐形突袭三轮摩托
        - 破坏者
        - 变节者

faction-corrino =
    .name = 科里诺

faction-mercenaries =
    .name = 雇佣兵

faction-smugglers =
    .name = 走私者

faction-fremen =
    .name = 弗雷曼

map-generator-d2k = 地图生成器
map-generator-clear = 清除地形

## defaults.yaml
notification-unit-lost = 单位损失。
notification-unit-promoted = 单位晋升。
notification-enemy-building-captured = 敌方建筑已被占领。
notification-primary-building-selected = 已选定主建筑。

## aircraft.yaml
actor-carryall-reinforce =
    .name = 搬运机
    .description =
    大型有翼的行星内运输舰
    自动往返香料田吊运采集车。
    接到命令时可将车辆吊运至维修台。

actor-carryall-encyclopedia =
    在香料田与精炼厂之间自动运输采集车。接到命令时也可以吊起其他单位并将其送到维修台。

    搬运机是装甲较薄的运输飞行器。它容易被导弹击中，且只能被防空武器攻击。

actor-frigate-name = 护卫舰

actor-ornithopter =
    .name = 扑翼机
    .encyclopedia =
    沙丘上飞得最快的飞行器，装甲较薄，可投掷 500 磅炸弹。对步兵和轻装甲目标极为有效，也能对其他装甲类型造成伤害。

actor-ornithopter-husk-name = 扑翼机
actor-carryall-husk-name = 搬运机
actor-carryall-huskvtol-name = 搬运机

## arrakis.yaml
notification-worm-attack = 沙虫袭击。
notification-worm-sign = 发现沙虫迹象。

actor-spicebloom-spawnpoint-name = 香料花刷新点
actor-spicebloom-name = 香料花
actor-sandworm-name = 沙虫
actor-sietch-name = 弗雷曼穴地

## defaults.yaml
meta-vehicle-generic-name = 单位
meta-husk-generic-name = 被摧毁的单位
meta-aircrafthusk-generic-name = 单位
meta-infantry-generic-name = 单位
meta-plane-generic-name = 单位
meta-building-generic-name = 建筑

## husks.yaml
actor-mcv-husk-name = 移动建造车（已摧毁）
actor-harvester-husk-name = 香料采集车（已摧毁）
actor-siege-tank-husk-name = 攻城坦克（已摧毁）
actor-missile-tank-husk-name = 导弹坦克（已摧毁）
actor-sonic-tank-husk-name = 音波坦克（已摧毁）
actor-devastator-husk-name = 毁灭者（已摧毁）
actor-deviator-husk-name = 变节者（已摧毁）
meta-combat-tank-husk-name = 主战坦克（已摧毁）

## infantry.yaml
actor-light-inf =
    .name = 轻步兵
    .description =
    通用步兵。
      对步兵强
      对车辆与火炮弱
    .encyclopedia =
    装甲较薄的步兵，装备 9 毫米 RP 突击步枪。对步兵和轻装甲车辆有效。

    轻步兵对导弹和大口径火炮有一定抗性，但极易被高爆弹、火焰和轻武器杀伤。

    概要：

        - 爆炸半径：小
        - 视野：极小
        - 对轻步兵、反坦克兵、导弹坦克、变节者强
        - 对主战坦克、攻城坦克、掷弹兵、三轮摩托、音波坦克弱

actor-engineer =
    .name = 工程师
    .description =
    渗透并占领敌方
    建筑。
      对建筑强
      对一切弱
      可修复受损的悬崖
    .encyclopedia =
    可用于占领敌方建筑。

    工程师对反坦克武器有一定抗性，但极易被高爆弹、火焰和轻武器杀伤。

    工程师可以让被摧毁的残骸恢复到勉强可用的状态，从而把残骸开到最近的维修台进行全面维修。

actor-trooper =
    .name = 反坦克兵
    .description =
    反坦克步兵。
      对坦克强
      对步兵与火炮弱
    .encyclopedia =
    装备有线制导的穿甲导弹战斗部，反坦克兵对车辆和建筑非常有效，但对付步兵较为吃力。

    反坦克兵对反坦克武器有一定抗性，但极易被高爆弹、火焰和子弹武器杀伤。

    概要：

        - 爆炸半径：中
        - 视野：小
        - 对主战坦克、导弹坦克、四轮导弹车、三轮摩托、变节者、建筑、防御设施强
        - 对攻城坦克、轻步兵、掷弹兵、音波坦克弱

actor-thumper =
    .name = 震地兵
    .description =
    展开后会吸引附近的沙虫。
      无武装
    .encyclopedia =
    展开一个发出巨大敲击声的装置，把沙虫吸引到该区域。

actor-fremen =
    .name = 弗雷曼战士
    .description =
    装备突击步枪与火箭的精英步兵。
      对步兵与车辆强
      对火炮弱
      特殊能力：隐形
    .encyclopedia =
    沙丘的土著沙漠战士，装备 10 毫米突击步枪与火箭。其火力对步兵和车辆同样有效。

    弗雷曼单位极易被高爆武器和子弹武器杀伤。

    概要：

        - 爆炸半径：中
        - 视野：小
        - 对四轮导弹车、三轮摩托、导弹坦克、主战坦克、毁灭者、建筑、防御设施强
        - 对攻城坦克、轻步兵、掷弹兵、音波坦克弱

actor-grenadier =
    .name = 掷弹兵
    .description =
    装备手榴弹的步兵。
      对建筑与步兵强
      对车辆弱
    .encyclopedia =
    对建筑强力的步兵炮兵单位。阵亡时有几率发生爆炸，因此不应集中编队。

    概要：

        - 爆炸半径：大
        - 视野：小
        - 对轻步兵、三轮摩托、导弹坦克、主战坦克、建筑、防御设施强
        - 对攻城坦克、主战坦克、音波坦克、毁灭者弱

actor-sardaukar =
    .name = 萨杜卡
    .description =
    科里诺精英突击步兵。
      对步兵与车辆强
      对火炮弱
    .encyclopedia =
    强大的重型步兵，装备对付步兵有效的机枪和攻击车辆的火箭发射器。被碾压时会发生爆炸并伤害上方的车辆。

    概要：

        - 爆炸半径：大
        - 视野：小
        - 对三轮摩托、四轮导弹车、导弹坦克、主战坦克、建筑、防御设施强
        - 对攻城坦克、音波坦克、掷弹兵、坦克碾压弱

actor-mpsardaukar-description =
    哈克南精英突击步兵。
      对步兵与车辆强
      对火炮弱

actor-saboteur =
    .name = 破坏者
    .description =
    携带炸药的潜行步兵。
    可在限定时间内变为隐形。
      对建筑强
      对一切弱
      特殊能力：摧毁建筑
    .encyclopedia =
    奥多斯家族的特种军事单位，进入敌方建筑或车辆后可将其炸毁，但自己也会在爆炸中阵亡。它可以启动自毁，伤害附近的敌方单位。

    破坏者对反坦克武器有一定抗性，但极易被高爆弹、火焰和子弹武器杀伤。

actor-nsfremen-description =
    装备突击步枪与火箭的精英步兵。
      对步兵与车辆强
      对火炮弱

## misc.yaml
actor-crate-name = 补给箱
actor-mpspawn-name = （多人游戏出生点）
actor-waypoint-name = （脚本行为路径点）
actor-camera-name = （向拥有者揭示区域）
actor-wormspawner-name = （沙虫生成点）

actor-upgrade-conyard =
    .name = 建造厂升级
    .description =
    解锁更多建造项目：
    - 大型混凝土板
    - 火箭炮塔

actor-upgrade-barracks =
    .name = 兵营升级
    .description =
    解锁更多步兵：
    - 反坦克兵
    - 工程师
    - 震地兵

    解锁家族专属步兵所需：
    - 阿特雷德斯：掷弹兵
    - 哈克南：萨杜卡

actor-upgrade-light =
    .name = 轻型工厂升级
    .description =
    解锁更多轻型单位：
    - 四轮导弹车

    解锁家族专属轻型单位所需：
    - 奥多斯：隐形突袭三轮摩托

actor-upgrade-heavy =
    .name = 重型工厂升级
    .description =
    解锁更多建造项目：
    - 维修台
    - 伊克斯研究中心

    解锁更多重型单位：
    - 攻城坦克
    - 导弹坦克
    - 移动建造车

actor-upgrade-hightech =
    .name = 高科技工厂升级
    .description =
    解锁阿特雷德斯的空袭超级武器。

actor-deathhand =
    .name = 死亡之手
    .encyclopedia =
    装备原子集束弹头，在目标上方引爆，对大片区域造成巨大伤害。

## structures.yaml
notification-construction-complete = 建造完成。
notification-unit-ready = 单位就绪。
notification-repairing = 正在维修。
notification-unit-repaired = 单位维修完成。
notification-select-target = 选择目标。
notification-missile-launch-detected = 侦测到导弹发射。
notification-airstrike-ready = 空袭就绪。
notification-building-lost = 建筑损失。
notification-reinforcements-have-arrived = 增援已抵达。
notification-death-hand-missile-prepping = 死亡之手导弹准备中。
notification-death-hand-missile-ready = 死亡之手导弹就绪。
notification-fremen-ready = 弗雷曼战士就绪。
notification-saboteur-ready = 破坏者就绪。

meta-concrete =
    .generic-name = 建筑
    .description =
    提供坚固的地基，
    可防止地形造成的损害。

actor-concrete-a =
    .name = 混凝土板
    .encyclopedia =
    未建在混凝土板上的建筑会持续受到沙丘严酷环境的侵蚀。虽然可以维修，但把建筑建在混凝土上才能避免持续风化。

    混凝土对大多数武器都很脆弱，且一旦受损就无法修复。

actor-concrete-b-name = 大型混凝土板

actor-construction-yard =
    .name = 建造厂
    .description = 生产建筑。
    .encyclopedia =
    作为阿拉基斯上任何基地的根基，建造厂能提供少量电力，并使新建建筑成为可能。请保护这座建筑！它对你基地的成败至关重要。

    建造厂相当坚固，但会不同程度地受到所有武器的伤害。

actor-wind-trap =
    .name = 风阱
    .description =
    为其他建筑
    提供电力。
    .encyclopedia =
    为你的基地提供电力与水。巨大的地上管道把气流导入地下的巨型涡轮机，驱动发电机与湿度提取器。

    风阱对大多数武器都很脆弱。

actor-barracks =
    .name = 兵营
    .description = 训练步兵。
    .encyclopedia =
    生产与训练轻步兵单位所需，可在后续任务中升级以训练高级步兵。

    兵营对大多数武器都很脆弱。

actor-refinery =
    .name = 香料精炼厂
    .description =
    采集车在这里卸下香料
    进行加工。
    .encyclopedia =
    沙丘上一切香料生产的基础。采集车把开采的香料运到精炼厂，转化为信用点。精炼后的香料会自动分配到香料仓与精炼厂储存。每座精炼厂都能储存香料。建成精炼厂后，搬运机会送来一辆香料采集车。

    精炼厂对大多数武器都很脆弱。

actor-silo =
    .name = 香料仓
    .description = 储存多余的香料。
    .encyclopedia =
    储存开采的香料。精炼厂溢出的香料会平均分配到所有可用的香料仓。若超出储存容量，多余的香料就会损失。香料仓被摧毁或被占领时，其内容物会重新分配，前提是有足够的空间。

    香料仓对大多数武器都很脆弱。

actor-light-factory =
    .name = 轻型工厂
    .description = 生产轻型车辆。
    .encyclopedia =
    生产小型轻装甲战斗车辆所需。可在后续任务中升级以制造更先进的轻型车辆。

    轻型工厂对大多数武器都很脆弱。

actor-heavy-factory =
    .name = 重型工厂
    .description = 生产重型车辆。
    .encyclopedia =
    使采集车与主战坦克这类重型车辆得以建造。经过升级后可解锁高级车辆，其中一些可能还需要其他建筑。

    重型工厂对大多数武器都很脆弱。

actor-outpost =
    .name = 前哨站
    .description =
    提供战场雷达地图。
    需要电力才能运作。
    可侦测隐形单位。
    .encyclopedia =
    只要有足够的电力，雷达前哨站就会启动，提供雷达地图。

    雷达前哨站对大多数武器都很脆弱。

actor-starport =
    .name = 星港
    .description = 快速增援的投放点，但要付出代价。
    .encyclopedia =
    解锁与 CHOAM 商会之间的星际贸易，可以用浮动价格购买车辆与飞行器单位。这座设施是从商会获取单位的关键。

    即便装甲厚重，星港对大多数武器也很脆弱。

actor-wall =
    .name = 混凝土墙
    .generic-name = 建筑
    .description = 阻挡单位并拦下敌方火力。
    .encyclopedia =
    沙丘上最有效的防御屏障，能挡下坦克炮火并阻碍单位移动。

    墙只能被爆炸性武器、导弹和炮弹破坏。与混凝土板类似，一旦受损就无法修复。

actor-medium-gun-turret =
    .name = 炮塔
    .description =
    防御建筑。可侦测隐形单位。
      对轻型车辆强
      对步兵中
      对坦克与飞行器弱
    .encyclopedia =
    中程武器，对各种车辆都有效，对重装甲车辆尤为有效。它会自动向射程内的任何敌方单位开火，运作需要电力。

    炮塔对小口径武器和爆炸性武器有一定抗性，但易被导弹和重型炸药破坏。

actor-large-gun-turret =
    .name = 火箭炮塔
    .description =
    防御建筑。可侦测隐形单位。
    需要电力才能运作。
      对坦克、飞行器、移动目标强
      对步兵弱
    .encyclopedia =
    经过强化的防御建筑，射程比炮塔更远、射速更快。其先进的瞄准系统需要电力才能运作。

    火箭炮塔对枪械和爆炸性武器有一定抗性，但易被导弹和大口径火炮破坏。

actor-repair-pad =
    .name = 维修台
    .description =
    维修车辆。
    使移动建造车可以建造。
    .encyclopedia =
    以生产成本的一小部分为代价维修单位。

    维修台对大多数武器都很脆弱。

actor-high-tech-factory =
    .name = 高科技工厂
    .description = 解锁先进科技。
    .airstrikepower-name = 空袭
    .airstrikepower-description = 扑翼机轰炸目标。
    .encyclopedia =
    生产飞行器单位，也是建造搬运机的前提。阿特雷德斯家族可以在后续任务中升级该设施，建造扑翼机以发动空袭。

    高科技工厂对大多数武器都很脆弱。

actor-research-centre =
    .name = 伊克斯研究中心
    .description = 解锁高级坦克。
    .encyclopedia =
    为建筑与车辆提供科技升级。研发高级特殊武器与原型机都需要这座设施。

    伊克斯研究中心对大多数武器都很脆弱。

actor-palace =
    .name = 宫殿
    .description = 解锁精英步兵与武器。
    .encyclopedia =
    建成后作为指挥中心，提供额外的选项与特殊武器。

    即便装甲厚重，宫殿对大多数武器也很脆弱。
    .nukepower-name = 死亡之手
    .nukepower-description = 向目标位置发射一枚原子导弹。
    .produceactorpower-fremen-name = 招募弗雷曼战士
    .produceactorpower-fremen-description = 装备突击步枪与火箭的精英步兵。
      对步兵与车辆强
      对火炮弱
      特殊能力：隐形
    .produceactorpower-saboteur-name = 招募破坏者
    .produceactorpower-saboteur-description = 携带炸药的潜行步兵。
    展开后可在限定时间内变为隐形。
      对建筑强
      对一切弱
      特殊能力：摧毁建筑

## vehicles.yaml
actor-mcv =
    .name = 移动建造车
    .description =
    展开后成为建造厂。
      无武装
    .encyclopedia =
    必须开到可以展开的区域。找到合适的岩石地面后，移动建造车就能变形成建造厂。

    移动建造车对子弹和轻型爆炸物有一定抗性。它易被导弹和大口径火炮破坏。

actor-harvester =
    .name = 香料采集车
    .description =
    采集香料以供加工。
      无武装
    .encyclopedia =
    对子弹以及一定程度上的高爆物有抗性。它易被导弹和大口径火炮破坏。

    建成精炼厂时会附带一辆采集车。

actor-trike =
    .name = 三轮摩托
    .description =
    快速侦察车。
      对步兵强
      对坦克弱
    .encyclopedia =
    轻装甲三轮车辆，装备重机枪，对步兵和轻装甲车辆有效。

    三轮摩托易被大多数武器破坏，但大口径火炮对它的效果略差。

    概要：

        - 爆炸半径：小
        - 视野：中
        - 对轻步兵、反坦克兵、导弹坦克、变节者强
        - 对主战坦克、攻城坦克、掷弹兵、萨杜卡弱

    提示：三轮摩托对轻步兵有 0.5 格射程优势。一旦轻步兵靠得太近，就立刻把它后撤。

actor-quad =
    .name = 四轮导弹车
    .description =
    导弹侦察车。
      对车辆强
      对步兵弱
    .encyclopedia =
    在装甲和火力上都优于三轮摩托，四轮导弹车是一种发射穿甲火箭的四轮车辆。它对大多数车辆都有效。

    四轮导弹车对子弹以及一定程度上的爆炸物有抗性。它易被导弹和大口径火炮破坏。

    概要：

        - 爆炸半径：中
        - 视野：中
        - 对攻城坦克、音波坦克、建筑强
        - 对主战坦克、反坦克兵、导弹坦克弱

    提示：四轮导弹车对移动目标精度很差。尽量靠近目标以获得最大伤害。

actor-siege-tank =
    .name = 攻城坦克
    .description =
    攻城炮兵。
      对步兵与建筑强
      对坦克弱
    .encyclopedia =
    对步兵和轻装甲车辆极其有效，但对付重装甲目标较为吃力。它拥有很长的射程。

    攻城坦克对子弹以及一定程度上的爆炸物有抗性。它易被导弹和大口径火炮破坏。

    装载大量高爆弹药，是车辆被摧毁后发生剧烈爆炸的原因

    概要：

        - 爆炸半径：大
        - 视野：大
        - 对任何步兵、三轮摩托、变节者强
        - 对主战坦克、四轮导弹车、导弹坦克弱

    提示：攻城坦克可以打到视野范围之外。

actor-missile-tank =
    .name = 导弹坦克
    .description =
    火箭炮兵。
      对车辆、建筑与飞行器强
      对步兵弱
    .encyclopedia =
    能击落飞行器，对除步兵以外的大多数目标都有效。

    导弹坦克易被大多数武器破坏，大口径火炮对它的效果略差。

    概要：

        - 爆炸半径：中
        - 视野：大
        - 对主战坦克、毁灭者、四轮导弹车强
        - 对任何类型的步兵、三轮摩托、隐形突袭三轮摩托弱

    提示：导弹坦克可以打到视野范围之外。


actor-sonic-tank =
    .name = 音波坦克
    .description =
    发射音波震荡。
      对步兵与车辆强
      对火炮弱
    .encyclopedia =
    对步兵和轻装甲车辆最有效，但对装甲目标较弱。

    它的音波会伤害行进路径上的所有单位。

    对子弹和小型爆炸物有抗性，但易被导弹和大口径火炮破坏。

    概要：

        - 爆炸半径：极大
        - 视野：中
        - 对任何步兵、攻城坦克、导弹坦克、变节者强
        - 对主战坦克、四轮导弹车、毁灭者弱

    提示：音波强度随距离增加。尽量在最大射程上开火以获得最大伤害。

actor-devastator =
    .name = 毁灭者
    .description =
    超重型坦克。
      对坦克强
      对火炮弱
    .encyclopedia =
    作为沙丘上最强大的坦克，毁灭者虽慢，但对大多数单位都极其有效。它发射双重等离子弹，并能按命令自毁，伤害附近的单位与建筑。

    对子弹和高爆物有抗性，但易被导弹和大口径火炮破坏。

    概要：

        - 爆炸半径：大
        - 视野：中
        - 对主战坦克、攻城坦克、轻步兵、音波坦克强
        - 对反坦克兵、导弹坦克、变节者弱

    提示：毁灭者面对大批反坦克兵时很脆弱。改用自毁吧。

actor-raider =
    .name = 突袭三轮摩托
    .description =
    改进型侦察车。
      对步兵与轻型车辆强
      对坦克弱
    .encyclopedia =
    由奥多斯家族升级的突袭三轮摩托拥有更强的火力、速度与装甲。装备双联 20 毫米机炮，对步兵和轻装甲车辆很强。

    突袭三轮摩托易被大多数武器破坏，不过大口径火炮（主战坦克）对它的效果略差。

    概要：

        - 爆炸半径：小
        - 视野：小
        - 对轻步兵、反坦克兵、导弹坦克、变节者、三轮摩托强
        - 对主战坦克、攻城坦克、掷弹兵、萨杜卡、四轮导弹车弱

actor-stealth-raider =
    .name = 隐形突袭三轮摩托
    .description =
    隐形的突袭三轮摩托。
      对步兵与轻型车辆强
      对坦克弱
    .encyclopedia =
    突袭三轮摩托的隐形版本，适合发动潜袭。它开火时会解除隐形。

    概要：

        - 爆炸半径：小
        - 视野：小
        - 对轻步兵、反坦克兵、导弹坦克、变节者、三轮摩托强
        - 对主战坦克、攻城坦克、掷弹兵、萨杜卡弱

    提示：攻城坦克和导弹坦克可以打到视野范围之外。用隐形突袭三轮摩托为它们扩展视野，它们就能在最大射程上开火。

actor-deviator =
    .name = 变节者
    .description =
    发射可使敌方车辆
    改变效忠对象弹头。
    .encyclopedia =
    发射会释放硅雾的导弹，暂时改变被命中车辆的效忠对象。人员受硅雾影响很小。

    变节者易被大多数武器破坏，大口径火炮对它的效果略差。

    概要：

        - 爆炸半径：小
        - 视野：大
        - 对主战坦克、四轮导弹车、毁灭者、导弹坦克强
        - 对任何步兵、导弹坦克、音波坦克、三轮摩托弱

    提示：变节者的装填时间非常长。在编队中让部分变节者保持停火，以便机会出现时随时都有导弹可用。


meta-combat-tank-description =
    主战坦克。
      对坦克强
      对步兵弱

actor-combat-tank-a =
    .name = 阿特雷德斯主战坦克
    .encyclopedia =
    对大多数车辆有效，但对付轻装甲目标略显不足。

    对子弹和重型炸药有抗性，但易被导弹和大口径火炮破坏。阿特雷德斯主战坦克是机动性与装甲之间不错的折中，并且有稍远的射程。

    概要：

        - 爆炸半径：中
        - 视野：中
        - 对主战坦克、攻城坦克、四轮导弹车、音波坦克强
        - 对反坦克兵、导弹坦克、毁灭者、变节者弱

    阿特雷德斯坦克加成：射程更远

actor-combat-tank-h =
    .name = 哈克南主战坦克
    .encyclopedia =
    对大多数车辆有效，但对付轻装甲目标略显不足。

    比同类更强，但也更慢、射速更低。

    概要：

        - 爆炸半径：中
        - 视野：中
        - 对主战坦克、攻城坦克、四轮导弹车、音波坦克强
        - 对反坦克兵、导弹坦克、毁灭者、变节者弱

    哈克南坦克加成：装甲更强

actor-combat-tank-o =
    .name = 奥多斯主战坦克
    .encyclopedia =
    对大多数车辆有效，但对付轻装甲目标略显不足。

    速度最快的主战坦克，但也是最弱的。射速优于同类。

    概要：

        - 爆炸半径：中
        - 视野：中
        - 对主战坦克、攻城坦克、四轮导弹车、音波坦克强
        - 对反坦克兵、导弹坦克、毁灭者、变节者弱

    奥多斯坦克加成：射速

meta-destroyabletile =
    .generic-name = 通路（可破坏）
    .name = 通路（可破坏）

meta-destroyedtile =
    .generic-name = 通路（可修复）
    .name = 通路（可修复）

## ai.yaml
bot-omnius =
    .name = 奥姆纽斯

bot-vidius =
    .name = 维迪乌斯

bot-gladius =
    .name = 格拉迪乌斯

## map-generators.yaml
label-random-map = 随机地图
label-clear-map-generator-option-tile = 地块
label-clear-map-generator-choice-tile-sand =
   .label = 沙地
label-clear-map-generator-choice-tile-concrete =
   .label = 混凝土
label-clear-map-generator-choice-tile-dune =
   .label = 沙丘
label-clear-map-generator-choice-tile-rock =
   .label = 岩石
label-clear-map-generator-choice-tile-platform =
   .label = 平台

label-d2k-map-generator-option-seed = 随机种子
label-d2k-map-generator-option-terrain-type = 地形类型
label-d2k-map-generator-choice-terrain-type-rocky =
   .label = 岩石
label-d2k-map-generator-choice-terrain-type-rough =
   .label = 崎岖
label-d2k-map-generator-choice-terrain-type-flat =
   .label = 平坦
label-d2k-map-generator-choice-terrain-type-pockets =
   .label = 凹地
label-d2k-map-generator-option-players = 玩家数

label-d2k-map-generator-option-symmetry = 对称方式
label-d2k-map-generator-choice-mirror-none =
   .label = 无
label-d2k-map-generator-choice-symmetry-mirror-horizontal =
   .label = 水平镜像
label-d2k-map-generator-choice-symmetry-mirror-vertical =
   .label = 垂直镜像
label-d2k-map-generator-choice-symmetry-mirror-diagonal-tl =
   .label = 对角镜像（左上）
label-d2k-map-generator-choice-symmetry-mirror-diagonal-tr =
   .label = 对角镜像（右上）
label-d2k-map-generator-choice-symmetry-mirror-2-rotations =
   .label = 旋转 2 次
label-d2k-map-generator-choice-symmetry-mirror-3-rotations =
   .label = 旋转 3 次
label-d2k-map-generator-choice-symmetry-mirror-4-rotations =
   .label = 旋转 4 次
label-d2k-map-generator-choice-symmetry-mirror-5-rotations =
   .label = 旋转 5 次
label-d2k-map-generator-choice-symmetry-mirror-6-rotations =
   .label = 旋转 6 次
label-d2k-map-generator-choice-symmetry-mirror-7-rotations =
   .label = 旋转 7 次
label-d2k-map-generator-choice-symmetry-mirror-8-rotations =
   .label = 旋转 8 次

label-d2k-map-generator-option-resources = 资源
label-d2k-map-generator-choice-resources-none =
   .label = 无
label-d2k-map-generator-choice-resources-low =
   .label = 低
label-d2k-map-generator-choice-resources-medium =
   .label = 中
label-d2k-map-generator-choice-resources-high =
   .label = 高
label-d2k-map-generator-choice-resources-very-high =
   .label = 极高
label-d2k-map-generator-choice-resources-full =
   .label = 全满

label-d2k-map-generator-option-worms = 沙虫
label-d2k-map-generator-choice-worms-none =
   .label = 无
label-d2k-map-generator-choice-worms-low =
   .label = 低
label-d2k-map-generator-choice-worms-medium =
   .label = 中
label-d2k-map-generator-choice-worms-high =
   .label = 高

label-d2k-map-generator-option-density = 密度
label-d2k-map-generator-choice-density-players =
   .label = 随玩家数缩放
label-d2k-map-generator-choice-density-area-and-players =
   .label = 随地图尺寸与玩家数缩放
label-d2k-map-generator-choice-density-area-very-low =
   .label = 极低
label-d2k-map-generator-choice-density-area-low =
   .label = 低
label-d2k-map-generator-choice-density-area-medium =
   .label = 中
label-d2k-map-generator-choice-density-area-high =
   .label = 高
label-d2k-map-generator-choice-density-area-very-high =
   .label = 极高
