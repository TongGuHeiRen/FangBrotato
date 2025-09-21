extends Control

signal 请求重开()

@onready var 标签: Label = $"标签"
@onready var 重开按钮: Button = $"重开按钮"

func _ready() -> void:
	if 重开按钮:
		重开按钮.pressed.connect(func(): 请求重开.emit())
	hide()

func 显示胜利(游戏统计: Dictionary) -> void:
	标签.text = "胜利!" 
	show()

func 显示失败(游戏统计: Dictionary) -> void:
	标签.text = "失败.." 
	show()

func 隐藏() -> void:
	hide()

