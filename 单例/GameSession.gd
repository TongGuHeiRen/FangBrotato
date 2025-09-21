extends Node

signal 金币变化(值:int)
signal 生命变化(值:int)
signal 波次变化(索引:int)
signal 游戏结束(胜利:bool)

var 金币: int = 0
var 生命: int = 100
var 波次索引: int = 0
var 正在进行: bool = false

func 重置() -> void:
	金币 = 0
	生命 = 100
	波次索引 = 0
	正在进行 = true
	金币变化.emit(金币)
	生命变化.emit(生命)
	波次变化.emit(波次索引)

func 增加金币(n: int) -> void:
	金币 += n
	金币变化.emit(金币)

func 扣除生命(n: int) -> void:
	生命 = max(0, 生命 - n)
	生命变化.emit(生命)
	if 生命 <= 0:
		结束游戏(false)

func 设置波次(索引: int) -> void:
	波次索引 = 索引
	波次变化.emit(波次索引)

func 结束游戏(胜利: bool) -> void:
	正在进行 = false
	游戏结束.emit(胜利)

