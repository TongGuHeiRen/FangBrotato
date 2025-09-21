class_name main
extends Node

@export var 金袋场景: PackedScene
@export var 金币场景: PackedScene
@export var 消耗品场景: PackedScene
@export var 炮塔效果: Resource
@export var 地雷效果: Resource
@export var 金币精灵: Array[Texture2D]
@export var 金币拾取音效: Array[Resource]
@export var 金币替代拾取音效: Array[Resource]
@export var 升级音效: Resource
@export var 运行胜利音效: Array[Resource]
@export var 运行失败音效: Array[Resource]
@export var 波次结束音效: Array[Resource]

func 显示手动光标() -> bool:
	return 工具.is_manual_aim(0) and not _正在清理

const 边缘大小: int = 96
const 最大金币数: int = 50
const 最小金币几率: float = 0.5
const 最小地图大小: int = 12

const 鼠标与玩家手动瞄准距离: int = 200

var _正在清理: bool = false
var _活跃金币: Array[Node] = []
var _消耗品: Array[Node] = []
var _待处理升级: Array[Array] = [[], [], [], []]
var _待处理消耗品: Array[Array] = [[], [], [], []]

var _波次结束计时器超时: bool = false

var _玩家: Array[Node] = []
var _下一个金币玩家: int
var _玩家界面: Array[Node] = []
var _待处理玩家容器: Array[Node] = []

var _运行失败: bool = false
var _波次失败: bool = false
var _运行胜利: bool = false
var _金币袋: Node



var _死亡时投射物属性缓存: Array[Variant] = [null, null, null, null]
var _本波次生成物品: int = 0
var _玩家生命值低于一半: Array[bool] = [false, false, false, false]

var _是否群体波次: bool = false
var _是否精英波次: bool = false
var _精英击杀奖励: int = 0
var 覆盖金币袋位置: Vector2 = Vector2.ZERO

var _池: Dictionary = {}
var _跳过暂停检查: bool = false

@onready var _实体容器: YSort = $"%实体"
@onready var _实体生成器: Node = $实体生成器
@onready var _效果管理器: Node = $效果管理器
@onready var _属性管理器: 属性管理器 = $"%属性管理器"
@onready var _波次管理器: Node = $波次管理器
@onready var _浮动文本管理器: Node = $浮动文本管理器
@onready var _效果行为: 效果行为 = $效果行为
@onready var _摄像机: 我的摄像机 = $摄像机
@onready var _屏幕震动器: Node = $摄像机/屏幕震动器
@onready var _材料容器: Node2D = $"%材料"
@onready var _消耗品容器: Node2D = $"%消耗品"
@onready var _诞生容器: Node2D = $"%诞生"
@onready var _暂停菜单: Node = $界面/暂停菜单
@onready var _波次结束计时器: Timer = $波次结束计时器
@onready var _升级界面: 升级界面 = $界面/升级界面
@onready var _合作升级界面: 升级界面 = $界面/合作升级界面
@onready var _波次计时器: Timer = $波次计时器

@onready var _波次清除标签: Label = $界面/波次清除标签
@onready var _平视显示器: Node = $界面/平视显示器
@onready var _界面奖励金币: Node = $界面/平视显示器/生命容器P1/界面奖励金币
@onready var _界面奖励金币位置: Node2D = $界面/平视显示器/生命容器P1/界面奖励金币/位置2D
@onready var _当前波次标签: Label = $界面/平视显示器/波次容器/当前波次标签
@onready var _波次计时器标签: Node = $界面/平视显示器/波次容器/波次计时器标签
@onready var _界面波次容器: Node = $界面/平视显示器/波次容器
@onready var _界面待处理边距容器: MarginContainer = $"%待处理边距容器"
@onready var _界面调暗屏幕: ColorRect = $界面/调暗屏幕
@onready var _瓦片地图: Node = $瓦片地图
@onready var _瓦片地图限制: Node = $"%瓦片地图限制"
@onready var _背景: Node = $画布图层/背景
@onready var _收获计时器: Timer = $收获计时器
@onready var _重试波次: Node = $界面/重试波次

@onready var _伤害晕影: Node = $界面/伤害晕影
@onready var _信息弹窗: Node = $界面/信息弹窗
@onready var _帧率标签: Label = $"%帧率标签"
@onready var _爆炸: Node2D = $"爆炸"
@onready var _效果: Node2D = $"效果"
@onready var _浮动文本: Node2D = $"%浮动文本"
@onready var _玩家投射物: Node2D = $"%玩家投射物"
@onready var _敌人投射物: Node2D = $"%敌人投射物"
@onready var _半秒计时器: Node2D = $"%半秒计时器"
@onready var _爆炸容器: Node2D = $"爆炸容器"
@onready var _效果容器: Node2D = $"效果容器"
@onready var _浮动文本容器: Node2D = $"浮动文本容器"
@onready var _出生容器: Node2D = $"出生容器"

var _玩家是否半血: Array[bool] = [false, false, false, false]


