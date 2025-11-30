class_name MutationAttackConfig

extends BaseAttackConfig

@export_category("Mutation Parameters")
## Урон от лужи.
@export var damage: DamageData = DamageData.new()
## Начальный радиус лужи.
@export var initial_radius: float = 15.0
## Конечный радиус лужи.
@export var final_radius: float = 50.0
## Время расширения лужи от начальный радиус -> конечный радиус.
@export var expansion_time: float = 0.8
## Время, которое лужа лежит на полу.
@export var damage_duration: float = 1.0
## Внутренний кулдаун для параллельного исполнения атаки.
@export var cooldown_time: float = 3.0

func get_parameters_dict() -> Dictionary:
	var parameters = super.get_parameters_dict()
	parameters["damage"] = damage
	parameters["initial_radius"] = initial_radius
	parameters["final_radius"] = final_radius
	parameters["expansion_time"] = expansion_time
	parameters["damage_duration"] = damage_duration
	parameters["cooldown_time"] = cooldown_time
	return parameters
