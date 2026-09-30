## OpenRA 简体中文汉化补丁 (SPDX-License-Identifier: GPL-3.0-or-later)
## 中文译文:OpenRA_simplified_chinese 项目贡献;原始英文文案版权归 OpenRA 项目 (GPL-3.0) 所有。
## Buttons
button-cancel = 取消
button-retry = 重试
button-back = 返回
button-continue = 继续
button-quit = 退出

## Server Orders
notification-custom-rules = 该地图包含自定义规则,游戏体验可能发生变化。
notification-two-humans-required = 此服务器需要至少两名真人玩家才能开始对局。
notification-unknown-server-command = 未知的服务器命令:{ $command }。
notification-admin-start-game = 只有房主可以开始游戏。
notification-no-start-until-required-slots-full = 必需位置坐满后才能开始游戏。
notification-no-start-without-players = 没有玩家无法开始游戏。
notification-insufficient-enabled-spawn-points = 需要启用更多出生点才能开始游戏。
notification-malformed-command = { $command } 命令格式有误。
notification-state-unchanged-ready = 已标记准备就绪时无法更改状态。
notification-invalid-faction-selected = 选择了无效的阵营:{ $faction }。
notification-state-unchanged-game-started = 游戏开始后状态无法更改({ $command })。
notification-requires-host = 只有房主可以执行该操作。
notification-invalid-bot-slot = 无法向已有其他客户端的位置添加电脑玩家。
notification-invalid-bot-type = 无效的电脑玩家类型。
notification-admin-change-map = 只有房主可以更换地图。
notification-player-disconnected = { $player } 已断开连接。
notification-team-player-disconnected = { $player }(队伍 { $team })已断开连接。
notification-observer-disconnected = { $player }(观战者)已断开连接。
notification-unknown-map = 服务器上未找到该地图。
notification-searching-map = 正在资源中心搜索地图...
notification-admin-change-configuration = 只有房主可以更改设置。
notification-changed-map = { $player } 将地图更换为 { $map }。
notification-you-were-kicked = 你已被踢出服务器。
notification-admin-kicked = { $admin } 将 { $player } 踢出了服务器。
notification-kicked = { $player } 已被踢出服务器。
notification-temp-ban = { $admin } 将 { $player } 临时封禁。
notification-admin-transfer-admin = 只有管理员可以将管理权转给其他玩家。
notification-admin-move-spectators = 只有房主可以将玩家移入观战席。
notification-empty-slot = 该位置无人。
notification-move-spectators = { $admin } 将 { $player } 移入了观战席。
notification-nick-changed = { $player } 现在改名为 { $name }。
notification-player-dropped = 一名玩家因超时被断开。
notification-connection-problems = { $player } 的网络连接出现问题。
notification-timeout-dropped = { $player } 因超时被断开。
notification-timeout-dropped-in =
    { $timeout ->
        [one] { $player } 将在 { $timeout } 秒后被断开。
       *[other] { $player } 将在 { $timeout } 秒后被断开。
    }
notification-error-game-started = 游戏已经开始。
notification-requires-password = 服务器需要密码。
notification-incorrect-password = 密码错误。
notification-incompatible-mod = 服务器运行的是不兼容的模组。
notification-incompatible-version = 服务器运行的是不兼容的版本。
notification-incompatible-protocol = 服务器运行的是不兼容的协议。
notification-you-were-banned = 你已被该服务器封禁。
notification-you-were-temp-banned = 你已被该服务器临时封禁。
notification-game-full = 游戏人数已满。
notification-new-admin = { $player } 现在是管理员。
notification-invalid-configuration-command = 无效的设置命令。
notification-admin-option = 只有房主可以设置该选项。
notification-error-number-teams = 无法解析队伍数量:{ $raw }。
notification-admin-kick = 只有房主可以踢出玩家。
notification-kick-self = 房主不能踢出自己。
notification-kick-none = 该位置无人。
notification-no-kick-game-started = 游戏开始后只能踢出观战者和已被击败的玩家。
notification-admin-clear-spawn = 只有管理员可以清空出生点。
notification-spawn-occupied = 你不能与其他玩家占据同一出生点。
notification-spawn-locked = 该出生点已锁定给另一个玩家位置。
notification-admin-lobby-info = 只有房主可以设置房间信息。
notification-invalid-lobby-info = 收到的房间信息无效。
notification-player-color-terrain = 已调整颜色,使其与地形区分更明显。
notification-player-color-player = 已调整颜色,使其与其他玩家区分更明显。
notification-invalid-player-color = 无法确定有效的玩家颜色,已随机选择。
notification-invalid-error-code = 解析错误信息失败。
notification-master-server-connected = 已与主服务器建立通信。
notification-master-server-error = 与主服务器通信失败。
notification-game-offline = 游戏尚未在线发布。
notification-no-port-forward = 服务器端口无法从互联网访问。
notification-blacklisted-server-name = 服务器名称包含被屏蔽的词。
notification-requires-authentication = 该服务器要求玩家拥有 OpenRA 论坛账号。
notification-no-permission-to-join = 你没有加入此服务器的权限。
notification-slot-closed = 你的位置已被房主关闭。

