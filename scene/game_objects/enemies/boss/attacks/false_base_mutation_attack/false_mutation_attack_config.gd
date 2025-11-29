class_name MutationAttackConfig

extends BaseAttackConfig

@export_category("Mutation Parameters")
@export var damage: DamageData = DamageData.new()
@export var initial_radius: float = 15.0
@export var final_radius: float = 50.0
@export var expansion_time: float = 0.8
@export var damage_duration: float = 1.0

func get_parameters_dict() -> Dictionary:
	var parameters = super.get_parameters_dict()
	parameters["damage"] = damage
	parameters["initial_radius"] = initial_radius
	parameters["final_radius"] = final_radius
	parameters["expansion_time"] = expansion_time
	parameters["damage_duration"] = damage_duration
	return parameters
