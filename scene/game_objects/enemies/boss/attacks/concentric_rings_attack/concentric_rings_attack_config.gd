class_name ConcentricRingsAttackConfig

extends BaseAttackConfig

@export_category("ConcentricRings Parameters")
## Урон от касания любого снаряда из кольца.
@export var damage: DamageData = DamageData.new()
## Скорость вращения кольца в градусах. Каждый индекс соотвествует своему кольцу.
## Если не указать значение, то значениe будет DEFAULT_SPEED_OF_RING,
## которое записано в константу в ConcentricRingsAttackController.
@export var rings_speed: Array[float] = []
## Количество снарядов на каждой кольце. Каждый индекс соответствуем своему кольцу.
## Если не указать значение, то значение будет EFAULT_NUMBER_OF_PROJECTILES,
## которое записано в константу в ConcentricRingsAttackController.
@export var projectiles_per_ring: Array[int] = []
## Количество колец.
@export var number_of_rings: int = 2
## Расстояние между кольцами.
@export var distance_between_rings: float = 100.0
## Размер снаряда, изменяется animated_sprite_2d.scale.
@export var projectile_size: float = 1.0
## Время жизни колец. Если значение -1 или 0, то время жизни неограниченно, и кольца
## можно будет убрать только функцией destroy_concentric_rings() в
## ConcentricRingsAttackController.
@export var duration: float = 10.0
## Внутренний кулдаун для параллельного исполнения атаки.
@export var cooldown_time: float = 3.0

func get_parameters_dict() -> Dictionary:
	var parameters = super.get_parameters_dict()
	parameters["damage"] = damage
	parameters["rings_speed"] = rings_speed
	parameters["projectiles_per_ring"] = projectiles_per_ring
	parameters["number_of_rings"] = number_of_rings
	parameters["distance_between_rings"] = distance_between_rings
	parameters["projectile_size"] = projectile_size
	parameters["duration"] =  duration
	parameters["cooldown_time"] = cooldown_time
	return parameters
