class_name EnemyRangeAttackController1

extends EnemyAttackController

var player: PlayerController

func _ready():
	super._ready()
	player = get_tree().get_first_node_in_group("player")

func activate_attack():
	attack_started.emit()
	_spawn_attack_instance()
	await get_tree().create_timer(get_duration()).timeout
	attack_finished.emit()
	start_cooldown()


func _spawn_attack_instance():
	attack_started.emit()

	var attack_instance = _create_attack_instance()
	attack_instance.global_position = owner.global_position
	attack_instance.set_direction((player.global_position - owner.global_position).normalized())
	attack_instance.set_enemy(owner)
	attack_instance.rotation += owner.movement_component.last_direction.angle()
	attack_instance.set_projectile_speed(projectile_speed)
	_set_damage(attack_instance)
	if randf() < 0.5:
		await get_tree().create_timer(0.1).timeout
		_spawn_attack_instance()


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate() as RangeEnemyAttackScene1
	get_tree().get_first_node_in_group("front_layer").add_child(attack_instance)
	return attack_instance


func _on_cooldown_timer_timeout() -> void:
	attack_cd_timeout.emit()
