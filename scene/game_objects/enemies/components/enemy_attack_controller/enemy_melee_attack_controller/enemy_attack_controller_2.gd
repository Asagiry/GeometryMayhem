class_name EnemyMeleeAttackController2
extends EnemyAttackController

const FIRE_SECTOR_ANGLE: float = 90.0

func activate_attack():
	attack_started.emit()
	_stop_movement()
	var attack_instance = _create_and_setup_attack()
	if attack_instance.has_method("perform_attack"):
		attack_instance.perform_attack()
	await _wait_for_attack_completion(attack_instance)
	_start_movement()
	attack_finished.emit()
	start_cooldown()


func _create_and_setup_attack() -> Node:
	var attack_instance = _create_attack_instance()
	_setup_attack_instance(attack_instance)
	return attack_instance


func _setup_attack_instance(attack_instance: Node) -> void:
	attack_instance.global_position = owner.global_position
	attack_instance.rotation = _get_direction_to_player().angle()
	attack_instance.set_enemy(owner)
	attack_instance.set_attack_range(get_attack_range(), FIRE_SECTOR_ANGLE)
	attack_instance.set_speed_scale(1.0 / get_duration())
	_set_damage(attack_instance)


func _wait_for_attack_completion(attack_instance: Node) -> void:
	await attack_instance.attack_finished


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate()
	owner.add_child(attack_instance)
	return attack_instance


func _on_cooldown_timer_timeout() -> void:
	attack_cd_timeout.emit()
