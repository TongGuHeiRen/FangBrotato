class_name 武器
extends Node2D

signal 请求破坏武器(武器, 掉落金币数量)
signal 请求重置炮塔冷却时间

const 检测范围: = 200
@export var 自定义击中音效: Array[Resource] = []
var 武器位置: = -1
var 武器属性: Resource
var 索引: = 0

var 效果列表: = []
var 当前属性: = 武器属性.new()

var _父节点: Node

var _闲置角度: = 0.0
var _当前闲置角度: = _闲置角度
var _当前冷却时间: float = 0
var _是否正在射击: = false

var _当前目标: = []
var _范围内目标列表: = []
var _原始精灵图 = null

@onready var 枪口位置: Position2D = $Sprite/Muzzle
@onready var 补间动画: Tween = $Tween
@onready var 精灵图: Sprite = $Sprite
@onready var _攻击框: Area2D = $Sprite/Hitbox
@onready var _附加点: Position2D = $Attach
@onready var _检测范围区域: Area2D = $Range
@onready var _检测范围形状: CollisionShape2D = $Range/CollisionShape2D
@onready var _射击行为: WeaponShootingBehavior = $ShootingBehavior


func _ready() -> void:
	_原始精灵图 = 精灵图.texture
	更新精灵图(_原始精灵图)

	_父节点 = get_parent().get_parent()

	禁用攻击框()
	var _初始化行为 = _射击行为.init(self)

	初始化属性()





func 初始化属性(在波次开始时: bool = true) -> void:
	# 简化属性初始化，只设置基础属性
	if 武器属性 is 远程武器属性:
		当前属性 = 武器服务.初始化远程属性(武器属性, 0, false, null)
	else:
		当前属性 = 武器服务.初始化近战属性(武器属性, 0, null)

	_攻击框.击中时投射物 = []
	当前属性.burning_data.来源 = self

	var 攻击框参数: = Hitbox.攻击框参数.new().从武器属性设置(当前属性)
	_攻击框.效果缩放 = 当前属性.effect_scale
	_攻击框.设置伤害(当前属性.damage, 攻击框参数)
	_攻击框.速度百分比修饰符 = 当前属性.speed_percent_modifier
	_攻击框.效果 = []
	_攻击框.来源 = self

	if 在波次开始时:
		_当前冷却时间 = 获取下一个冷却时间(在波次开始时)

	重置冷却时间()
	_检测范围形状.shape.radius = 当前属性.max_range + 检测范围


func _process(_delta: float) -> void:
	更新精灵图水平翻转()
	更新闲置角度()


func 附加到(附加到位置: Vector2, 附加闲置角度: float) -> void:
	position = 附加到位置 - _附加点.position
	_闲置角度 = 附加闲置角度


func _physics_process(delta: float) -> void:
	if _是否正在射击:
		rotation = 获取方向()
	else:
		rotation = 获取方向并计算目标()

	if not _是否正在射击:
		_当前冷却时间 = max(_当前冷却时间 - 工具类.物理时间步长(delta), 0)

	if _当前冷却时间 <= 10 and 精灵图.texture == 武器属性.custom_on_cooldown_sprite:
		更新精灵图(_原始精灵图)

	if 是否应该射击():
		射击()







func 更新精灵图(新精灵图: Texture) -> void:
	精灵图.texture = 皮肤管理器.获取皮肤(新精灵图)





func 获取最大射程() -> int:
	return 当前属性.max_range + 50


func 获取方向并计算目标() -> Vector2:
	if _范围内目标列表.size() == 0:
		return Vector2.ZERO

	# 保留自动瞄准功能
	if 当前属性.auto_aim:
		var 目标 = 工具类.获取最近目标(_范围内目标列表, global_position)
		if 目标 == null:
			return Vector2.ZERO
		return 目标.global_position - global_position

	return Vector2.ZERO


func 获取方向() -> float:
	if _当前目标.size() == 0 or not is_instance_valid(_当前目标[0]):
		return rotation if _是否正在射击 else 获取方向并计算目标()
	else:
		var 到目标的方向 = (_当前目标[0].global_position - global_position).angle()
		return 到目标的方向


func 是否应该射击() -> bool:
	if _是否正在射击:
		return false

	return (_当前冷却时间 == 0
		 and 
		(
			(
				_当前目标.size() > 0
				 and is_instance_valid(_当前目标[0])
				 and 工具类.是否在范围内(_当前目标[1], 当前属性.min_range, 获取最大射程())
			)
		)
	)


func 射击() -> void:
	更新击退效果()
	_射击行为.shoot(_当前目标[1])
	_当前冷却时间 = 获取下一个冷却时间()

	if 武器属性.custom_on_cooldown_sprite != null:
		更新精灵图(武器属性.custom_on_cooldown_sprite)


func 重置冷却时间() -> void:
	_当前冷却时间 = min(_当前冷却时间, 当前属性.cooldown)


func 获取下一个冷却时间(在波次开始时: bool = false) -> float:
	var 冷却基础值 = 当前属性.cooldown
	
	if 在波次开始时 and 冷却基础值 >= 180:
		冷却基础值 = 180

	return 冷却基础值











func 更新击退效果() -> void:
	var 击退方向: = Vector2(cos(rotation), sin(rotation))
	_攻击框.设置击退(击退方向, 当前属性.knockback, 当前属性.knockback_piercing)


func 设置射击状态(值: bool) -> void:
	_是否正在射击 = 值


func 禁用攻击框() -> void:
	_攻击框.忽略物体列表.clear()
	_攻击框.禁用()


func 启用攻击框() -> void:
	_攻击框.启用()





func 更新精灵图水平翻转() -> void:
	if 工具类.是否面向右方(rotation_degrees):
		精灵图.flip_v = false
	else:
		精灵图.flip_v = true


func 更新闲置角度() -> void:
	if _父节点.get_direction() == 1:
		_当前闲置角度 = _闲置角度
	else:
		_当前闲置角度 = PI - _闲置角度


func _当检测范围物体进入(物体: Node) -> void:
	_范围内目标列表.push_back(物体)
	物体死亡.connect(当目标死亡时.bind(物体))


func _当检测范围物体离开(物体: Node) -> void:
	_范围内目标列表.erase(物体)
	if _当前目标.size() > 0 and 物体 == _当前目标[0]:
		_当前目标.clear()
	if 物体死亡.is_connected(当目标死亡时):
		物体死亡.disconnect(当目标死亡时)


func 当目标死亡时(目标: Node, _参数: Entity.DieArgs) -> void:
	_范围内目标列表.erase(目标)
	if _当前目标.size() > 0 and 目标 == _当前目标[0]:
		_当前目标.clear()


func _on_Hitbox_hit_something(被击中的物体: Node, 造成的伤害: int) -> void:
	_攻击框.忽略物体列表.push_back(被击中的物体)
	当武器击中某物时(被击中的物体, 造成的伤害, _攻击框)

	if 自定义击中音效.size() > 0:
		音效管理器2D.播放(工具类.获取随机元素(自定义击中音效), 被击中的物体.global_position, - 2, 0.1)




func 当武器击中某物时(_被击中的物体: Node, 造成的伤害: int, 攻击框: Hitbox) -> void:
	# 简化击中处理，只保留基础功能
	if 攻击框 == null:
		return 

	for 效果 in 效果列表:
		if 效果.key == "击中时破坏":
			if 工具类.获取几率成功(效果.value / 100.0):
				请求破坏武器.emit(self, 效果.value2)
