class_name BossAttackController
extends Node

signal stage_ready
signal attack_finished

@export var cooldown_between_attacks: float = 3.0

@export var stages: Array[AttackStageConfig] = []

var attack_instances: Dictionary = {}  # Имя контроллера -> инстанс
var current_stage_attacks: Array[Node]

func _ready() -> void:
	_load_attack_instances()


func wait_load():
	print("1234")
	await stage_ready
	print("123")


func _load_attack_instances():
	for child in get_children():
		if child is BaseBossAttackController:
			attack_instances[child.name] = child
			print("Loaded controller: ", child.name)


func prepare_stage(stage_index: int):
	if stage_index < 0 or stage_index >= stages.size():
		push_error("Stage index out of range: ", stage_index, ", stages count: ", stages.size())
		return []

	var stage_attacks: Array[Node] = []
	var stage = stages[stage_index]

	print("Preparing stage: ", stage.stage_name)
	print("Stage has ", stage.attacks.size(), " attack configs")

	for i in range(stage.attacks.size()):
		var attack_config = stage.attacks[i]
		var attack_instance = _find_controller_for_config(attack_config, i)
		if attack_instance:
			print("Found controller: ", attack_instance.name)
			_apply_attack_parameters(attack_instance, attack_config.get_parameters_dict())
			stage_attacks.append(attack_instance)
		else:
			push_warning("NO CONTROLLER FOUND for config index: ", i)

	print("Stage preparation complete, attacks count: ", stage_attacks.size())
	current_stage_attacks = stage_attacks
	stage_ready.emit()


func _find_controller_for_config(attack_config: BaseAttackConfig, index: int) -> Node:
	var controller_names = attack_instances.keys()
	
	if index < controller_names.size():
		var controller_name = controller_names[index]
		return attack_instances[controller_name]
	
	push_error("No controller found for index: ", index)
	return null


func get_stage_cooldown(stage_index: int) -> float:
	if stage_index < 0 or stage_index >= stages.size():
		return cooldown_between_attacks
	return stages[stage_index].attack_cooldown


func _apply_attack_parameters(attack_instance: Node, parameters: Dictionary):
	for property in parameters:
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


func activate_attack(attack_instance: Node):
	print("BossAttackController: Activating attack: ", attack_instance.name)
	attack_instance.activate_attack()
	attack_instance.attack_finished.connect(_on_attack_finished.bind(attack_instance))
#TODO Костыль - переделать

func _on_attack_finished(attack_instance):
	attack_finished.emit()
	attack_instance.attack_finished.disconnect(_on_attack_finished)
