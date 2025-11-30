class_name AwpAttackConfig

extends BaseAttackConfig

@export_category("AWP Parameters")
## Урон от одного выстрела.
@export var damage: DamageData = DamageData.new()
## Количество секунд стадии прицеливания, когда луч следует за игроком.
@export var aim_duration: float = 2.0
## Количество секунд между концом стадии прицеливании(когда луч встал) и
## самим выстрелом.
@export var delay_before_attack: float = 0.5
## Количество выстрелов.
@export var number_of_shots: int = 1
## Время между выстрелами.
@export var time_between_shots: float = 0.2
## Внутренний кулдаун для параллельного исполнения атаки.
@export var cooldown_time: float = 3.0

func get_parameters_dict() -> Dictionary:
	var parameters = super.get_parameters_dict()
	parameters["damage"] = damage
	parameters["aim_duration"] = aim_duration
	parameters["delay_before_attack"] = delay_before_attack
	parameters["number_of_shots"] = number_of_shots
	parameters["time_between_shots"] = time_between_shots
	parameters["cooldown_time"] = cooldown_time
	return parameters