## ServerOrders, UnitOrders
notification-joined = { $player } 已加入游戏。
notification-lobby-disconnected = { $player } 已离开。

## UnitOrders
notification-game-has-started = 游戏已开始。
notification-game-paused = 游戏已被 { $player } 暂停。
notification-game-unpaused = 游戏已被 { $player } 继续。

## Server
notification-game-started = 游戏开始。

## PlayerMessageTracker
notification-chat-temp-disabled =
    { $remaining ->
        [one] 聊天功能已禁用。请于 { $remaining } 秒后重试。
       *[other] 聊天功能已禁用。请于 { $remaining } 秒后重试。
    }

## VoteKickTracker
notification-unable-to-start-a-vote = 无法发起投票。
notification-insufficient-votes-to-kick = 踢出玩家 { $kickee } 的票数不足。
notification-kick-already-voted = 你已经投过票了。
notification-vote-kick-started = 玩家 { $kicker } 发起投票,要求踢出玩家 { $kickee }。
notification-vote-kick-in-progress = { $percentage }% 的玩家已投票要求踢出玩家 { $kickee }。
notification-vote-kick-ended = 踢出玩家 { $kickee } 的投票未通过。

## ActorEditLogic
label-duplicate-actor-id = 单位编号重复
label-actor-id = 请输入单位编号
label-actor-owner = 归属

## ActorSelectorLogic
label-actor-type = 类型:{ $actorType }

## CommonSelectorLogic
options-common-selector =
    .search-results = 搜索结果
    .all = 全部
    .multiple = 多个
    .none = 无

## SaveMapLogic
label-unpacked-map = 未打包

dialog-save-map-failed =
    .title = 保存地图失败
    .prompt = 详情请查看 debug.log。
    .confirm = 确定

dialog-overwrite-map-failed =
    .title = 警告
    .prompt = 保存将覆盖
    一个已存在的地图。
    .confirm = 保存

dialog-overwrite-map-outside-edit =
    .title = 警告
    .prompt = 该地图已在编辑器之外被修改。
    保存可能会覆盖这些改动。
    .confirm = 保存

notification-save-current-map = 已保存当前地图。

## GameInfoLogic
menu-game-info =
    .objectives = 任务目标
    .briefing = 任务简报
    .options = 选项
    .debug = 调试
    .chat = 聊天

## GameInfoObjectivesLogic, GameInfoStatsLogic
label-mission-in-progress = 进行中
label-mission-accomplished = 已完成
label-mission-failed = 已失败

## GameInfoStatsLogic
label-mute-player = 屏蔽该玩家
label-unmute-player = 取消屏蔽该玩家
button-kick-player = 踢出该玩家
button-vote-kick-player = 投票踢出该玩家

dialog-kick =
    .title = 踢出 { $player }?
    .prompt = 该玩家将无法重新加入本局游戏。
    .confirm = 踢出

dialog-vote-kick =
    .title = 投票踢出 { $player }?
    .prompt = 该玩家将无法重新加入本局游戏。
    .prompt-break-bots =
    { $bots ->
        [one] 踢出房主会同时踢出 1 个电脑玩家。
       *[other] 踢出房主会同时踢出 { $bots } 个电脑玩家。
    }
    .vote-start = 发起投票
    .vote-for = 赞成
    .vote-against = 反对
    .vote-cancel = 弃权

notification-vote-kick-disabled = 此服务器已禁用投票踢人。

## GameTimerLogic
label-paused = 已暂停
label-max-speed = 最高速
label-replay-speed = { $percentage }% 速度
label-replay-complete = 已完成 { $percentage }%

## LobbyLogic, InGameChatLogic
label-chat-disabled = 聊天已禁用
label-chat-availability =
    { $seconds ->
        [one] 聊天将在 { $seconds } 秒后可用...
       *[other] 聊天将在 { $seconds } 秒后可用...
    }

## LobbyLogic, ServerListLogic
label-bot-player = 电脑玩家

## LobbyLogic
notification-lobby-option = { $name }:{ $value }。
notification-lobby-option-changed = { $name } 已改为 { $value }。
notification-map-bots-disabled = 此地图已禁用电脑玩家。

