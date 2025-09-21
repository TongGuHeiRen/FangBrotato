extends Node

signal 波次开始(索引:int, 时长:float)
signal 波次结束(索引:int, 胜利:bool)
signal 请求生成(数量:int)

@export var 波次表: Array[Dictionary] = [
	{"持续秒": 15.0, "每秒": 1, "数量上限": 20},
	{"持续秒": 20.0, "每秒": 2, "数量上限": 40}
]
@export var 起始索引: int = 0

@onready var 波次计时器: Timer = $"波次计时器"
@onready var 间隔计时器: Timer = $"间隔计时器"

var _当前索引: int = -1
var _当前配置: Dictionary = {}
var _已生成总数: int = 0
var _活动中: bool = false

func 开始波次(波次索引: int = 起始索引) -> void:
	if 波次索引 < 0 or 波次索引 >= 波次表.size():
		波次结束.emit(波次索引, true)
		return
	_当前索引 = 波次索引
	_已生成总数 = 0
	_当前配置 = 波次表[波次索引]
	var 时长: float = _当前配置.get("持续秒", 10.0)
	var 每秒数量: int = _当前配置.get("每秒", 1)
	_活动中 = true
	波次开始.emit(波次索引, 时长)
	波次计时器.one_shot = true
	波次计时器.start(时长)
	间隔计时器.one_shot = false
	间隔计时器.wait_time = 1.0
	间隔计时器.start()
	# 保存本轮每秒配置
	set_meta("_每秒", 每秒数量)
	set_meta("_上限", _当前配置.get("数量上限", 9999))

func 结束当前波次(胜利: bool) -> void:
	间隔计时器.stop()
	波次计时器.stop()
	_活动中 = false
	波次结束.emit(_当前索引, 胜利)

func 获取当前剩余时间() -> float:
	return 波次计时器.time_left

func _on_间隔超时() -> void:
	var 每秒生成数量: int = int(get_meta("_每秒", 1))
	var 生成上限: int = int(get_meta("_上限", 9999))
	if _已生成总数 >= 生成上限:
		间隔计时器.stop()
		return
	请求生成.emit(每秒生成数量)
	_已生成总数 += 每秒生成数量

func _ready() -> void:
	if 间隔计时器:
		间隔计时器.timeout.connect(_on_间隔超时)
	if 波次计时器:
		波次计时器.timeout.connect(func():
			间隔计时器.stop()
			波次结束.emit(_当前索引, true)
			# 自动开始下一波
			call_deferred("开始波次", _当前索引 + 1)
		)
