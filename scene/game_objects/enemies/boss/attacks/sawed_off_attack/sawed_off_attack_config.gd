class_name SawedOffAttackConfig

extends BaseAttackConfig

@export_category("SawedOff Parameters")
## Урон от одного снаряда.
@export var damage: DamageData = DamageData.new()
## Скорость каждого снаряда.
@export var projectile_speed: float = 200.0
## Размер снаряда, изменяется animated_sprite_2d.scale.
@export var projectile_size: float = 1.0
## Количество снарядов в одной веерном выстреле.
@export var shots_per_burst: int = 1
## Угол по которому летят все снаряды.
@export var shots_angle: float = 30.0
## Внутренний кулдаун для параллельного исполнения атаки.
@export var cooldown_time: float = 3.0

func get_parameters_dict() -> Dictionary:
	var parameters = super.get_parameters_dict()
	parameters["damage"] = damage
	parameters["projectile_speed"] = projectile_speed
	parameters["projectile_size"] = projectile_size
	parameters["shots_per_burst"] = shots_per_burst
	parameters["shots_angle"] = shots_angle
	parameters["cooldown_time"] = cooldown_time
	return parameters
