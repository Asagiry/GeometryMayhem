class_name FalseBaseMutationAttackController

extends BaseBossAttackController

var damage: DamageData = DamageData.new()
var initial_radius: float = 15.0
var final_radius: float = 50.0  
var expansion_time: float = 0.8
var damage_duration: float = 1.0


func activate_attack():
	attack_started.emit()
	var attack_instance = _create_and_setup_attack()
	await _wait_for_attack_completion(attack_instance)
	attack_finished.emit()


func _create_and_setup_attack():
	var attack_instance = _create_attack_instance()
	_setup_attack_instance(attack_instance)
	return attack_instance


func _setup_attack_instance(attack_instance) -> void:
	attack_instance.global_position = attack_instance.calculate_position_ahead_of_player()
	attack_instance.set_enemy(owner)
	attack_instance.set_damage(damage)
	attack_instance.set_parameters(
		initial_radius,
		final_radius,
		expansion_time,
		damage_duration,
	)


func _wait_for_attack_completion(attack_instance) -> void:
	await attack_instance.attack_finished


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate()
	get_tree().get_first_node_in_group("front_layer").add_child(attack_instance)
	return attack_instance


func set_damage(p_damage: DamageData):
	damage = p_damage


func set_initial_radius(value: float):
	initial_radius = value


func set_final_radius(value: float):
	final_radius = value


func set_expansion_time(value: float):
	expansion_time = value


func set_damage_duration(value: float):
	damage_duration = value