## IngameMenuLogic
menu-ingame =
    .leave = 离开
    .abort = 中止任务
    .restart = 重新开始
    .surrender = 投降
    .load-game = 读取存档
    .save-game = 保存游戏
    .music = 音乐
    .settings = 设置
    .return-to-map = 返回地图
    .resume = 继续
    .save-map = 保存地图
    .exit-map = 退出地图编辑器

dialog-leave-mission =
    .title = 离开任务
    .prompt = 离开本局游戏并返回菜单?
    .confirm = 离开
    .cancel = 留下

dialog-restart-mission =
    .title = 重新开始
    .prompt = 确定要重新开始吗?
    .confirm = 重新开始
    .cancel = 留下

dialog-surrender =
    .title = 投降
    .prompt = 确定要投降吗?
    .confirm = 投降
    .cancel = 留下

dialog-error-max-player =
    .title = 错误:超出最大玩家数
    .prompt = 定义的玩家数量过多({ $players }/{ $max })。
    .confirm = 返回

dialog-exit-map-editor =
    .title = 退出地图编辑器
    .prompt-unsaved = 退出将丢失所有未保存的改动?
    .prompt-deleted = 该地图可能已在编辑器之外被删除
    .confirm-anyway = 仍然退出
    .confirm = 退出

dialog-play-map-warning =
    .title = 警告
    .prompt = 该地图可能已被删除,
    或包含导致无法载入的错误。
    .cancel = 好的

dialog-exit-to-map-editor =
    .title = 离开任务
    .prompt = 离开本局游戏并返回编辑器?
    .confirm = 返回编辑器
    .cancel = 留下

## IngamePowerBarLogic
## IngamePowerCounterLogic
label-power-usage = 电力使用:{ $usage }/{ $capacity }
label-infinite-power = 无限

## IngameSiloBarLogic
## IngameCashCounterLogic
label-silo-usage = 矿仓容量:{ $usage }/{ $capacity }

## ObserverShroudSelectorLogic
options-shroud-selector =
    .all-players = 所有玩家
    .disable-shroud = 关闭战争迷雾
    .other = 其他

## ObserverStatsLogic
options-observer-stats =
    .none = 信息:无
    .basic = 基础
    .economy = 经济
    .production = 生产
    .support-powers = 支援技能
    .combat = 战斗
    .army = 部队
    .earnings-graph = 收入(图表)
    .army-graph = 部队(图表)

## WorldTooltipLogic
label-unrevealed-terrain = 未探明地形

## KickClientLogic
dialog-kick-client =
    .prompt = 踢出 { $player }?

## KickSpectatorsLogic
dialog-kick-spectators =
    .prompt =
    { $count ->
        [one] 确定要踢出一名观战者吗?
       *[other] 确定要踢出 { $count } 名观战者吗?
    }

## LobbyLogic
options-slot-admin =
    .add-bots = 添加
    .remove-bots = 移除
    .configure-bots = 配置电脑玩家
    .teams-count = { $count } 支队伍
    .humans-vs-bots = 真人对电脑
    .free-for-all = 混战
    .configure-teams = 配置队伍

## LobbyLogic, InGameChatLogic
button-general-chat = 全体
button-team-chat = 队伍

## LobbyOptionsLogic, MissionBrowserLogic
label-not-available = 不可用

## LobbyUtils
options-lobby-slot =
    .slot = 位置
    .open = 开放
    .closed = 关闭
    .bots = 电脑玩家
    .bots-disabled = 已禁用电脑玩家

## MapPreviewLogic
label-connecting = 正在连接...
label-downloading-map = 正在下载 { $size } kB
label-downloading-map-progress = 正在下载 { $size } kB({ $progress }%)
button-retry-install = 重试安装
button-retry-search = 重试搜索
## also MapChooserLogic
label-created-by = 作者:{ $author }

## SpawnSelectorTooltipLogic
label-disabled-spawn = 已禁用的出生点
label-available-spawn = 可用的出生点

## DisplaySettingsLogic
options-camera =
    .close = 近
    .medium = 中
    .far = 远
    .furthest = 最远

options-display-mode =
    .windowed = 窗口化
    .legacy-fullscreen = 全屏(传统)
    .fullscreen = 全屏

label-video-display-index = 显示器 { $number }

options-status-bars =
    .standard = 标准
    .show-on-damage = 受损时显示
    .always-show = 始终显示

options-target-lines =
    .automatic = 自动
    .manual = 手动
    .disabled = 关闭

checkbox-frame-limiter = 启用帧率限制({ $fps } FPS)

## HotkeysSettingsLogic
label-original-notice = 默认值为“{ $key }”
label-duplicate-notice = 该键已在 { $context } 中用于“{ $key }”
hotkey-context-any = 任意