func _ready() -> void:
	if 调试服务.display_fps:
		_帧率标签.show()

	var _e = _实体生成器.players_spawned.connect(_当实体生成器玩家已生成)

	音乐管理器.tween(0)
	_暂停菜单.enabled = true
	if 调试服务.hide_wave_timer: 
		_界面波次容器.hide()

	运行数据.on_wave_start()
	_下一个金币玩家 = 工具.randi() % 运行数据.获取玩家数量()

	

	_背景.texture.gradient.colors[1] = 物品服务.获取背景渐变颜色()
	_瓦片地图.tile_set.tile_set_texture(0, 运行数据.get_background().获取瓦片精灵())
	_瓦片地图.outline.modulate = 运行数据.get_background().outline_color

	临时属性.reset()

	var _stats = 运行数据.stats_updated.connect(当属性更新)

	_金币袋 = 工具.在主场景实例化场景(金袋场景, 获取金币袋位置())
	var current_zone = 区域服务.get_zone_data(运行数据.current_zone).duplicate()
	var current_wave_data = 区域服务.get_wave_data(运行数据.current_zone, 运行数据.current_wave)

	var map_size_coef = (1 + (运行数据.sum_all_player_effects("map_size") / 100.0))
	current_zone.width = max(最小地图大小, (current_zone.width * map_size_coef)) as int
	current_zone.height = max(最小地图大小, (current_zone.height * map_size_coef)) as int

	区域服务.set_current_zone(current_zone)
	_瓦片地图.init(current_zone)
	_瓦片地图限制.init(current_zone)

	_当前波次标签.text = 文本.text("WAVE", [str(运行数据.current_wave)]).to_upper()

	_波次计时器.wait_time = 1 if 运行数据.instant_waves else current_wave_data.wave_duration

	if 调试服务.custom_wave_duration != -1:
		_波次计时器.wait_time = 调试服务.custom_wave_duration

	_波次计时器.start()
	_波次计时器标签.wave_timer = _波次计时器
	var _error_wave_timer = _波次计时器.tick_started.connect(当计时开始)

	var _error_group_spawn = _波次管理器.group_spawn_timing_reached.connect(_实体生成器.on_group_spawn_timing_reached)
	_波次管理器.init(_波次计时器, current_zone, current_wave_data)

	var _error_connect = _合作升级界面.upgrade_selected.connect(当升级选择)
	_error_connect = _合作升级界面.item_take_button_pressed.connect(当物品盒子拿取按钮按下)
	_error_connect = _合作升级界面.item_discard_button_pressed.connect(当物品盒子丢弃按钮按下)

	_error_connect = _升级界面.upgrade_selected.connect(当升级选择)
	_error_connect = _升级界面.item_take_button_pressed.connect(当物品盒子拿取按钮按下)
	_error_connect = _升级界面.item_discard_button_pressed.connect(当物品盒子丢弃按钮按下)

	var _error_level_up = 运行数据.levelled_up.connect(当升级)
	var _error_level_up_floating_text = 运行数据.levelled_up.connect(_浮动文本管理器.当升级)
	var _error_xp_added = 运行数据.xp_added.connect(当经验值添加)
	var _error_gold_changed = 运行数据.gold_changed.connect(当金币改变)
	var _error_bonus_gold_ui = 运行数据.bonus_gold_changed.connect(_界面奖励金币.更新值)
	var _error_bonus_gold = 运行数据.bonus_gold_changed.connect(当奖励金币改变)
	当奖励金币改变(运行数据.bonus_gold)
	var _error_damage_effect = 运行数据.damage_effect.connect(当伤害效果)
	var _error_lifesteal_effect = 运行数据.lifesteal_effect.connect(当生命偷取效果)
	var _error_healing_effect = 运行数据.healing_effect.connect(当治疗效果)
	var _error_heal_over_time_effect = 运行数据.heal_over_time_effect.connect(当持续治疗效果)

	var _error_gamepad = 输入服务.game_lost_focus.connect(_当游戏失去焦点)

	
	var max_bounds = 区域服务.get_current_zone_rect().grow_individual(边缘大小, 边缘大小 * 2, 边缘大小, 边缘大小)
	_摄像机.init(max_bounds, float(边缘大小))
	当锁定合作摄像机改变(进度数据.settings.lock_coop_camera)
	区域服务.current_zone_max_camera_rect = _摄像机.获取最大摄像机边界()

	_界面调暗屏幕.color.a = 0

	if 进度数据.settings.manual_aim:
		输入服务.hide_mouse = false

	var _error_options_1 = _暂停菜单.menu_gameplay_options.character_highlighting_changed.connect(当角色高亮改变)
	var _error_options_2 = _暂停菜单.menu_gameplay_options.hp_bar_on_character_changed.connect(当角色生命条改变)
	var _error_options_3 = _暂停菜单.menu_gameplay_options.weapon_highlighting_changed.connect(当武器高亮改变)
	var _error_options_4 = _暂停菜单.menu_gameplay_options.darken_screen_changed.connect(当调暗屏幕改变)
	var _error_options_5 = _暂停菜单.menu_gameplay_options.lock_coop_camera_changed.connect(当锁定合作摄像机改变)

	for player_index in 合作服务.MAX_PLAYER_COUNT:
		var player_idx_string = str(player_index + 1)
		var things_to_process_player_container = get_node("%%UI待处理玩家容器%s" % player_idx_string)
		
		things_to_process_player_container.hide()
		if not 运行数据.is_coop_run:
			
			things_to_process_player_container.horizontal_alignment = BoxContainer.AlignmentMode.ALIGNMENT_END
		_待处理玩家容器.push_back(things_to_process_player_container)
	
		_是否群体波次 = 运行数据.is_elite_wave(精英类型.HORDE)
		_是否精英波次 = 运行数据.is_elite_wave(精英类型.ELITE)
	
		if not 运行数据.is_coop_run:
			_界面待处理边距容器.add_theme_constant_override("margin_right", 0)
	
		for effect_behavior_data in 效果行为服务.scene_effect_behaviors:
			var effect_behavior: 场景效果行为 = effect_behavior_data.scene.instantiate()
			_效果行为.add_child(effect_behavior.init(_实体生成器, _波次管理器))
	
		_实体生成器.init(
			区域服务.current_zone_min_position, 
			区域服务.current_zone_max_position, 
			current_wave_data, 
			_波次计时器
		)
		_属性管理器.init(_实体生成器)
	
		实体服务.reset_cache()
		输入服务.set_gamepad_echo_processing(false)
		_合作升级界面.propagate_call("set_process_input", [false])
	
		_初始化半秒计时器()
	
	
	func _初始化半秒计时器() -> void:
		var 计时器等待时间: float = 0.5
		var 玩家数量: int = 运行数据.获取玩家数量()
		var 计时器延迟: float = 计时器等待时间 / 玩家数量
		for 玩家索引 in 玩家数量:
			if 链接统计.update_for_player_every_half_sec[玩家索引]:
				var 计时器: Timer = Timer.new()
				计时器.wait_time = 计时器等待时间
				计时器.autostart = true
				_半秒计时器.add_child(计时器)
				计时器.timeout.connect(_当半秒计时器超时.bind(玩家索引))
				await get_tree().create_timer(计时器延迟).timeout
	
	
	func 当界面元素鼠标进入(ui_element: Node, text: String) -> void:
		if _正在清理:
			_信息弹窗.display(ui_element, tr(text))
	
	
	func 当界面元素鼠标进入(ui_element: Node, text: String) -> void:
		if _正在清理:
			_信息弹窗.display(ui_element, tr(text))
	
	
	func 当界面元素鼠标离开(_ui_element: Node) -> void:
		_信息弹窗.hide()
	
	
	func 当角色高亮改变(_value: bool) -> void:
		for player in _玩家:
			if not is_instance_valid(player) or not player.is_inside_tree():
				continue
			player.更新高亮()
	
	
	func 当武器高亮改变(_value: bool) -> void:
		for player in _玩家:
			if not is_instance_valid(player) or not player.is_inside_tree():
				continue
			player.更新武器高亮()
	
	
	func 当调暗屏幕改变(_value: int) -> void:
		_伤害晕影.根据生命值更新()
	
	
	func 当锁定合作摄像机改变(value: int) -> void:
		_摄像机.dynamic_camera_enabled = not value
	
	
	func 当角色生命条改变(_value: int) -> void:
		for i in _玩家.size():
			if not is_instance_valid(_玩家[i]) or not _玩家[i].is_inside_tree(): 
				return 
			_当玩家生命值更新(_玩家[i], _玩家[i].current_stats.health, _玩家[i].max_stats.health)
	
	
	func 当属性更新(玩家索引: int) -> void:
		_属性管理器.重新加载属性(_玩家[玩家索引])
		_死亡时投射物属性缓存[玩家索引] = null
	
	
	func _处理进程(_delta: float) -> void:
		if 调试服务.enable_time_scale_buttons:
			if Input.is_physical_key_pressed(KEY_1):
				Engine.time_scale = 0.5
			if Input.is_physical_key_pressed(KEY_2):
				Engine.time_scale = 1.0
			if Input.is_physical_key_pressed(KEY_3):
				Engine.time_scale = 2.0
	
		_处理鼠标可见性()
		_检查暂停()
	
	
	func _处理鼠标可见性() -> void:
		if _正在清理 or 运行数据.is_coop_run:
			return 
	
		if 进度数据.settings.manual_aim or 进度数据.settings.mouse_only:
			输入服务.hide_mouse = false
		elif 进度数据.settings.manual_aim_on_mouse_press:
			if 输入服务.using_gamepad:
				var rjoy = Input.get_vector("rjoy_left", "rjoy_right", "rjoy_up", "rjoy_down")
				输入服务.hide_mouse = rjoy == Vector2.ZERO
			else:
				输入服务.hide_mouse = not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		else:
			输入服务.hide_mouse = true
	
	
	func _检查暂停() -> void:
		if _跳过暂停检查:
			_跳过暂停检查 = false
			return 
	
		if 运行数据.is_coop_run:
			for player_index in 运行数据.获取玩家数量():
				var remapped_device = 合作服务.get_remapped_player_device(player_index)
				if Input.is_action_just_pressed("ui_pause_%s" % remapped_device):
					_暂停菜单.pause(player_index)
					break
		else:
			if Input.is_action_just_pressed("ui_pause"):
				_暂停菜单.pause(0)
	
	
	func _物理处理进程(_delta: float) -> void:
		if _正在清理:
			_金币袋.global_position = 获取金币袋位置()
	
		for player_index in 运行数据.获取玩家数量():
			var life_bar_effects = _玩家[player_index].生命条效果()
			var player_ui: 玩家UI元素 = _玩家界面[player_index]
			player_ui.life_bar.根据效果更新颜色(life_bar_effects)
			player_ui.player_life_bar.根据效果更新颜色(life_bar_effects)
	
		if not _正在清理:
			for player_index in 运行数据.获取玩家数量():
				if not 工具.is_manual_aim(player_index) or not 工具.is_player_using_gamepad(player_index):
					continue
				var rjoy = 工具.get_player_rjoy_vector(player_index)
				if rjoy != Vector2.ZERO:
					_玩家[player_index].gamepad_attack_vector = rjoy.normalized()
			if not 运行数据.is_coop_run and 工具.is_manual_aim(0) and 工具.is_player_using_gamepad(0):
				var player_pos = _玩家[0].get_screen_transform().origin
				player_pos.y -= 32
				get_viewport().warp_mouse(player_pos + 鼠标与玩家手动瞄准距离 * _玩家[0].gamepad_attack_vector)
	
	
	func 当计时开始() -> void:
		_波次计时器标签.modulate = Color.RED
	
	
	func 当奖励金币改变(value: int) -> void:
		if value == 0:
			_界面奖励金币.hide()
	
	
	func 当玩家死亡(p_player: 玩家, _args: 实体.死亡参数) -> void:
		var player_ui: 玩家UI元素 = _玩家界面[p_player.玩家索引]
		player_ui.player_life_bar.hide()
		if 运行数据.is_coop_run:
			player_ui.life_bar.set_value(100)
			player_ui.life_bar.progress_color = Color.WHITE
			player_ui.life_bar.hide_with_flash()
	
		p_player.highlight.hide()
	
		var 存活玩家: Array[Node] = _获取存活玩家()
		if not 存活玩家.is_empty():
			return 
	
		清理房间()
	
		进度数据.reset_and_save_new_run_state()
	
	
	func 当敌人死亡(enemy: Enemy, args: Entity.DeathArgs) -> void:
		_波次管理器.当敌人被击杀(enemy, args)
		
		if enemy.is_boss:
			运行数据.is_endless_run_boss_killed = true
			运行数据.all_last_wave_bosses_killed = true
			_波次管理器.移除Boss(enemy)
			
			if 运行数据.is_endless_run:
				var additional_groups = 区域服务.get_additional_groups(int((运行数据.current_wave / 10.0) * 3), 90)
				for i in additional_groups.size():
					additional_groups[i].spawn_timing = _波次计时器.wait_time - _波次计时器.time_left + i
				_波次管理器.添加群组(additional_groups)
				运行数据.all_last_wave_bosses_killed = true
			else:
				_波次计时器.wait_time = 0.1
				_波次计时器.start()
	
		var 存活玩家: Array[Node] = _获取随机存活的玩家()
	
		for player in 存活玩家:
			var 玩家索引 = player.玩家索引
			var 死亡时伤害 = 运行数据.获取玩家效果("dmg_when_death", 玩家索引)
			if 死亡时伤害.size() > 0:
				var _dmg_taken = 处理属性伤害(死亡时伤害, 玩家索引)
	
		for player in 存活玩家:
			var 玩家索引 = player.玩家索引
			var 死亡时投射物 = 运行数据.获取玩家效果("projectiles_on_death", 玩家索引)
			if 死亡时投射物.is_empty():
				continue
	
			for i in 死亡时投射物[0]:
				var stats = 死亡时投射物[1]
				if _死亡时投射物属性缓存[玩家索引] != null:
					stats = _死亡时投射物属性缓存[玩家索引]
				else:
					stats = 武器服务.init_ranged_stats(死亡时投射物[1], 玩家索引, true)
					_死亡时投射物属性缓存[玩家索引] = stats
	
			var 自动瞄准敌人: bool = 死亡时投射物[2]
			var 来源 = player
			var 生成投射物参数: = 武器服务.生成投射物参数.new()
			生成投射物参数.damage_tracking_key = "物品_留胡子的婴儿"
			生成投射物参数.from_player_index = 玩家索引
			var _projectile = 武器服务.管理特殊生成投射物(
				enemy, 
				stats, 
				randf_range(-PI, PI), 
				自动瞄准敌人, 
				_实体生成器, 
				来源, 
				生成投射物参数
			)
	
		for player in 存活玩家:
			var 玩家索引 = player.玩家索引
			运行数据.处理爆炸效果("explode_on_death", enemy.global_position, 玩家索引)
	
		生成战利品(enemy, EntityType.ENEMY, args)
		进度数据.增加属性("击杀敌人")
	
	
	func 当敌人受到伤害(enemy: Enemy, _value: int, _knockback_direction: Vector2, _is_crit: bool, _is_dodge: bool, _is_protected: bool, _armor_did_something: bool, args: TakeDamageArgs, _hit_type: int) -> void:
		if enemy.dead and 武器服务.敌人死亡时是否生成地雷(args.hitbox, args.is_burning, args.来源玩家索引):
			var 位置 = _实体生成器.获取区域内生成位置(enemy.global_position, 200)
			var 队列 = _实体生成器.queues_to_spawn_structures[args.来源玩家索引]
			队列.push_back([EntityType.STRUCTURE, 地雷效果.scene, 位置, 地雷效果])
	
	
	func 当玩家想要生成金币(价值: int, 位置: Vector2, 散布: int) -> void:
		var 实际价值 = 获取金币价值(EntityType.NEUTRAL, Entity.DeathArgs.new(), 价值)
		生成金币(实际价值, 位置, 散布)
	
	
	func 生成战利品(unit: Unit, entity_type: int, args: Entity.DeathArgs) -> void:
		if not unit.can_drop_loot:
			return 
	
		if unit.stats.can_drop_consumables:
			生成消耗品(unit)
	
		var wave_factor = 运行数据.current_wave * 0.015
		var spawn_chance = 1.0 if 运行数据.current_wave < 5 else maxf(0.5, (1.0 - wave_factor))
	
		if _是否群体波次:
			spawn_chance *= 0.65
	
		if unit.stats.always_drop_consumables:
			spawn_chance = 1.0
	
		if entity_type == EntityType.ENEMY and not 工具.get_chance_success(spawn_chance):
			return 
	
		var 位置: Vector2 = unit.global_position
		var 价值: float = 获取金币价值(entity_type, args, unit.stats.value, unit)
		var 金币散布 = clampi((价值 - 1) * 25, unit.stats.gold_spread, 200)
	
		生成金币(价值, 位置, 金币散布)
	
	
	func 生成消耗品(unit: Unit) -> void:
		var 幸运值: = 0.0
	
		for 玩家索引 in 运行数据.获取玩家数量():
			幸运值 += 工具.get_stat("stat_luck", 玩家索引) / 100.0
	
		if not 工具.get_chance_success(unit.stats.consumable_drop_chance + 幸运值):
			return
	
		var 消耗品 = 消耗品场景.instantiate()
		消耗品.init(运行数据.current_wave, unit.stats.consumable_drop_tier)
		_消耗品容器.add_child(消耗品)
		消耗品.global_position = unit.global_position
		消耗品.set_owner(_消耗品容器)
		_消耗品.push_back(消耗品)
		await 消耗品.ready
		消耗品.picked_up.connect(当消耗品被拾取)
	
	
	func 当消耗品被拾取(消耗品: 消耗品, 玩家索引: int) -> void:
		_消耗品.erase(消耗品)
		消耗品.queue_free()
	
	
	func 生成金币(value: float, 位置: Vector2, 散布: int) -> void:
		if value <= 0:
			return
	
		var 金币价值 = 获取金币价值(EntityType.NEUTRAL, Entity.DeathArgs.new(), value)
		var 金币数量 = min(最大金币数, roundi(金币价值))
		var 剩余价值 = 金币价值 - 金币数量
	
		if 剩余价值 > 0 and 工具.get_chance_success(剩余价值):
			金币数量 += 1
	
		for i in 金币数量:
			var 金币 = 金币场景.instantiate()
			_活跃金币.push_back(金币)
			_材料容器.add_child(金币)
			金币.global_position = 位置
			金币.set_owner(_材料容器)
			金币.init(1, 散布)
			金币.picked_up.connect(当金币被拾取)
	
		if _活跃金币.size() > 500:
			for i in 100:
				if not is_instance_valid(_活跃金币[i]):
					_活跃金币.remove_at(i)
					continue
				_活跃金币[i].queue_free()
				_活跃金币.remove_at(i)
	
	
	func 获取金币价值(entity_type: int, args: Entity.DeathArgs, base_value: float, unit: Unit = null) -> float:
		var 价值 = base_value
	
		if entity_type == EntityType.ENEMY:
			var 玩家索引 = args.killer_player_index
			if 玩家索引 == -1:
				玩家索引 = 0
	
			价值 = round(价值 * (1 + (工具.get_stat("stat_gold", 玩家索引) / 100.0)))
	
			if unit.is_elite:
				价值 *= 1.5
				_精英击杀奖励 += round(价值 * 0.5)
	
		return 价值
	
	
	func 当金币被拾取(金币: 金币, 玩家索引: int) -> void:
		_活跃金币.erase(金币)
		金币.queue_free()
		运行数据.add_gold(金币.value, 玩家索引)
		运行数据.add_xp(金币.value, 玩家索引)
	
		if 金币.value > 1:
			_浮动文本管理器.当金币被收集(金币.value, 玩家索引)
	
		var sound_index = mini(金币替代拾取音效.size() - 1, 运行数据.get_tracked_value(玩家索引, "item_greedy_ring"))
		声音服务.play_sound(金币拾取音效[sound_index], 金币.global_position)
	
	
	func 当升级(玩家索引: int) -> void:
		_浮动文本管理器.当升级(玩家索引)
		声音服务.播放声音(升级音效, _玩家[玩家索引].global_position)
	
	
	func 清理房间() -> void:
		if _正在清理:
			return
	
		_正在清理 = true
		_波次计时器.stop()
		_波次管理器.stop()
		_实体生成器.stop()
	
		输入服务.hide_mouse = true
	
		if 运行数据.is_endless_run:
			if not 运行数据.all_last_wave_bosses_killed:
				_波次失败 = true
			else:
				_波次结束计时器.start()
		else:
			if not _波次管理器.is_wave_complete():
				_波次失败 = true
			else:
				_波次结束计时器.start()
	
		if _波次失败:
			运行数据.failed_waves += 1
			if 运行数据.failed_waves >= 3:
				_运行失败 = true
				_设置运行状态()
			else:
				_重试波次.show()
		else:
			运行数据.failed_waves = 0
			运行数据.current_wave += 1
			if 运行数据.current_wave > 区域服务.get_zone_data(运行数据.current_zone).waves:
				_运行胜利 = true
				_设置运行状态()
			else:
				_波次结束计时器.start()
	
	
	func 设置运行状态() -> void:
		var 存活玩家: Array[Node] = _获取存活玩家()
		if not 存活玩家.is_empty():
			return
	
		_波次计时器.stop()
		_波次管理器.stop()
		_实体生成器.stop()
	
		if _运行失败:
			声音服务.play_sound(运行失败音效.pick_random())
			_重试波次.show()
		elif _运行胜利:
			声音服务.play_sound(运行胜利音效.pick_random())
			_切换场景("res://场景/MenuScene.tscn")
		else:
			_波次结束计时器.start()
	
	
	func 获取金币袋位置() -> Vector2:
		if 覆盖金币袋位置 != Vector2.ZERO:
			return 覆盖金币袋位置
	
		var 位置 = 区域服务.get_current_zone_rect().get_center()
		位置.y -= 32
		return 位置
	
	
	func 当波次结束计时器超时() -> void:
		_波次结束计时器超时 = true
	
		if 运行数据.is_endless_run:
			进度数据.保存进度数据()
			声音服务.播放声音(波次结束音效.pick_random())
			_切换场景("res://场景/MenuScene.tscn")
			return
	
		if 运行数据.is_coop_run:
			_合作升级界面.show()
		else:
			_升级界面.show()
	
		_界面调暗屏幕.show()
	_暂停菜单.enabled = false
	
		for 玩家索引 in 运行数据.获取玩家数量():
			var 波次结束统计 = 运行数据.获取玩家效果("stats_end_of_wave", 玩家索引)
			for 波次结束单项统计 in 波次结束统计:
				运行数据.add_stat(波次结束单项统计[0], 波次结束单项统计[1], 玩家索引)
	
				if 波次结束单项统计[0] == "stat_percent_damage":
					运行数据.添加追踪值(玩家索引, "item_vigilante_ring", 波次结束单项统计[1])
				elif 波次结束单项统计[0] == "stat_max_hp":
					var 叶子值 = 0
					var 物品 = 运行数据.获取玩家物品(玩家索引)
					for item in items:
					if item.my_id == "item_grinds_magical_leaf":
						for effect in item.effects:
							if effect.key != "stat_curse":
								leaf_value += effect.value
					run_data.add_tracked_value(player_index, "item_leaf", leaf_value)
				elif 波次结束单项统计[0] == "stat_melee_damage":
					var 机械臂值 = 0
					var 物品 = 运行数据.获取玩家物品(玩家索引)
					for 单个物品 in 物品:
						if 单个物品.我的ID == "item_robot_arm":
							for 效果 in 单个物品.effects:
								if 效果.键 != "stat_curse" and 效果.值 > 0:
									机械臂值 += 效果.值
					运行数据.添加追踪值(玩家索引, "item_robot_arm", 机械臂值)
				elif 波次结束单项统计[0] == "xp_gain" and 波次结束单项统计[1] > 0:
					运行数据.添加追踪值(玩家索引, "item_celery_tea", 波次结束单项统计[1])
				elif 波次结束单项统计[0] == "stat_armor" and 波次结束单项统计[1] < 0:
					运行数据.添加追踪值(玩家索引, "item_ashes", abs(波次结束单项统计[1]) as int)
	
		for 玩家索引 in 运行数据.获取玩家数量():
			工具.转换属性(运行数据.获取玩家效果("convert_stats_end_of_wave", 玩家索引), 玩家索引)
	
		管理收获()
	
		调试服务.log_data("start clean_up_room...")
		清理房间()
	
		临时统计.重置()
		输入服务.hide_mouse = true
	
	
	func 管理收获() -> void:
	for 玩家索引 in 运行数据.获取玩家数量():
		var 和平主义者效果 = 工具.获取属性("stat_pacifist", 玩家索引)
		var 每个存活敌人材料效果 = 工具.获取属性("stat_materials_per_living_enemy", 玩家索引)

		if 工具.获取属性("stat_harvesting", 玩家索引) != 0 or 和平主义者效果 != 0 or _精英击杀奖励 != 0\
		 or 每个存活敌人材料效果 != 0:
			var 和平主义者奖励 = round((_实体生成器.获取所有敌人().size() + _实体生成器.为了性能移除的敌人数量) * (和平主义者效果 / 100.0))
			var 存活敌人奖励 = _实体生成器.敌人.size() * 每个存活敌人材料效果

			if _是否群体波次:
				和平主义者奖励 = (和平主义者奖励 / 2) as int

			var 值 = 工具.获取属性("stat_harvesting", 玩家索引) + 和平主义者奖励 + _精英击杀奖励 + 存活敌人奖励

			if 值 >= 0:
				运行数据.添加金币(值, 玩家索引)
		运行数据.添加经验值(值, 玩家索引)
			else:
				运行数据.移除金币(abs(值) as int, 玩家索引)

			_浮动文本管理器.当收获(值, 玩家索引)

			if 工具.获取属性("stat_harvesting", 玩家索引) > 0:
				_收获计时器.start()

			运行数据.添加经验值(0, 玩家索引)
	
	
	func 获取存活玩家() -> Array[Node]:
		var 存活玩家: Array[Node] = []
		for 玩家 in _玩家:
			if not 玩家.dead:
				存活玩家.append(玩家)
	
		return 存活玩家
	
	
	func 获取随机存活的玩家() -> Array[Node]:
		var 存活玩家: Array[Node] = _获取存活玩家()
		存活玩家.shuffle()
		return 存活玩家
	
	
	func 切换场景(path: String) -> void:
		var _error = get_tree().change_scene_to_file(path)
	
	
	func 当界面奖励金币鼠标进入() -> void:
		if _正在清理:
			_信息弹窗.display(_界面奖励金币, 文本.text("信息_奖励_金币", [str(运行数据.bonus_gold)]))
	
	
	func 当界面奖励金币鼠标退出() -> void:
		_信息弹窗.hide()
	
	
	func 当实体生成器玩家已生成(玩家数组: Array[Node]) -> void:
		_玩家 = 玩家数组
		_摄像机.targets = 玩家数组
		_浮动文本管理器.players = _玩家
	
		效果行为服务.update_active_effect_behaviors()
	
		if _玩家.size() > 1:
			_伤害晕影.active = false
	
		_玩家界面.clear()
		for i in _玩家.size():
			var 效果数组 = 运行数据.获取玩家效果数组(i)
	
			var 玩家界面元素: 玩家界面元素 = 玩家界面元素.new()
			var 玩家索引字符串 = str(i + 1)
	
			玩家界面元素.玩家索引 = i
			玩家界面元素.玩家生命条 = get_node("%%PlayerLifeBarContainerP%s/PlayerLifeBarP%s" % [玩家索引字符串, 玩家索引字符串])
			玩家界面元素.玩家生命条容器 = get_node("%%PlayerLifeBarContainerP%s" % 玩家索引字符串)
			玩家界面元素.hud容器 = get_node("%%LifeContainerP%s" % 玩家索引字符串)
			玩家界面元素.生命条 = get_node("%%UILifeBarP%s" % 玩家索引字符串)
			玩家界面元素.生命标签 = get_node("%%UILifeBarP%s/MarginContainer/LifeLabel" % 玩家索引字符串)
			玩家界面元素.经验条 = get_node("%%UIXPBarP%s" % 玩家索引字符串)
			玩家界面元素.等级标签 = get_node("%%UIXPBarP%s/MarginContainer/LevelLabel" % 玩家索引字符串)
			玩家界面元素.金币 = get_node("%%UIGoldP%s" % 玩家索引字符串)
	
			玩家界面元素.生命标签.设置消息翻译(false)
			玩家界面元素.等级标签.设置消息翻译(false)
	
			_玩家界面.push_back(玩家界面元素)
	
			玩家界面元素.更新界面(_玩家[i])
			玩家界面元素.hud可见 = true
			玩家界面元素.设置界面位置(i)
	
			_玩家[i].获取生命条远程变换().remote_path = 玩家界面元素.玩家生命条容器.get_path()
			_玩家[i].current_stats.health = maxi(1, _玩家[i].max_stats.health * (效果数组["hp_start_wave"] / 100.0)) as int
	
			if 效果数组["hp_start_next_wave"] != 100:
				_玩家[i].current_stats.health = maxi(1, _玩家[i].max_stats.health * (效果数组["hp_start_next_wave"] / 100.0)) as int
				效果数组["hp_start_next_wave"] = 100
	
			_玩家[i].检查生命值恢复()
	
			_当玩家生命值更新(_玩家[i], _玩家[i].current_stats.health, _玩家[i].max_stats.health)
	
			var _错误玩家生命值 = _玩家[i].health_updated.connect(_当玩家生命值更新)
			var _错误治疗文本 = _玩家[i].healed.connect(_浮动文本管理器._当玩家被治疗)
			var _错误死亡 = _玩家[i].died.connect(_当玩家死亡)
			var _错误受到伤害 = _玩家[i].took_damage.connect(_屏幕震动器._当玩家受到伤害)
			var _错误被治疗 = _玩家[i].healed.connect(当玩家被治疗)
			var _错误想要生成金币 = _玩家[i].wanted_to_spawn_gold.connect(当玩家想要生成金币)
	
	func 处理状态伤害(状态伤害: Array, 玩家索引: int) -> Array:
		var 总伤害值 = 0
		var 已造成伤害 = [0, 0]
		var 追踪值: Dictionary = {}
	
		if 状态伤害.is_empty():
		return 已造成伤害

	var 状态字典 = {}
	var 百分比伤害加成 = 1 + 工具.获取属性("stat_percent_damage", 玩家索引) / 100.0
	for 伤害数据 in 状态伤害:

		if randf() >= 伤害数据[2] / 100.0:
			continue

		var 伤害字典 = 状态字典.get(伤害数据[0])
			if not 伤害字典:
				伤害字典 = {"stat": 工具.获取属性(伤害数据[0], 玩家索引)}
			状态字典[伤害数据[0]] = 伤害字典
		var 伤害值 = 伤害字典.get(伤害数据[1])
		if not 伤害值:
			var 基础伤害: int = floor(maxi(1, 伤害数据[1] / 100.0 * 伤害字典["stat"]))
			伤害值 = round(基础伤害 * 百分比伤害加成) as int
			伤害字典[伤害数据[1]] = 伤害值
		总伤害值 += 伤害值

		var 追踪键: String = 伤害数据[3] if 伤害数据.size() == 4 else ""
		if 追踪键 != "":
			if 追踪键 in 追踪值:
				追踪值[追踪键] += 伤害值
			else:
				追踪值[追踪键] = 伤害值

	if 总伤害值 <= 0:
		return 已造成伤害

	var 敌人列表: Array[Node] = _实体生成器.get_all_enemies()
	var 随机敌人 = 工具.获取随机元素(敌人列表)
	if 随机敌人 == null or not is_instance_valid(随机敌人) or 随机敌人.current_stats.health == 0:
		return 已造成伤害

	var 伤害参数 = 造成伤害参数.new(玩家索引)
	已造成伤害 = 随机敌人.造成伤害(总伤害值, 伤害参数)
	
		var 剩余待追踪伤害: int = 已造成伤害[1]
		for 追踪键 in 追踪值.keys():
			var 追踪值数据 = 追踪值[追踪键]
	
			if 追踪值数据 <= 剩余待追踪伤害:
				运行数据.添加追踪值(玩家索引, 追踪键, 追踪值数据)
				剩余待追踪伤害 -= 追踪值数据
	
			else:
				运行数据.添加追踪值(玩家索引, 追踪键, 剩余待追踪伤害)
				break
	
		return 已造成伤害
	
	
	func 检查半血状态(玩家索引: int) -> void:
		var 半血状态效果 = 运行数据.获取玩家效果("stats_below_half_health", 玩家索引)
		if 半血状态效果.size() == 0:
			return 
	
		var 当前生命值 = _玩家[玩家索引].current_stats.health
		var 最大生命值 = _玩家[玩家索引].max_stats.health
		if 当前生命值 < (最大生命值 / 2.0) and not _玩家是否半血[玩家索引]:
			_玩家是否半血[玩家索引] = true
			for 状态 in 半血状态效果:
				临时统计.添加属性(状态[0], 状态[1], 玩家索引)
				运行数据.发出信号("stat_added", 状态[0], 状态[1], 0.0, 玩家索引)
	
		elif 当前生命值 >= 最大生命值 / 2.0 and _玩家是否半血[玩家索引]:
			_玩家是否半血[玩家索引] = false
			for 状态 in 半血状态效果:
				临时统计.移除属性(状态[0], 状态[1], 玩家索引)
				运行数据.发出信号("stat_removed", 状态[0], 状态[1], 0.0, 玩家索引)
	
	
	func 当玩家生命值更新(玩家: 玩家, 当前值: int, 最大值: int) -> void:
		var 玩家索引 = 玩家.player_index
		运行数据.players_data[玩家索引].current_health = 当前值
	
		if 玩家.player_index == 0 and not 运行数据.is_coop_run:
			_伤害晕影.根据生命值更新(当前值, 最大值)
	
		检查半血状态(玩家索引)
	
		var 玩家界面元素: 玩家界面元素 = _玩家界面[玩家索引]
		var 生命条 = 玩家界面元素.life_bar
		生命条.更新值(当前值, 最大值)
	
		var 玩家生命条 = 玩家界面元素.player_life_bar
		玩家生命条.visible = 进度数据.settings.hp_bar_on_character and 当前值 != 最大值 and not 玩家.dead
		if 玩家生命条.visible:
			玩家生命条.更新值(当前值, 最大值)
	
		玩家界面元素.更新生命标签(玩家)
	
	
	func 当金币改变(新值: int, 玩家索引: int) -> void:
		var 玩家界面元素: 玩家界面元素 = _玩家界面[玩家索引]
		玩家界面元素.gold.更新值(新值)
	
	
	func 当伤害效果(值: int, 玩家索引: int, 护甲已应用: bool, 可闪避: bool) -> void:
		_玩家[玩家索引].当伤害效果(值, 护甲已应用, 可闪避)
	
	
	func 当生命偷取效果(值: int, 玩家索引: int) -> void:
		var 玩家: 玩家 = _玩家[玩家索引]
		玩家.当生命偷取效果(值)
	
	
	func 当治疗效果(值: int, 玩家索引: int, 追踪键: String = "") -> void:
		_玩家[玩家索引].当治疗效果(值, 追踪键)
	
	
	func 当持续治疗效果(总治疗量: int, 持续时间: int, 玩家索引: int) -> void:
		_玩家[玩家索引].当持续治疗效果(总治疗量, 持续时间)
	
	
	
	
	
	func 当半秒计时器超时(玩家索引: int) -> void:
		if 链接统计.update_for_player_every_half_sec[玩家索引]:
			链接统计.reset_player(玩家索引)
	
	
	func 当游戏失去焦点() -> void:
		if not _重试波次.visible:
			_暂停菜单.当游戏失去焦点()
	
	
	func 从池中获取节点(文件名: String) -> Node:
		if _池.has(文件名):
			return _池[文件名].pop_back()
		else:
			_池[文件名] = []
			return null
	
	
	func 添加节点到池中(节点: Node) -> void:
		if _池.has(节点.scene_file_path):
			call_deferred("_添加节点到池中", 节点)
		else:
			节点.queue_free()
	
	
	func 添加节点到池中(节点: Node) -> void:
		assert(not 节点 in _池[节点.scene_file_path])
		_池[节点.scene_file_path].push_back(节点)
	
	
	func 添加爆炸(爆炸实例: 玩家爆炸) -> void:
		_爆炸容器.add_child(爆炸实例)
	
	
	func 添加效果(效果实例: Node) -> void:
		_效果容器.add_child(效果实例)
	
	
	func 添加浮动文本(文本实例: 浮动文本) -> void:
		_浮动文本容器.add_child(文本实例)
	
	
	func 添加玩家投射物(投射物实例: 玩家投射物) -> void:
		_玩家投射物.add_child(投射物实例)
	
	
	func 添加敌人投射物(投射物实例: 投射物) -> void:
		_敌人投射物.add_child(投射物实例)
	
	
	func 添加出生效果(出生实例: 实体出生) -> void:
		_出生容器.add_child(出生实例)
	
	
	func 添加实体(实体实例: 实体) -> void:
		_实体容器.add_child(实体实例)
	
	
	func 退出场景树() -> void:
		输入服务.set_gamepad_echo_processing(true)
	
	
	func 当半波计时器超时() -> void:
		for 玩家索引 in 运行数据.get_player_count():
			工具.convert_stats(运行数据.获取玩家效果("convert_stats_half_wave", 玩家索引), 玩家索引, false)
	
		if 运行数据.concat_all_player_effects("convert_stats_half_wave").size() > 0:
			_波次计时器标签.更改颜色(Color.DEEP_SKY_BLUE)
