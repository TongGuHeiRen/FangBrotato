extends CanvasLayer

signal 请求打开菜单()

@onready var 金币标签: Label = $"金币标签"
@onready var 生命值标签: Label = $"生命值标签"
@onready var 波次标签: Label = $"波次标签"
@onready var 计时标签: Label = $"计时标签"
@onready var 菜单按钮: Button = $"菜单按钮"

func _ready() -> void:
	if 菜单按钮:
		菜单按钮.pressed.connect(func(): 请求打开菜单.emit())

func 设置金币(金币数量: int) -> void:
	金币标签.text = "金币: %d" % 金币数量

func 设置生命(生命值: int) -> void:
	生命值标签.text = "生命值: %d" % 生命值

func 设置波次(波次索引: int) -> void:
	波次标签.text = "波次: %d" % 波次索引

func 设置计时(剩余秒数: float) -> void:
	计时标签.text = "计时: %.1f" % 剩余秒数

