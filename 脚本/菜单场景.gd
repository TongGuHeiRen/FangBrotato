extends Control

# 菜单场景脚本
# 处理游戏菜单的显示和交互

# 节点引用
@onready var 背景面板 = $背景面板
@onready var 按钮容器 = $按钮容器
@onready var 继续按钮 = $按钮容器/继续按钮
@onready var 重新开始按钮 = $按钮容器/重新开始按钮
@onready var 退出按钮 = $按钮容器/退出按钮

func _ready():
	# 初始化菜单
	print("菜单场景已准备")
	
	# 设置背景面板样式
	背景面板.modulate = Color(0.0, 0.0, 0.0, 0.8)  # 半透明黑色背景
	
	# 设置按钮样式
	设置按钮样式(继续按钮)
	设置按钮样式(重新开始按钮)
	设置按钮样式(退出按钮)
	
	# 默认聚焦继续按钮
	继续按钮.grab_focus()

# 设置按钮样式
func 设置按钮样式(按钮: Button):
	# 设置按钮大小
	按钮.custom_minimum_size = Vector2(200, 50)
	
	# 设置按钮字体大小
	按钮.add_theme_font_size_override("font_size", 20)

# 继续按钮点击处理
func _当继续按钮被点击():
	print("继续按钮被点击")
	# 这个信号会由MainScene.gd处理

# 重新开始按钮点击处理
func _当重新开始按钮被点击():
	print("重新开始按钮被点击")
	# 这个信号会由MainScene.gd处理

# 退出按钮点击处理
func _当退出按钮被点击():
	print("退出按钮被点击")
	# 这个信号会由MainScene.gd处理