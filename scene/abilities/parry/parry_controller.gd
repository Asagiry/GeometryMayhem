class_name ParryController
extends BaseComponent # Меняем наследование

signal parry_started()
signal parry_finished()
signal parry_cooldown_timeout()

@export var parry_scene: PackedScene

var push_duration: float = 0.2
var duration_multiplier: float = 1.0
var cooldown_multiplier: float = 1.0

var melee_targets: Array[Node2D]
var is_parrying: bool = false
var parry_instance: Parry
var player: PlayerController
var is_parry_from_mouse: bool
var is_on_cooldown: bool

@onready var parry_cooldown: Timer = $ParryCooldown


func _ready():
	_connect_signals()
	super._ready()  # Вызовет _setup_owner_reference() и _setup_stat_subscriptions()


func _setup_owner_reference():
	super._setup_owner_reference()

	# Получаем player из owner
	if owner_node is PlayerController:
		player = owner_node
	else:
		player = get_tree().get_first_node_in_group("player") as PlayerController

	if parry_scene:
		parry_instance = parry_scene.instantiate() as Parry
		parry_instance.init(get_angle(), get_radius())


func _connect_signals():
	if player and player.effect_receiver:
		player.effect_receiver.attack_component_effects_changed.connect(_on_effect_stats_changed)


func _physics_process(_delta):
	# Обновляем позицию парри только если он активен
	if parry_instance and is_instance_valid(parry_instance) and parry_instance.get_parent():
		parry_instance.global_position = player.global_position
		parry_instance.rotation = player.rotation


func start_cooldown():
	parry_cooldown.start(get_cooldown() * cooldown_multiplier)


func activate_parry(input_state: bool):
	if is_parrying or is_on_cooldown:
		return


	parry_started.emit()
	is_parrying = true

	# Добавляем парри в сцену
	if parry_instance and not parry_instance.get_parent():
		parry_instance.update_parameters(get_angle(), get_radius())
		add_child(parry_instance)
		parry_instance.global_position = player.global_position
		parry_instance.rotation = player.rotation

	is_parry_from_mouse = input_state
	if is_parry_from_mouse:
		var mouse_dir = player.global_position.direction_to(player.get_global_mouse_position())
		player.rotation = mouse_dir.angle() + deg_to_rad(90)
		player.movement_component.last_direction = mouse_dir

	await get_tree().physics_frame
	player.set_collision_layer_value(2, true)

	await _parry()
	await get_tree().create_timer(get_duration() * duration_multiplier).timeout

	# Убираем парри из сцены
	if parry_instance and is_instance_valid(parry_instance):
		remove_child(parry_instance)

	is_parrying = false
	start_cooldown()
	parry_finished.emit()


func _parry():
	await get_tree().physics_frame

	if not parry_instance or not is_instance_valid(parry_instance):
		return
	var area = parry_instance.parry_area
	if not area:
		return

	var successful_parry: bool = false
	var dir = player.movement_component.last_direction

	var overlapping_bodies = area.get_overlapping_bodies()
	var overlapping_areas = area.get_overlapping_areas()

	for body in overlapping_bodies:
		if not is_instance_valid(body):
			continue
		if body.is_in_group("enemy"):
			_push_enemy(body, dir)
			successful_parry = true

	for a in overlapping_areas:
		if not is_instance_valid(a):
			continue
		if a.is_in_group("projectile"):
			var area_owner = a.owner
			if area_owner and is_instance_valid(area_owner) and area_owner.has_method("change_collision"):
				area_owner.change_collision()
				area_owner.set_direction(dir)
				successful_parry = true

	if successful_parry:
		Global.player_successful_parry.emit()


func _push_enemy(enemy: Node2D, facing_direction: Vector2) -> void:
	var target_pos = _calculate_push_target(enemy, facing_direction)
	_animate_enemy_push(enemy, target_pos)


func _calculate_push_target(enemy: Node2D, facing_direction: Vector2) -> Vector2:
	var direction = facing_direction.normalized()
	var to_enemy = (enemy.global_position - player.global_position).normalized()
	var angle_offset = direction.angle_to(to_enemy)
	var max_angle = deg_to_rad(get_angle())
	angle_offset = clamp(angle_offset, -max_angle, max_angle)
	direction = direction.rotated(angle_offset)

	var ray = RayCast2D.new()
	ray.target_position = direction * get_push_distance()
	enemy.add_child(ray)
	ray.enabled = true
	ray.force_raycast_update()

	var safe_distance = get_push_distance()
	if ray.is_colliding():
		safe_distance = (ray.get_collision_point() - enemy.global_position).length() - 1
	ray.queue_free()

	return enemy.global_position + direction * safe_distance


func _animate_enemy_push(enemy: Node2D, target_pos: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(enemy, "global_position", target_pos, push_duration) \
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)

	var tilt_tween = create_tween()
	tilt_tween.tween_property(
		enemy.animated_sprite_2d,
		"rotation",
		deg_to_rad(-10.0),
		push_duration / 3,
	) \
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tilt_tween.finished.connect(
		func():
			var back_tween = create_tween()
			back_tween.tween_property(
				enemy.animated_sprite_2d,
				"rotation",
				deg_to_rad(10.0),
				push_duration / 3,
			) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			back_tween.finished.connect(
				func():
					var reset_tween = create_tween()
					reset_tween.tween_property(
						enemy.animated_sprite_2d,
						"rotation",
						0.0,
						push_duration / 3,
					) \
					.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			)
	)
	_shake_enemy(enemy)


func _shake_enemy(enemy: Node2D) -> void:
	var sprite = enemy.animated_sprite_2d
	if !is_instance_valid(sprite):
		return

	var shake_tween = create_tween()
	var shake_strength = 6.5
	var shake_speed = 0.05

	for i in range(4):
		shake_tween.tween_property(
			sprite,
			"position:x",
			sprite.position.x + randf_range(-shake_strength, shake_strength),
			shake_speed)
		shake_tween.tween_property(
			sprite,
			"position:x",
			sprite.position.x,
			shake_speed)


func _on_parry_cooldown_timeout() -> void:
	parry_cooldown_timeout.emit()


func _on_effect_stats_changed(updated_stats) -> void:
	if updated_stats.has("attack_duration_multiplier"):
		duration_multiplier = updated_stats["attack_duration_multiplier"]
	# Добавь другие эффекты если нужно
	# if updated_stats.has("parry_cd_multiplier"):
	#     cooldown_multiplier = updated_stats["parry_cd_multiplier"]
	# if updated_stats.has("damage_multiplier"):
	#     damage_multiplier = updated_stats["(parry)damage_multiplier"]


func get_cooldown() -> float:
	return get_stat("parry_cd") * cooldown_multiplier


func get_push_distance() -> float:
	return get_stat("parry_push_distance")


func get_angle() -> float:
	return get_stat("parry_angle")


func get_radius() -> float:
	return get_stat("parry_radius")


func get_duration() -> float:
	return get_stat("parry_duration") * duration_multiplier


func get_parry_damage() -> DamageData:
	return get_stat("parry_damage")
