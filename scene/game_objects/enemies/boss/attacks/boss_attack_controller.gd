class_name BossAttackController
extends Node

signal stage_ready(stage_index: int, stage_attacks: Array[Node])  # Сигнал когда стадия готова

@export var stages: Array[AttackStageConfig] = []

var attack_instances: Dictionary = {}  # Имя контроллера -> инстанс

func _ready() -> void:
	_load_attack_instances()

func wait_load():
	await get_tree().create_timer(0.5).timeout

func _load_attack_instances():
	# Собираем все дочерние контроллеры атак
	for child in get_children():
		if child is BaseBossAttackController:
			attack_instances[child.name] = child
			print("Loaded controller: ", child.name)

# НОВЫЙ МЕТОД: Подготовить стадию и вернуть атаки через сигнал
# В BossAttackController замени prepare_stage:
func prepare_stage(stage_index: int) -> Array[Node]:
	if stage_index < 0 or stage_index >= stages.size():
		print("Stage index out of range: ", stage_index, ", stages count: ", stages.size())
		return []
	
	var stage_attacks: Array[Node] = []
	var stage = stages[stage_index]
	
	print("Preparing stage: ", stage.stage_name)
	print("Stage has ", stage.attacks.size(), " attack configs")
	
	for i in range(stage.attacks.size()):
		var attack_config = stage.attacks[i]
		print("Processing attack config ", i, ": ", attack_config.resource_path)
		
		var attack_instance = _find_controller_for_config(attack_config, i)
		if attack_instance:
			print("Found controller: ", attack_instance.name)
			_apply_attack_parameters(attack_instance, attack_config.get_parameters_dict())
			stage_attacks.append(attack_instance)
		else:
			print("NO CONTROLLER FOUND for config index: ", i)
	
	print("Stage preparation complete, attacks count: ", stage_attacks.size())
	return stage_attacks

func _find_controller_for_config(attack_config: BaseAttackConfig, index: int) -> Node:
	# Простой маппинг: первый конфиг -> первый контроллер, второй конфиг -> второй контроллер и т.д.
	var controller_names = attack_instances.keys()
	
	if index < controller_names.size():
		var controller_name = controller_names[index]
		print("Mapping config index ", index, " to controller: ", controller_name)
		return attack_instances[controller_name]
	
	print("No controller found for index: ", index)
	return null

func get_stage_cooldown(stage_index: int) -> float:
	if stage_index < 0 or stage_index >= stages.size():
		return 3.0  # Значение по умолчанию
	return stages[stage_index].attack_cooldown

func _apply_attack_parameters(attack_instance: Node, parameters: Dictionary):
	print("Applying parameters to ", attack_instance.name, ": ", parameters)
	for property in parameters:
		if attack_instance.has_method("set_" + property):
			attack_instance.call("set_" + property, parameters[property])
			print("Called set_", property, " with value: ", parameters[property])
		elif attack_instance.has_property(property):
			attack_instance.set(property, parameters[property])
			print("Set property ", property, " to value: ", parameters[property])
		else:
			print("Property ", property, " not found in ", attack_instance.name)

func get_stage_count() -> int:
	return stages.size()

func get_stage_name(stage_index: int) -> String:
	if stage_index < stages.size():
		return stages[stage_index].stage_name
	return ""

# ПРОСТОЙ МЕТОД ДЛЯ ЗАПУСКА АТАКИ
func activate_attack(attack_instance: Node):
	print("BossAttackController: Activating attack: ", attack_instance.name)
	attack_instance.activate_attack()
