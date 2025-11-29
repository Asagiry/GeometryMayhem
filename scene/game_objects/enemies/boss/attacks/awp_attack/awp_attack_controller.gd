class_name AwpAttackController

extends BaseBossAttackController

var damage: DamageData = DamageData.new()
var aim_duration: float
## Задержка между стадией прицеливания и стрельбой
var delay_before_attack: float
var number_of_shots: int
var time_between_shots: float

func activate_attack():
	print("AwpAttackController: activate_attack called")
	attack_started.emit()
	print("Movement stopped")
	_stop_movement()
	var attack_instance = _create_and_setup_attack()
	print("Waiting for attack completion...")
	await _wait_for_attack_completion(attack_instance)
	print("Attack completed, starting movement")
	_start_movement()
	attack_finished.emit()
	print("AwpAttackController: activate_attack finished")


func _create_and_setup_attack():
	var attack_instance = _create_attack_instance()
	_setup_attack_instance(attack_instance)
	return attack_instance


func _setup_attack_instance(attack_instance) -> void:
	attack_instance.global_position = owner.global_position
	attack_instance.set_enemy(owner)
	attack_instance.set_damage(damage)
	attack_instance.set_parameters(
		aim_duration,
		delay_before_attack,
		number_of_shots,
		time_between_shots,
	)


func _wait_for_attack_completion(attack_instance) -> void:
	await attack_instance.attack_finished


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate()
	get_tree().get_first_node_in_group("front_layer").add_child(attack_instance)
	return attack_instance


func set_damage(p_damage: DamageData):
	damage = p_damage


func set_aim_duration(value: float):
	aim_duration = value


func set_number_of_shots(value: int):
	number_of_shots = value


func set_delay_before_attack(value: float):
	delay_before_attack = value


func set_time_between_shots(value: float):
	time_between_shots = value
