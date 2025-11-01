class_name EnemyRangeAttackController

extends EnemyAttackController

const DELAY_BETWEEN_PROJECTILES: float = 0.1

var chance_to_deploy_additional_projectile: float
var player: PlayerController

func _ready():
	super._ready()
	player = get_tree().get_first_node_in_group("player")
	chance_to_deploy_additional_projectile = owner.stats.chance_to_additional_projectile


func activate_attack():
	attack_started.emit()

	await _spawn_attack_instance()

	attack_finished.emit()
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
	attack_instance.global_position = owner.global_position
	attack_instance.rotation += direction_to_player.angle()
	attack_instance.set_direction(direction_to_player)
	attack_instance.set_enemy(owner)
	attack_instance.set_projectile_speed(projectile_speed)
	_set_damage(attack_instance)


func _get_direction_to_player():
	return (player.global_position - owner.global_position).normalized()


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate() as RangeEnemyAttackScene1
	get_tree().get_first_node_in_group("front_layer").add_child(attack_instance)
	return attack_instance


func _on_cooldown_timer_timeout() -> void:
	attack_cd_timeout.emit()