## GameplaySettingsLogic
auto-save-interval =
    .disabled = 关闭
    .options =
        { $seconds ->
            [one] 1 秒
           *[other] { $seconds } 秒
        }
    .minute-options =
        { $minutes ->
            [one] 1 分钟
           *[other] { $minutes } 分钟
        }

auto-save-max-file-number = { $saves } 个存档

## InputSettingsLogic
options-mouse-scroll-type =
    .disabled = 关闭
    .standard = 标准
    .inverted = 反向
    .joystick = 摇杆

## InputSettingsLogic, IntroductionPromptLogic
options-control-scheme =
    .classic = 经典
    .modern = 现代
    .otherrts = 其他 RTS

## SettingsLogic
dialog-settings-save =
    .title = 需要重启
    .prompt = 部分改动将在
    游戏重启后生效。
    .cancel = 继续

dialog-settings-restart =
    .title = 立即重启?
    .prompt = 部分改动将在
    游戏重启后生效。是否立即重启?
    .confirm = 立即重启
    .cancel = 稍后重启

dialog-settings-reset =
    .title = 重置 { $panel }
    .prompt = 确定要重置
    本面板中的所有设置吗?
    .confirm = 重置
    .cancel = 取消

## AssetBrowserLogic
label-all-packages = 所有数据包
label-length-in-seconds = { $length } 秒

## ConnectionLogic
label-connecting-to-endpoint = 正在连接 { $endpoint }...
label-could-not-connect-to-target = 无法连接到 { $target }
label-unknown-error = 未知错误
label-password-required = 需要密码
label-connection-failed = 连接失败
notification-mod-switch-failed = 切换模组失败。

## GameSaveBrowserLogic
dialog-rename-save =
    .title = 重命名存档
    .prompt = 输入新的文件名:
    .confirm = 重命名

dialog-delete-save =
    .title = 删除所选存档?
    .prompt = 删除“{ $save }”。
    .confirm = 删除

dialog-delete-all-saves =
    .title = 删除全部存档?
    .prompt =
    { $count ->
        [one] 删除 { $count } 个存档。
       *[other] 删除 { $count } 个存档。
    }
    .confirm = 全部删除

notification-save-deletion-failed = 删除存档文件“{ $savePath }”失败。详情请查看日志。

dialog-overwrite-save =
    .title = 覆盖存档?
    .prompt = 覆盖 { $file }?
    .confirm = 覆盖

## MainMenuLogic
label-loading-news = 正在载入新闻
label-news-retrieval-failed = 获取新闻失败:{ $message }
label-news-parsing-failed = 解析新闻失败:{ $message }
label-author-datetime = 由 { $author } 发布于 { $datetime }

## MapChooserLogic
label-all-maps = 所有地图
label-no-matches = 无匹配结果
label-player-count =
    { $players ->
        [one] { $players } 名玩家
       *[other] { $players } 名玩家
    }
label-map-size-huge = 超大
label-map-size-large = 大
label-map-size-medium = 中
label-map-size-small = 小
label-map-searching-count =
    { $count ->
        [one] 正在 OpenRA 资源中心搜索 { $count } 张地图...
       *[other] 正在 OpenRA 资源中心搜索 { $count } 张地图...
    }
label-map-unavailable-count =
    { $count ->
        [one] 有 { $count } 张地图未能在 OpenRA 资源中心找到
       *[other] 有 { $count } 张地图未能在 OpenRA 资源中心找到
    }

notification-map-deletion-failed = 删除地图“{ $map }”失败。详情请查看 debug.log。

dialog-delete-map =
    .title = 删除地图
    .prompt = 删除地图“{ $title }”?
    .confirm = 删除

dialog-delete-all-maps =
    .title = 删除地图
    .prompt = 删除本页的所有地图?
    .confirm = 删除

options-order-maps =
    .player-count = 玩家数
    .title = 标题
    .date = 日期
    .size = 尺寸

button-mapchooser-system-maps-tab = 官方地图
button-mapchooser-remote-maps-tab = 服务器地图
button-mapchooser-user-maps-tab = 自定义地图
button-mapchooser-generated-maps-tab = 生成地图

## MissionBrowserLogic
dialog-no-video =
    .title = 视频未安装
    .prompt =
        游戏视频可以通过
        “管理内容”菜单安装。
    .cancel = 返回

dialog-cant-play-video =
    .title = 无法播放视频
    .prompt = 视频播放过程中出现错误。
    .cancel = 返回

## MusicPlayerLogic
label-sound-muted = 音频已在设置中静音。
label-no-song-playing = 当前没有播放曲目

## MuteHotkeyLogic
label-audio-muted = 音频已静音。
label-audio-unmuted = 音频已取消静音。

