extends Node

# Main scene script for the mecha roguelike game
# This script handles the main game scene initialization and management

# 预加载场景和脚本
const 玩家场景 = preload("res://场景/玩家.tscn")
const 菜单场景 = preload("res://场景/菜单场景.tscn")
const 敌人场景 = preload("res://场景/敌人.tscn")
const 游戏管理器脚本 = preload("res://管理器/游戏管理器.gd")

# 实战2新增系统预加载
const 生成器场景 = preload("res://场景/生成器.tscn")
const 波次管理器场景 = preload("res://场景/波次管理器.tscn")
const 掉落场景 = preload("res://场景/掉落物.tscn")
const HUD场景 = preload("res://场景/HUD.tscn")
const 结果面板场景 = preload("res://场景/结果面板.tscn")


# onready变量引用子节点

@onready var 敌人容器 = $敌人容器
@onready var 掉落容器 = $掉落容器
@onready var UI根 = $UI层


# 实战2实例缓存
var 生成器实例
var 波次管理器实例
var HUD实例
var 结算面板实例

@onready var 地图 = $地图
@onready var 相机 = $相机
@onready var 金币标签 = $UI层/金币标签
@onready var 生命值标签 = $UI层/生命值标签
@onready var 波次标签 = $UI层/波次标签
@onready var 菜单按钮 = $UI层/菜单按钮
@onready var 背景 = $背景层/背景

# 游戏状态变量
var 玩家实例
var 游戏管理器
var 菜单实例
var 游戏暂停: bool = false

func _ready():
	# Initialize the game when the scene is ready
	print("主场景已加载")

	# 创建游戏管理器
	游戏管理器 = 游戏管理器脚本.new()
	add_child(游戏管理器)

	# 集成实战2系统
	_集成系统()


	# 连接信号（按钮点击等）
	菜单按钮.connect("pressed", Callable(self, "_on_menu_button_pressed"))

	# 连接游戏管理器信号
	游戏管理器.connect("金币更新", Callable(self, "_on_coins_updated"))
	游戏管理器.connect("生命值更新", Callable(self, "_on_health_updated"))
	游戏管理器.connect("波次更新", Callable(self, "_on_wave_updated"))
	游戏管理器.connect("游戏结束", Callable(self, "_on_game_over"))

	# 调用初始化场景方法
	初始化场景()

	# 更新UI显示
	更新金币显示()
	更新生命值显示()
	更新波次显示()

	# 开始游戏
	游戏管理器.开始游戏()

# 初始化场景方法
func 初始化场景():
	# 初始化地图
	初始化地图()
	# 生成玩家
	生成玩家()
	# 初始化游戏状态
	初始化游戏状态()
	print("场景初始化完成")

# 初始化地图方法
func 初始化地图():
	# 这里可以添加地图初始化逻辑
	# 例如设置地图大小、加载地图数据等
	print("地图初始化完成")

# 生成玩家方法
func 生成玩家():
	# 实例化玩家场景
	玩家实例 = 玩家场景.instantiate()

	# 将玩家添加到场景中
	add_child(玩家实例)

	# 设置玩家初始位置
	玩家实例.position = Vector2(0, 0)

	# 连接玩家信号
	玩家实例.connect("生命值变化", Callable(self, "_on_player_health_changed"))

	print("玩家角色已生成并添加到场景中")

# 初始化游戏状态方法
func 初始化游戏状态():
	# 设置相机
	相机.make_current()
	相机.position = Vector2(0, 0)
	相机.position_smoothing_enabled = true
	相机.position_smoothing_speed = 5.0

	# 设置敌人场景
	游戏管理器.设置敌人场景(敌人场景)

	# 设置主场景引用
	游戏管理器.设置主场景(self)

	print("游戏状态初始化完成")

# 更新金币显示方法
func 更新金币显示():
	金币标签.text = "金币: " + str(游戏管理器.金币)

# 更新生命值显示方法
func 更新生命值显示():
	生命值标签.text = "生命值: " + str(游戏管理器.生命值)

# 更新波次显示方法
func 更新波次显示():
	波次标签.text = "波次: " + str(游戏管理器.当前波次)

# 玩家生命值变化处理函数
func _当玩家生命值变化(新生命值):
	游戏管理器.更新生命值(新生命值 - 游戏管理器.生命值)

# 金币更新处理函数
func _当金币更新(新金币):
	更新金币显示()

# 生命值更新处理函数
func _当生命值更新(新生命值):
	更新生命值显示()

# 波次更新处理函数
func _当波次更新(新波次):
	更新波次显示()

# 游戏结束处理函数
func _当游戏结束():
	print("游戏结束")
	# 这里可以添加游戏结束逻辑，例如显示游戏结束画面
	# 暂停游戏
	游戏管理器.暂停游戏()
	# 显示菜单
	显示菜单()

# 菜单按钮点击处理函数
func _当菜单按钮被点击():
	print("菜单按钮已点击")
	if 菜单实例:
		隐藏菜单()
	else:
		显示菜单()

