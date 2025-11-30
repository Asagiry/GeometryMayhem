class_name SpiralAttackConfig

extends BaseAttackConfig

@export_category("Spiral Parameters")
## Время исполнения spiral атаки.
@export var duration: float = 10.0
## Скорость вращения каждого tentacle в градусах.
@export var rotation_speed: float = 1.0
## Внутренний кулдаун для параллельного исполнения атаки.
@export var cooldown_time: float = 3.0

func get_parameters_dict() -> Dictionary:
	var parameters = super.get_parameters_dict()
	parameters["duration"] = duration
	parameters["rotation_speed"] = rotation_speed
	parameters["cooldown_time"] = cooldown_time
	return parameters