## PlayerProfileLogic
label-loading-player-profile = 正在载入玩家资料...
label-loading-player-profile-failed = 载入玩家资料失败。

## ProductionTooltipLogic, EncyclopediaLogic
label-requires = 需要 { $prerequisites }。

## ReplayBrowserLogic
label-duration = 时长:{ $time }

options-replay-type =
    .singleplayer = 单人
    .multiplayer = 多人

options-winstate =
    .victory = 胜利
    .defeat = 失败

options-replay-date =
    .today = 今天
    .last-week = 最近 7 天
    .last-fortnight = 最近 14 天
    .last-month = 最近 30 天

options-replay-duration =
    .very-short = 5 分钟以内
    .short = 较短(10 分钟)
    .medium = 中等(30 分钟)
    .long = 较长(60 分钟以上)

dialog-rename-replay =
    .title = 重命名录像
    .prompt = 输入新的文件名:
    .confirm = 重命名

dialog-delete-replay =
    .title = 删除所选录像?
    .prompt = 删除录像 { $replay }?
    .confirm = 删除

dialog-delete-all-replays =
    .title = 删除所有所选录像?
    .prompt =
    { $count ->
        [one] 删除 { $count } 个录像。
       *[other] 删除 { $count } 个录像。
    }
    .confirm = 全部删除

notification-replay-deletion-failed = 删除录像文件“{ $file }”失败。详情请查看 debug.log。

## ReplayUtils
-incompatible-replay-recorded = 它由

dialog-incompatible-replay =
    .title = 录像不兼容
    .prompt = 无法读取录像元数据。
    .confirm = 确定
    .prompt-unknown-version = { -incompatible-replay-recorded }未知版本录制。
    .prompt-unknown-mod = { -incompatible-replay-recorded }未知模组录制。
    .prompt-unavailable-mod = { -incompatible-replay-recorded }不可用的模组录制:{ $mod }。
    .prompt-incompatible-version = { -incompatible-replay-recorded }不兼容的版本录制:
    { $version }。
    .prompt-unavailable-map = { -incompatible-replay-recorded }不可用的地图录制:
    { $map }。

# SelectUnitsByTypeHotkeyLogic
nothing-selected = 未选中任何单位。

## SelectUnitsByTypeHotkeyLogic, SelectAllUnitsHotkeyLogic
selected-units-across-screen =
    { $units ->
        [one] 已选中屏幕内的 1 个单位。
       *[other] 已选中屏幕内的 { $units } 个单位。
    }

selected-units-across-map =
    { $units ->
        [one] 已选中地图上的 1 个单位。
       *[other] 已选中地图上的 { $units } 个单位。
    }

## ServerCreationLogic
label-internet-server-nat-A = 互联网服务器(UPnP/NAT-PMP
label-internet-server-nat-B-enabled = 已启用
label-internet-server-nat-B-not-supported = 不支持
label-internet-server-nat-B-disabled = 已禁用
label-internet-server-nat-C = ):

label-local-server = 局域网服务器:

dialog-server-creation-failed =
    .prompt = 无法监听端口 { $port }。
    .prompt-port-used = 请检查该端口是否已被占用。
    .prompt-error = 错误信息:“{ $message }”({ $code })。
    .title = 创建服务器失败
    .cancel = 返回

## ServerListLogic
label-players-online-count =
    { $players ->
        [one] { $players } 名玩家在线
       *[other] { $players } 名玩家在线
    }

label-search-status-failed = 查询服务器列表失败。
label-search-status-no-games = 未找到游戏。请尝试更改筛选条件。
label-no-server-selected = 未选择服务器

label-map-status-searching = 正在搜索...
label-map-classification-unknown = 未知地图

label-players-count =
    { $players ->
        [0] 无玩家
        [one] 1 名玩家
       *[other] { $players } 名玩家
    }

label-bots-count =
    { $bots ->
        [0] 无电脑玩家
        [one] 1 个电脑玩家
       *[other] { $bots } 个电脑玩家
    }

## ServerListLogic, ReplayBrowserLogic, ObserverShroudSelectorLogic
label-players = 玩家

## ServerListLogic, GameInfoStatsLogic
label-spectators = 观战者
label-spectators-count =
    { $spectators ->
        [0] 无观战者
        [one] 1 名观战者
       *[other] { $spectators } 名观战者
    }

## ServerlistLogic, GameInfoStatsLogic, ObserverShroudSelectorLogic, SpawnSelectorTooltipLogic, ReplayBrowserLogic
label-team-name = 队伍 { $team }
label-no-team = 无队伍

label-playing = 对战中
label-waiting = 等待中

label-other-players-count =
    { $players ->
        [one] 另外 1 名玩家
       *[other] 另外 { $players } 名玩家
    }

