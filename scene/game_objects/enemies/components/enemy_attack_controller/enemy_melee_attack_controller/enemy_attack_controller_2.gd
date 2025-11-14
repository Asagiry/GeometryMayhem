class_name EnemyMeleeAttackController2

extends EnemyAttackController


func activate_attack():
	attack_started.emit()

	var attack_instance = _create_and_setup_attack()
	await _wait_for_attack_completion(attack_instance)

	attack_finished.emit()
	start_cooldown()


func _create_and_setup_attack() -> Node:
	var attack_instance = _create_attack_instance()
	_setup_attack_instance(attack_instance)
	return attack_instance


func _setup_attack_instance(attack_instance: Node) -> void:
	attack_instance.global_position = owner.global_position
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player:
		var dir_to_player: Vector2 = (player.global_position - owner.global_position).normalized()
		attack_instance.rotation = dir_to_player.angle()
	attack_instance.set_enemy(owner)
	attack_instance.set_attack_range(get_attack_range())
	attack_instance.set_speed_scale(1.0 / get_duration())
	_set_damage(attack_instance)



func _wait_for_attack_completion(attack_instance: Node) -> void:
	await attack_instance.animation_player.animation_finished


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate()
	owner.add_child(attack_instance)
	return attack_instance


func _on_cooldown_timer_timeout() -> void:
	attack_cd_timeout.emit()
