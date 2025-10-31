class_name EnemyRangeAttackController1

extends EnemyAttackController

func activate_attack():
	attack_started.emit()
	_spawn_attack_instance()


func _spawn_attack_instance():
	attack_started.emit()

	var attack_instance = _create_attack_instance()
	print("ATTACK SPAWNED")
	attack_instance.global_position = owner.global_position
	attack_instance.set_direction(owner.movement_component.last_direction)
	attack_instance.set_enemy(owner)

	if owner.movement_component.last_direction.length() > 0.001:
		attack_instance.rotation += owner.movement_component.last_direction.angle()

	_set_damage(attack_instance)
	attack_finished.emit()
	start_cooldown()


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate() as RangeEnemyAttackScene1
	get_tree().get_first_node_in_group("front_layer").add_child(attack_instance)
	return attack_instance