label-in-progress-for =
    { $minutes ->
        [0] 开始不到 1 分钟。
        [one] 已进行 { $minutes } 分钟。
       *[other] 已进行 { $minutes } 分钟。
    }

label-password-protected = 需要密码
label-waiting-for-players = 等待玩家加入
label-server-shutting-down = 服务器正在关闭
label-unknown-server-state = 服务器状态未知

## Game
notification-saved-screenshot = 已保存截图 { $filename }

## ChatCommands
notification-invalid-command = { $name } 不是有效命令。

## DebugVisualizationCommands
description-combat-geometry = 切换战斗判定覆盖层。
description-render-geometry = 切换渲染判定覆盖层。
description-screen-map-overlay = 切换屏幕映射覆盖层。
description-depth-buffer = 切换深度缓冲覆盖层。
description-actor-tags-overlay = 切换单位标签覆盖层。

## DevCommands
notification-cheats-disabled = 作弊功能已禁用。
notification-invalid-cash-amount = 资金数量无效。
description-toggle-visibility = 切换视野判定与雷达地图。
description-give-cash = 给予默认或指定数量的资金。
description-give-cash-all = 给予所有玩家与电脑默认或指定数量的资金。
description-instant-building = 切换瞬间建造。
description-build-anywhere = 切换任意地点建造。
description-unlimited-power = 切换无限电力。
description-enable-tech = 切换解锁全部建造。
description-fast-charge = 切换支援技能近乎瞬间充能。
description-dev-cheat-all = 切换全部作弊并给予一些资金。
description-dev-crash = 让游戏崩溃。
description-levelup-actor = 为所选单位增加指定数量的等级。
description-player-experience = 为所选单位的拥有者增加指定经验值。
description-power-outage = 使所选单位的拥有者断电 5 秒。
description-kill-selected-actors = 摧毁所选单位。
description-dispose-selected-actors = 移除所选单位。

## HelpCommands
notification-available-commands = 以下是可用的命令:
description-no-description = 无说明。
description-help-description = 提供各类命令的有用信息。

## PlayerCommands
description-pause-description = 暂停或继续游戏。
description-surrender-description = 自毁全部单位并认输。

## DeveloperMode
notification-cheat-used = 使用了作弊:{ $cheat },由 { $player }{ $suffix }。

## CustomTerrainDebugOverlay
description-custom-terrain-debug-overlay = 切换自定义地形调试覆盖层。

## CellTriggerOverlay
description-cell-triggers-overlay = 切换脚本触发器覆盖层。

## HierarchicalPathFinderOverlay
description-hpf-debug-overlay = 切换分层寻路调试覆盖层。

## PathFinderOverlay
description-path-debug-overlay = 切换寻路过程可视化。

## TerrainGeometryOverlay
description-terrain-geometry-overlay = 切换地形判定覆盖层。

## ActorMapOverlay
description-actor-map-overlay = 切换单位映射覆盖层。

## MapOptions, MissionBrowserLogic
options-game-speed =
    .slowest = 最慢
    .slower = 较慢
    .normal = 正常
    .fast = 较快
    .faster = 更快
    .fastest = 最快

## TimeLimitManager
options-time-limit =
    .no-limit = 无限制
    .options =
        { $minutes ->
            [one] { $minutes } 分钟
           *[other] { $minutes } 分钟
        }

notification-time-limit-expired = 时间已到。

## EditorActorBrush
notification-added-actor = 已添加 { $name }({ $id })

## EditorCopyPasteBrush
notification-copied-tiles = 已复制 { $tiles } 个地块
notification-copied-actors = 已复制 { $actors } 个单位
notification-copied-tiles-actors = 已复制 { $tiles } 个地块和 { $actors } 个单位

## EditorDefaultBrush
notification-selected-area = 已选择区域 { $x },{ $y }({ $width },{ $height })
notification-removed-area = 已移除区域 { $x },{ $y }({ $width },{ $height })
notification-selected-actor = 已选择单位 { $id }
notification-cleared-selection = 已清除选择
notification-removed-actor = 已移除 { $name }({ $id })
notification-removed-resource = 已移除 { $type }
notification-moved-actor = 已将 { $id } 从 { $x1 },{ $y1 } 移动到 { $x2 },{ $y2 }

## EditorResourceBrush
notification-added-resource =
    { $count ->
       [one] 已添加 1 格 { $type }
      *[other] 已添加 { $count } 格 { $type }
    }

## EditorTileBrush
notification-added-tile = 已添加地块 { $id }
notification-filled-tile = 已用地块 { $id } 填充

## EditorMarkerLayerBrush
notification-added-marker-tiles-markers =
    .red = 红色
    .orange = 橙色
    .yellow = 黄色
    .green = 绿色
    .cyan = 青色
    .blue = 蓝色
    .purple = 紫色
    .magenta = 品红
