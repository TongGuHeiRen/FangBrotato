extends Node

# 游戏管理器脚本
# 负责管理游戏状态、敌人生成和波次系统

# 游戏状态变量
var 金币: int = 0
var 生命值: int = 100
var 当前波次: int = 1
var 游戏进行中: bool = false

# 敌人生成相关
var 敌人生成计时器: Timer
var 敌人生成间隔: float = 2.0  # 秒
var 敌人场景: PackedScene

# 波次系统相关
var 波次计时器: Timer
var 波次持续时间: float = 30.0  # 秒
var 当前波次敌人数量: int = 5
var 当前波次已生成敌人: int = 0

# 主场景引用
var 主场景: Node

# 信号定义
signal 金币更新(新金币: int)
signal 生命值更新(新生命值: int)
signal 波次更新(新波次: int)
signal 游戏结束

# 初始化函数
func _init() -> void:
	# 初始化游戏状态
	重置游戏状态()
	
	# 创建计时器
	敌人生成计时器 = Timer.new()
	敌人生成计时器.wait_time = 敌人生成间隔
	敌人生成计时器.one_shot = false
	敌人生成计时器.autostart = false
	敌人生成计时器.timeout.connect(_on_enemy_spawn_timer_timeout)
	
	波次计时器 = Timer.new()
	波次计时器.wait_time = 波次持续时间
	波次计时器.one_shot = true
	波次计时器.autostart = false
	波次计时器.timeout.connect(_on_wave_timer_timeout)

# 设置主场景引用
func 设置主场景(场景: Node) -> void:
	主场景 = 场景

# 重置游戏状态
func 重置游戏状态() -> void:
	金币 = 0
	生命值 = 100
	当前波次 = 1
	游戏进行中 = false
	当前波次敌人数量 = 5
	当前波次已生成敌人 = 0

# 开始游戏
func 开始游戏() -> void:
	游戏进行中 = true
	敌人生成计时器.start()
	波次计时器.start()
	print("游戏开始")

# 暂停游戏
func 暂停游戏() -> void:
	游戏进行中 = false
	敌人生成计时器.stop()
	波次计时器.stop()
	print("游戏暂停")

# 恢复游戏
func 恢复游戏() -> void:
	游戏进行中 = true
	敌人生成计时器.start()
	波次计时器.start()
	print("游戏恢复")

# 结束游戏
func 结束游戏() -> void:
	游戏进行中 = false
	敌人生成计时器.stop()
	波次计时器.stop()
	游戏结束.emit()
	print("游戏结束")

# 更新金币
func 更新金币(数量: int) -> void:
	金币 += 数量
	金币更新.emit(金币)

# 更新生命值
func 更新生命值(数量: int) -> void:
	生命值 += 数量
	if 生命值 <= 0:
		生命值 = 0
		结束游戏()
	生命值更新.emit(生命值)

# 开始新波次
func 开始新波次() -> void:
	当前波次 += 1
	当前波次敌人数量 = 5 + (当前波次 - 1) * 2  # 每波增加2个敌人
	当前波次已生成敌人 = 0
	波次计时器.start()
	波次更新.emit(当前波次)
	print("开始第", 当前波次, "波，敌人数量:", 当前波次敌人数量)

# 敌人生成计时器超时处理
func _on_enemy_spawn_timer_timeout() -> void:
	if 游戏进行中 and 当前波次已生成敌人 < 当前波次敌人数量:
		生成敌人()
		当前波次已生成敌人 += 1
		print("已生成敌人:", 当前波次已生成敌人, "/", 当前波次敌人数量)

# 波次计时器超时处理
func _on_wave_timer_timeout() -> void:
	if 游戏进行中:
		开始新波次()

# 生成敌人
func 生成敌人() -> void:
	if not 敌人场景 or not 主场景:
		return
	
	# 实例化敌人场景
	var 敌人实例: Node = 敌人场景.instantiate()
	
	# 将敌人添加到主场景中
	主场景.add_child(敌人实例)
	
	# 设置敌人随机位置
	var 屏幕大小: Vector2 = 主场景.get_viewport_rect().size
	敌人实例.position.x = randf_range(50, 屏幕大小.x - 50)
	敌人实例.position.y = randf_range(50, 屏幕大小.y - 50)
	
	print("生成一个敌人")

# 设置敌人场景
func 设置敌人场景(场景: PackedScene) -> void:
	敌人场景 = 场景