extends CharacterBody2D

signal 已死亡(奖励金币:int)

@export var 速度: float = 100.0
@export var 生命: int = 3
@export var 目标路径: NodePath

@onready var 敌人图像: Sprite2D = $"敌人图像"
@onready var 碰撞形状: CollisionShape2D = $"碰撞形状"

var _目标: Node2D = null

func 初始化(目标: Node2D) -> void:
	_目标 = 目标
	if is_instance_valid(_目标):
		目标路径 = _目标.get_path()

func 移动(目标位置: Vector2) -> void:
	var 方向 = (目标位置 - global_position)
	if 方向.length() > 0.001:
		方向 = 方向.normalized()
		velocity = 方向 * 速度
		move_and_slide()

func 追踪玩家(时间增量: float) -> void:
	var 目标节点: Node2D = _获取目标()
	if 目标节点:
		移动(目标节点.global_position)

func 受到伤害(伤害值: int) -> void:
	生命 -= 伤害值
	if 生命 <= 0:
		死亡()

func 死亡() -> void:
	emit_signal("已死亡", 1)
	queue_free()

func _获取目标() -> Node2D:
	if _目标 and is_instance_valid(_目标):
		return _目标
	if 目标路径 != NodePath(""):
		var 节点 = get_node_or_null(目标路径)
		if 节点 and 节点 is Node2D:
			_目标 = 节点
			return _目标
	return null

func _physics_process(时间增量: float) -> void:
	追踪玩家(时间增量)
