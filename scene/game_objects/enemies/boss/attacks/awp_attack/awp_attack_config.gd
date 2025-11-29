class_name AwpAttackConfig

extends BaseAttackConfig

@export_category("AWP Parameters")
@export var damage: DamageData = DamageData.new()
@export var aim_duration: float = 2.0
@export var delay_before_attack: float = 0.5
@export var number_of_shots: int = 1
@export var time_between_shots: float = 0.2

func get_parameters_dict() -> Dictionary:
	var parameters = super.get_parameters_dict()
	parameters["damage"] = damage
	parameters["aim_duration"] = aim_duration
	parameters["delay_before_attack"] = delay_before_attack
	parameters["number_of_shots"] = number_of_shots
	parameters["time_between_shots"] = time_between_shots
	return parameters