notification-added-marker-tiles =
    { $count ->
       [one] 已添加 { $type } 标记地块
      *[other] 已添加 { $count } 个 { $type } 标记地块
    }
notification-removed-marker-tiles =
    { $count ->
       [one] 已移除标记地块
      *[other] 已移除 { $count } 个标记地块
    }
notification-cleared-selected-marker-tiles =
    { $count ->
       [one] 已清除 { $type } 标记地块
      *[other] 已清除 { $count } 个 { $type } 标记地块
    }
notification-cleared-all-marker-tiles = 已清除 { $count } 个标记地块

## EditorActionManager
notification-opened = 已打开

## MapOverlaysLogic
mirror-mode =
    .none = 无
    .flip = 翻转
    .rotate = 旋转

## ActorEditLogic
notification-edited-actor = 已编辑 { $name }({ $id })
notification-edited-actor-id = 已编辑 { $name }({ $old-id }-> { $new-id })

## ConquestVictoryConditions, StrategicVictoryConditions
notification-player-is-victorious = { $player } 取得了胜利。
notification-player-is-defeated = { $player } 已被击败。

## OrderManager
notification-desync-compare-logs = 第 { $frame } 帧出现不同步。
    请与其他玩家比对 syncreport.log。

## WidgetUtils
label-win-state-won = 胜利
label-win-state-lost = 失败
label-client-state-disconnected = 已离开

## Player
enumerated-bot-name =
    { $name } { $number ->
       *[zero] {""}
        [other] { $number }
    }

## ModifiersExts
keycode-modifier =
    .alt = Alt
    .ctrl = Ctrl
    .meta = Meta
    .cmd = Cmd
    .shift = Shift
    .none = 无

