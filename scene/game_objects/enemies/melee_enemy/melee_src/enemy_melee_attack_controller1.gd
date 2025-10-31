class_name EnemyMeleeAttackController1

extends EnemyAttackController


func activate_attack():
	attack_started.emit()
	_spawn_attack_instance()


func _spawn_attack_instance():
	attack_started.emit()

	var attack_instance = _create_attack_instance()
	attack_instance.global_position = owner.global_position
	
	attack_instance.set_enemy(owner)
	attack_instance.set_attack_range(attack_range)
	if owner.movement_component.last_direction.length() > 0.001:
		attack_instance.rotation = owner.movement_component.last_direction.angle()
	attack_instance.set_speed_scale(1 / get_duration())
	_set_damage(attack_instance)
	
	await attack_instance.animation_player.animation_finished
	attack_finished.emit()
	start_cooldown()
	attack_instance.queue_free()


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate() as MeleeEnemyAttackScene1
	get_tree().get_first_node_in_group("front_layer").add_child(attack_instance)
	return attack_instance