# 显示菜单
func 显示菜单():
	if 菜单实例:
		return

	# 暂停游戏
	游戏管理器.暂停游戏()
	游戏暂停 = true

	# 实例化菜单场景
	菜单实例 = 菜单场景.instantiate()

	# 连接菜单信号
	菜单实例.继续按钮.connect("pressed", Callable(self, "_当继续按钮被点击"))
	菜单实例.重新开始按钮.connect("pressed", Callable(self, "_当重新开始按钮被点击"))
	菜单实例.退出按钮.connect("pressed", Callable(self, "_当退出按钮被点击"))

	# 将菜单添加到场景中
	add_child(菜单实例)

	print("菜单已显示")

# 隐藏菜单
func 隐藏菜单():
	if not 菜单实例:
		return

	# 移除菜单
	菜单实例.queue_free()
	菜单实例 = null

	# 恢复游戏
	游戏管理器.恢复游戏()
	游戏暂停 = false

	print("菜单已隐藏")

# 继续按钮点击处理函数
func _当继续按钮被点击():
	print("继续按钮已点击")
	隐藏菜单()

# 重新开始按钮点击处理函数
func _当重新开始按钮被点击():
	print("重新开始按钮已点击")

	# 隐藏菜单
	隐藏菜单()

	# 重置游戏状态
	游戏管理器.重置游戏状态()

	# 移除当前玩家
	if 玩家实例:
		玩家实例.queue_free()

	# 重新初始化场景
	初始化场景()

	# 更新UI显示
	更新金币显示()
	更新生命值显示()
	更新波次显示()

# ==== 实战2 集成 ====
func _集成系统() -> void:
	# 实例化与脚本挂载
	生成器实例 = 生成器场景.instantiate()
	生成器实例.set_script(load("res://脚本/Spawner.gd"))
	波次管理器实例 = 波次管理器场景.instantiate()
	波次管理器实例.set_script(load("res://脚本/WaveManager.gd"))
	add_child(生成器实例)
	add_child(波次管理器实例)
	# 配置与连接
	if 生成器实例:
		生成器实例.敌人预设 = 敌人场景
		生成器实例.已生成.connect(_当敌人生成)
	if 波次管理器实例:
		波次管理器实例.请求生成.connect(func(数量): 生成器实例.生成一组(数量))
	# HUD
	HUD实例 = HUD场景.instantiate()
	HUD实例.set_script(load("res://脚本/Hud.gd"))
	UI根.add_child(HUD实例)
	if HUD实例.has_signal("请求打开菜单"):
		HUD实例.请求打开菜单.connect(Callable(self, "_当菜单按钮被点击"))
	# GameSession 信号到 HUD
	var 游戏会话 = get_node_or_null("/root/GameSession")
	if 游戏会话:
		游戏会话.金币变化.connect(func(金币值): HUD实例.设置金币(金币值))
		游戏会话.生命变化.connect(func(生命值): HUD实例.设置生命(生命值))
		游戏会话.波次变化.connect(func(波次索引): HUD实例.设置波次(波次索引))
	# 结果面板
	结算面板实例 = 结果面板场景.instantiate()
	结算面板实例.set_script(load("res://脚本/ResultPanel.gd"))
	UI根.add_child(结算面板实例)
	if 结算面板实例.has_signal("请求重开"):
		结算面板实例.请求重开.connect(func():
			清空容器()
			var 游戏会话1 = get_node_or_null("/root/GameSession")
			if 游戏会话1:
				游戏会话1.重置()
			波次管理器实例.开始波次(0)
		)
	# 启动
	var 游戏会话2 = get_node_or_null("/root/GameSession")
	if 游戏会话2:
		游戏会话2.重置()
	波次管理器实例.开始波次(0)

func _当敌人生成(敌人: Node) -> void:
	if 敌人:
		敌人容器.add_child(敌人)
		# 强制挂载正确的敌人脚本，覆盖错误引用
		敌人.set_script(load("res://脚本/Enemy.gd"))
		if 玩家实例 and 敌人.has_method("初始化"):
			敌人.初始化(玩家实例)
		if 敌人.has_signal("已死亡"):
			敌人.已死亡.connect(_当敌人死亡)

func _当敌人死亡(奖励金币: int) -> void:
	var 掉落物 = 掉落场景.instantiate()
	掉落物.set_script(load("res://脚本/Loot.gd"))
	掉落容器.add_child(掉落物)
	if 掉落物.has_signal("被拾取"):
		掉落物.被拾取.connect(func(拾取数量:int):
			var 游戏会话 = get_node_or_null("/root/GameSession")
			if 游戏会话:
				游戏会话.增加金币(拾取数量)
		)
	var 游戏会话 = get_node_or_null("/root/GameSession")
	if 游戏会话:
		游戏会话.增加金币(奖励金币)

func 清空容器() -> void:
	for 子节点 in 敌人容器.get_children():
		子节点.queue_free()
	for 子节点 in 掉落容器.get_children():
		子节点.queue_free()


	# 开始游戏
	游戏管理器.开始游戏()

# 退出按钮点击处理函数
func _当退出按钮被点击():
	print("退出按钮已点击")
	# 这里可以添加退出游戏的逻辑
	# 例如返回主菜单或退出应用程序
	get_tree().quit()

# _process方法，处理游戏逻辑
func _process(时间增量):
	# 每帧更新相机位置以跟随玩家
	if 玩家实例 and not 游戏暂停:
		相机.global_position = 玩家实例.global_position

	# 检查ESC键，用于打开/关闭菜单
	if Input.is_action_just_pressed("ui_cancel"):
		if 菜单实例:
			隐藏菜单()
		else:
			显示菜单()
