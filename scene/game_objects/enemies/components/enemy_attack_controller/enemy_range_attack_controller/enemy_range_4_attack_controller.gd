class_name EnemyRangeAttackController4

extends EnemyAttackController


const DELAY_BETWEEN_PROJECTILES: float = 0.1
var chance_to_deploy_additional_projectile: float

@onready var attack_spawn_point: Node2D = %AttackSpawnPoint

func activate_attack() -> void:
	print("\n===== RANGE ATTACK START =====")

	print("ATTACK STARTED SIGNAL emit")
	attack_started.emit()

	# Останавливаем движение
	print("CALL _stop_movement()")
	_stop_movement()

	if owner and owner.movement_component:
		print("movement_component speed_multiplier =", owner.movement_component.speed_multiplier)
		print("owner.velocity BEFORE =", owner.velocity)

	# --- SPAWN PHASE ---
	print("SPAWN attack instance...")
	_spawn_attack_instance()
	print("SPAWN DONE")

	var duration := get_duration()
	if duration <= 0.0:
		print("!!! duration <= 0 (", duration, ") forcing = 0.6")
		duration = 0.6

	print("ATTACK DURATION =", duration)
	print("waiting timer...")

	# Таймер
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(func():
		print("*** TIMER timeout fired (after", duration, "sec) ***")
	)

	await timer.timeout

	print("TIMER awaited — attack duration ended")

	# --- FINISH PHASE ---
	print("ATTACK FINISHED SIGNAL emit")
	attack_finished.emit()

	print("CALL _start_movement()")
	_start_movement()

	if owner and owner.movement_component:
		print("movement_component speed_multiplier AFTER =", owner.movement_component.speed_multiplier)
		print("owner.velocity AFTER =", owner.velocity)

	print("CALL start_cooldown()")
	start_cooldown()

	print("===== RANGE ATTACK END =====\n")



func _spawn_attack_instance() -> void:
	_create_and_setup_attack_instance()


func _create_and_setup_attack_instance() -> void:
	var attack_instance = _create_attack_instance()
	_setup_attack_instance(attack_instance, _get_direction_to_player())


func _setup_attack_instance(attack_instance, direction_to_player: Vector2) -> void:
	var dir = direction_to_player.normalized()
	if owner is EnemyController:
		owner.set_facing_direction_360(dir, attack_spawn_point)
	attack_instance.global_position = attack_spawn_point.global_position
	attack_instance.rotation = dir.angle()
	if attack_instance.has_method("set_enemy"):
		attack_instance.set_enemy(owner)
	_set_damage(attack_instance)
	if attack_instance.has_method("setup_laser"):
		attack_instance.setup_laser(dir,  get_attack_range(), get_duration())


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate()
	get_tree().get_first_node_in_group("front_layer").add_child(attack_instance)
	return attack_instance


func _on_cooldown_timer_timeout() -> void:
	attack_cd_timeout.emit()
