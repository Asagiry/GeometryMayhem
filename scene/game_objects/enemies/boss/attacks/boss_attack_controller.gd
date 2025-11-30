class_name BossAttackController
extends Node

signal stage_ready
signal sequential_attack_finished

const TYPE_TO_CONTROLLER = {
		"AwpAttackConfig": "AwpAttackController",
		"MutationAttackConfig": "FalseBaseMutationAttackController",
		"GifGloveAttackConfig": "GifGloveAttackController",
		"SawedOffAttackConfig": "SawedOffAttackController",
		"ConcentricRingsAttackConfig": "ConcentricRingsAttackController",
		"SummonAttackConfig": "SummonAttackController",
		"SpiralAttackConfig": "SpiralAttackController",
	}

@export var stages: Array[AttackStageConfig] = []

var attack_instances: Dictionary = {}  # Имя контроллера -> инстанс
var current_stage_attacks: Array[Node]
var current_stage_sequential_attacks: Array[Node]

@onready var cooldown_between_attacks: Timer = %CooldownBetweenAttacks

func _ready() -> void:
	_load_attack_instances()


func _load_attack_instances():
	for child in get_children():
		if child is BaseBossAttackController:
			attack_instances[child.name] = child
			print("Loaded controller: ", child.name)


func prepare_stage(stage_index: int, excluded_attacks: Array[int] = []):
	if stage_index < 0 or stage_index >= stages.size():
		push_error("Stage index out of range: ", stage_index, ", stages count: ", stages.size())
		return []

	var stage_attacks: Array[Node] = []
	var stage = stages[stage_index]

	print("Preparing stage: ", stage.stage_name)
	print("Stage has ", stage.attacks.size(), " attack configs")

	for i in range(stage.attacks.size()):
		var attack_config = stage.attacks[i]
		var attack_instance = _find_controller_for_config(attack_config)
		if attack_instance:
			print("Found controller: ", attack_instance.name)
			_apply_attack_parameters(attack_instance, attack_config.get_parameters_dict())
			stage_attacks.append(attack_instance)
		else:
			push_warning("NO CONTROLLER FOUND for config : ",
			stage.attacks[i].get_script().get_global_name())

	print("Stage preparation complete, attacks count: ", stage_attacks.size())
	current_stage_attacks = stage_attacks
	current_stage_sequential_attacks.clear()
	current_stage_sequential_attacks = stage_attacks.duplicate()
	if not excluded_attacks.is_empty():
		for i in excluded_attacks:
			current_stage_sequential_attacks.remove_at(i)
	stage_ready.emit()


func _find_controller_for_config(attack_config: BaseAttackConfig) -> Node:
	var config_class_name = attack_config.get_script().get_global_name()
	if TYPE_TO_CONTROLLER.has(config_class_name):
		var controller_name = TYPE_TO_CONTROLLER[config_class_name]
		print(controller_name)
		if attack_instances.has(controller_name):
			return attack_instances[controller_name]
	push_error("No controller found for config: ", config_class_name)
	return null


func get_stage_cooldown(stage_index: int) -> float:
	if stage_index < 0 or stage_index >= stages.size():
		return cooldown_between_attacks.wait_time
	return stages[stage_index].attack_cooldown


func _apply_attack_parameters(attack_instance: Node, parameters: Dictionary):
	for property in parameters:
		print("PROPERTY = ", property)
		if attack_instance.has_method("set_" + property):
			attack_instance.call("set_" + property, parameters[property])
		elif attack_instance.has_property(property):
			attack_instance.set(property, parameters[property])
		else:
			push_warning("Property ", property, " not found in ", attack_instance.name)


func get_stage_count() -> int:
	return stages.size()


func get_stage_name(stage_index: int) -> String:
	if stage_index < stages.size():
		return stages[stage_index].stage_name
	return ""


func activate_sequential_attack(attack_instance: Node):
	if not attack_instance.attack_finished.is_connected(_on_attack_finished):
		attack_instance.attack_finished.connect(_on_attack_finished)
	attack_instance.activate_attack()


func _on_attack_finished():
	cooldown_between_attacks.start()


func _on_cooldown_between_attacks_timeout() -> void:
	sequential_attack_finished.emit()


func activate_parallel_attack(attack_instance: Node):
	attack_instance.is_parallel_mode = true
	attack_instance.activate_parallel_attack()


func stop_parallel_attack(attack_instance: Node):
	attack_instance.is_parallel_mode = false
