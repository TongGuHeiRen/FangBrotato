extends Area2D

signal 被拾取(数量:int)

@export var 金币值: int = 1
@export var 吸附半径: float = 64.0

func 被玩家拾取(玩家: Node) -> void:
	emit_signal("被拾取", 金币值)
	queue_free()

func 自动吸附到玩家(时间增量: float, 玩家: Node2D) -> void:
	if not 玩家:
		return
	var 距离 = 玩家.global_position.distance_to(global_position)
	if 距离 <= 吸附半径:
		global_position = global_position.lerp(玩家.global_position, min(1.0, 时间增量 * 10.0))

