class_name EnemyRangeAttackController2

extends EnemyAttackController

@onready var attack_spawn_point: Node2D = %AttackSpawnPoint

const DELAY_BETWEEN_PROJECTILES: float = 0.1

var chance_to_deploy_additional_projectile: float


func activate_attack():
	attack_started.emit()
	print("атака началась")

	chance_to_deploy_additional_projectile = get_chance_to_additional_projectile()
	await _spawn_attack_instance()

	attack_finished.emit()
	print("атака закончилась")
	start_cooldown()


func _spawn_attack_instance():
	_create_and_setup_attack_instance()

	if randf() < chance_to_deploy_additional_projectile:
		await get_tree().create_timer(DELAY_BETWEEN_PROJECTILES).timeout
		await _spawn_attack_instance()


func _create_and_setup_attack_instance():
	var attack_instance = _create_attack_instance()
	_setup_attack_instance(attack_instance, _get_direction_to_player())


func _setup_attack_instance(attack_instance, direction_to_player):
	var dir = direction_to_player.normalized()

	if owner is EnemyController:
		owner.set_facing_direction(dir,attack_spawn_point)
	attack_instance.global_position = attack_spawn_point.global_position
	attack_instance.rotation += direction_to_player.angle()
	attack_instance.set_direction(direction_to_player)
	attack_instance.set_enemy(owner)
	attack_instance.set_projectile_speed(get_projectile_speed())
	_set_damage(attack_instance)


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate()
	get_tree().get_first_node_in_group("front_layer").add_child(attack_instance)
	return attack_instance


func _on_cooldown_timer_timeout() -> void:
	attack_cd_timeout.emit()


func _on_timer_timeout() -> void:
	attack_cd_timeout.emit()
