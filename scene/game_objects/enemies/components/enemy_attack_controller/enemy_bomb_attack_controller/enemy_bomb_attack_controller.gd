class_name EnemyBombAttackController

extends EnemyAttackController

const QUEUE_FREE_DELAY: float = 0.5

func activate_attack():
	attack_started.emit()

	owner.hurt_box_shape.disabled = true

	var attack_instance = _create_and_setup_attack_instance()

	_wait_for_attack_completion(attack_instance)

	owner_node.queue_free()


func _create_and_setup_attack_instance():
	var attack_instance = _create_attack_instance()
	_setup_attack_instance(attack_instance)
	return attack_instance


func _setup_attack_instance(attack_instance):
	attack_instance.global_position = owner.global_position
	attack_instance.set_enemy(owner)
	attack_instance.set_explosion_range(get_attack_range())
	_set_damage(attack_instance)


func _wait_for_attack_completion(attack_instance: Node) -> void:
	await attack_instance.animation_player.animation_finished


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate() as BombEnemyAttackScene1
	get_tree().get_first_node_in_group("front_layer").add_child(attack_instance)
	return attack_instance


func _on_cooldown_timer_timeout() -> void:
	attack_cd_timeout.emit()
