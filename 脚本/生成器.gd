extends Node2D

signal 已生成(敌人: Node)

@export var 敌人预设: PackedScene
@export var 刷新点: Array[Vector2] = []
@export var 每批数量: int = 1

@onready var 生成计时器: Timer = $"生成计时器"

func 生成一只() -> Node:
	if 敌人预设 == null:
		return null
	var 实例 = 敌人预设.instantiate()
	emit_signal("已生成", 实例)
	return 实例

func 生成一组(生成数量: int) -> void:
	var 数量 = max(1, 生成数量)
	for 索引 in 数量:
		生成一只()

func 清空() -> void:
	for 子节点 in get_children():
		if 子节点 is CharacterBody2D:
			子节点.queue_free()

