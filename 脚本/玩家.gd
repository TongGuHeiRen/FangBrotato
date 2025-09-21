extends CharacterBody2D

# 玩家属性
@export var 生命值: int = 100
@export var 移动速度: float = 200.0
@export var 攻击力: int = 10

# 信号定义
signal 生命值变化(新生命值)

# 节点引用
@onready var 玩家图像 = $玩家图像
@onready var 碰撞形状 = $碰撞形状
@onready var 攻击区域 = $攻击区域

# 移动函数
func 移动(方向: Vector2):
	# 根据传入的方向移动玩家
	# 在Godot 4.x中，CharacterBody2D使用velocity和move_and_slide来移动
	velocity = 方向 * 移动速度
	move_and_slide()
	
	# 如果有移动方向，翻转玩家图像朝向
	if 方向.x != 0:
		玩家图像.flip_h = 方向.x < 0

# 攻击函数
func 攻击():
	# 执行玩家攻击逻辑
	print("玩家执行攻击，攻击力:", 攻击力)
	
	# 检测攻击区域内的敌人
	var 敌人列表 = 攻击区域.get_overlapping_bodies()
	for 敌人 in 敌人列表:
		if 敌人.has_method("受到伤害"):
			敌人.受到伤害(攻击力)
	
	# 这里可以添加攻击动画等其他效果

# 受到伤害函数
func 受到伤害(伤害值: int):
	# 减少玩家生命值，检查是否死亡
	print("玩家受到", 伤害值, "点伤害")
	生命值 -= 伤害值
	
	# 发射生命值变化信号
	emit_signal("生命值变化", 生命值)
	
	# 检查是否死亡
	if 生命值 <= 0:
		死亡()

# 死亡函数
func 死亡():
	print("玩家死亡")
	# 这里可以添加死亡动画、游戏结束等逻辑
	queue_free()  # 从场景中移除玩家

func _ready():
	# 初始化代码
	print("玩家角色已准备")
	
	# 将玩家添加到"玩家"组中，以便敌人可以找到玩家
	add_to_group("玩家")

func _physics_process(delta):
	# 处理玩家输入
	处理输入()

# 处理玩家输入函数
func 处理输入():
	# 获取移动方向
	var 移动方向 = Vector2.ZERO
	
	# 检查键盘输入
	if Input.is_action_pressed("ui_right"):
		移动方向.x += 1
	if Input.is_action_pressed("ui_left"):
		移动方向.x -= 1
	if Input.is_action_pressed("ui_down"):
		移动方向.y += 1
	if Input.is_action_pressed("ui_up"):
		移动方向.y -= 1
	
	# 如果有移动方向，则移动玩家
	if 移动方向 != Vector2.ZERO:
		移动方向 = 移动方向.normalized()  # 标准化向量，确保对角线移动不会更快
		移动(移动方向)
	
	# 检查攻击输入
	if Input.is_action_just_pressed("ui_accept"):
		攻击()

func _process(delta):
	# 每帧执行的代码
	pass