## KeycodeExts
keycode =
    .unknown = 未定义
    .return = 回车
    .escape = Esc
    .backspace = 退格
    .tab = Tab
    .space = 空格
    .exclaim = !
    .quotedbl = "
    .hash = #
    .percent = %
    .dollar = $
    .ampersand = &
    .quote = '
    .leftparen = (
    .rightparen = )
    .asterisk = *
    .plus = +
    .comma = ,
    .minus = -
    .period = .
    .slash = /
    .number_0 = 0
    .number_1 = 1
    .number_2 = 2
    .number_3 = 3
    .number_4 = 4
    .number_5 = 5
    .number_6 = 6
    .number_7 = 7
    .number_8 = 8
    .number_9 = 9
    .colon = :
    .semicolon = ;
    .less = <
    .equals = =
    .greater = >
    .question = ?
    .at = @
    .leftbracket = [
    .backslash = \
    .rightbracket = ]
    .caret = ^
    .underscore = _
    .backquote = `
    .a = A
    .b = B
    .c = C
    .d = D
    .e = E
    .f = F
    .g = G
    .h = H
    .i = I
    .j = J
    .k = K
    .l = L
    .m = M
    .n = N
    .o = O
    .p = P
    .q = Q
    .r = R
    .s = S
    .t = T
    .u = U
    .v = V
    .w = W
    .x = X
    .y = Y
    .z = Z
    .capslock = 大写锁定
    .f1 = F1
    .f2 = F2
    .f3 = F3
    .f4 = F4
    .f5 = F5
    .f6 = F6
    .f7 = F7
    .f8 = F8
    .f9 = F9
    .f10 = F10
    .f11 = F11
    .f12 = F12
    .printscreen = 打印屏幕
    .scrolllock = 滚动锁定
    .pause = 暂停
    .insert = 插入
    .home = Home
    .pageup = 上翻页
    .delete = 删除
    .end = End
    .pagedown = 下翻页
    .right = 右方向键
    .left = 左方向键
    .down = 下方向键
    .up = 上方向键
    .numlockclear = 数字锁定
    .kp_divide = 小键盘 /
    .kp_multiply = 小键盘 *
    .kp_minus = 小键盘 -
    .kp_plus = 小键盘 +
    .kp_enter = 小键盘回车
    .kp_1 = 小键盘 1
    .kp_2 = 小键盘 2
    .kp_3 = 小键盘 3
    .kp_4 = 小键盘 4
    .kp_5 = 小键盘 5
    .kp_6 = 小键盘 6
    .kp_7 = 小键盘 7
    .kp_8 = 小键盘 8
    .kp_9 = 小键盘 9
    .kp_0 = 小键盘 0
    .kp_period = 小键盘 .
    .application = 应用程序
    .power = 电源
    .kp_equals = 小键盘 =
    .f13 = F13
    .f14 = F14
    .f15 = F15
    .f16 = F16
    .f17 = F17
    .f18 = F18
    .f19 = F19
    .f20 = F20
    .f21 = F21
    .f22 = F22
    .f23 = F23
    .f24 = F24
    .execute = 执行
    .help = 帮助
    .menu = 菜单
    .select = 选择
    .stop = 停止
    .again = 重复
    .undo = 撤销
    .cut = 剪切
    .copy = 复制
    .paste = 粘贴
    .find = 查找
    .mute = 静音
    .volumeup = 音量增大
    .volumedown = 音量减小
    .kp_comma = 小键盘 ,
    .kp_equalsas400 = 小键盘(AS400)
    .alterase = AltErase
    .sysreq = SysReq
    .cancel = 取消
    .clear = 清除
    .prior = Prior
    .return2 = 回车
    .separator = 分隔符
    .out = Out
    .oper = Oper
    .clearagain = 清除 / 重复
    .crsel = CrSel
    .exsel = ExSel
    .kp_00 = 小键盘 00
    .kp_000 = 小键盘 000
    .thousandsseparator = 千位分隔符
    .decimalseparator = 小数点
    .currencyunit = 货币单位
    .currencysubunit = 货币辅单位
    .kp_leftparen = 小键盘 (
    .kp_rightparen = 小键盘 )
    .kp_leftbrace = 小键盘 {"{"}
    .kp_rightbrace = 小键盘 {"}"}
    .kp_tab = 小键盘 Tab
    .kp_backspace = 小键盘退格
    .kp_a = 小键盘 A
    .kp_b = 小键盘 B
    .kp_c = 小键盘 C
    .kp_d = 小键盘 D
    .kp_e = 小键盘 E
    .kp_f = 小键盘 F
    .kp_xor = 小键盘 XOR
    .kp_power = 小键盘 ^
    .kp_percent = 小键盘 %
    .kp_less = 小键盘 <
    .kp_greater = 小键盘 >
    .kp_ampersand = 小键盘 &
    .kp_dblampersand = 小键盘 &&
    .kp_verticalbar = 小键盘 |
    .kp_dblverticalbar = 小键盘 ||
    .kp_colon = 小键盘 :
    .kp_hash = 小键盘 #
    .kp_space = 小键盘空格
    .kp_at = 小键盘 @
    .kp_exclam = 小键盘 !
    .kp_memstore = 小键盘 MemStore
    .kp_memrecall = 小键盘 MemRecall
    .kp_memclear = 小键盘 MemClear
    .kp_memadd = 小键盘 MemAdd
    .kp_memsubtract = 小键盘 MemSubtract
    .kp_memmultiply = 小键盘 MemMultiply
    .kp_memdivide = 小键盘 MemDivide
    .kp_plusminus = 小键盘 +/-
    .kp_clear = 小键盘清除
    .kp_clearentry = 小键盘清除输入
    .kp_binary = 小键盘二进制
    .kp_octal = 小键盘八进制
    .kp_decimal = 小键盘十进制
    .kp_hexadecimal = 小键盘十六进制
    .lctrl = 左 Ctrl
    .lshift = 左 Shift
    .lalt = 左 Alt
    .lgui = 左 GUI
    .rctrl = 右 Ctrl
    .rshift = 右 Shift
    .ralt = 右 Alt
    .rgui = 右 GUI
    .mode = 模式切换
    .audionext = 下一曲
    .audioprev = 上一曲
    .audiostop = 停止播放
    .audioplay = 播放
    .audiomute = 静音
    .mediaselect = 媒体选择
    .www = WWW
    .mail = 邮件
    .calculator = 计算器
    .computer = 计算机
    .ac_search = AC 搜索
    .ac_home = AC 主页
    .ac_back = AC 后退
    .ac_forward = AC 前进
    .ac_stop = AC 停止
    .ac_refresh = AC 刷新
    .ac_bookmarks = AC 书签
    .brightnessdown = 亮度降低
    .brightnessup = 亮度提高
    .displayswitch = 显示切换
    .kbdillumtoggle = 键盘背光开关
    .kbdillumdown = 键盘背光减弱
    .kbdillumup = 键盘背光增强
    .eject = 弹出
    .sleep = 睡眠
    .mouse4 = 鼠标键 4
    .mouse5 = 鼠标键 5

## MapGeneratorToolLogic
notification-map-generator-generated = 使用 { $name } 生成

dialog-notification-map-generator-failed =
    .title = 地图生成失败
    .prompt = 详情请查看 debug.log。
    .cancel = 关闭

## EditorTilingPathBrush
notification-tiling-path-started = 已开始铺设路径
notification-tiling-path-updated = 已更新铺设路径
notification-tiling-path-reset = 已放弃铺设路径
notification-tiling-path-painted = 已绘制铺设路径
