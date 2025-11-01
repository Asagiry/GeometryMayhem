class_name ParryController
extends Node

signal parry_started()
signal parry_finished()
signal parry_cooldown_timeout()

@export var parry_scene: PackedScene
var cooldown: float
var push_distance: float
var angle: float
var radius: float
var duration: float = 0.3
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
	_enter_variables()
	_connect_signals()


func _physics_process(_delta):
	if parry_instance and is_instance_valid(player):
		parry_instance.global_position = player.global_position
		parry_instance.rotation = player.rotation


func _enter_variables():
	player = get_tree().get_first_node_in_group("player") as PlayerController
	parry_instance = parry_scene.instantiate() as Parry
	cooldown = player.stats.parry_cd
	push_distance = player.stats.parry_push_distance
	angle = player.stats.parry_angle
	radius = player.stats.parry_radius
	duration = player.stats.parry_duration
	parry_instance.init(angle,radius)
	add_child(parry_instance)


func _connect_signals():
	player.effect_receiver.attack_component_effects_changed.connect(_on_effect_stats_changed)


func start_cooldown():
	parry_cooldown.start(get_cooldown())


func activate_parry(input_state:bool):
	parry_started.emit()

	is_parry_from_mouse = input_state
	if is_parry_from_mouse:
		var mouse_dir = player.global_position.direction_to(player.get_global_mouse_position())
		player.rotation = mouse_dir.angle() + deg_to_rad(90)
		player.movement_component.last_direction = mouse_dir

	await get_tree().physics_frame
	player.set_collision_layer_value(2, true)
	await _parry()
	#TODO GM-116
	await get_tree().create_timer(get_duration()).timeout

	start_cooldown()
	parry_finished.emit()


func _parry():
	await get_tree().physics_frame

	var overlapping_bodies = parry_instance.parry_area.get_overlapping_bodies()
	var overlapping_areas = parry_instance.parry_area.get_overlapping_areas()

	for body in overlapping_bodies:
		if body.is_in_group("enemy"):
			_push_enemy(body, player.movement_component.last_direction)

	for area in overlapping_areas:
		if area.is_in_group("projectile"):
				area.owner.direction *= -1


func _push_enemy(enemy: Node2D, facing_direction: Vector2) -> void:
	var target_pos = _calculate_push_target(enemy, facing_direction)
	_animate_enemy_push(enemy, target_pos)


func _calculate_push_target(enemy: Node2D, facing_direction: Vector2) -> Vector2:
	var direction = facing_direction.normalized()
	var to_enemy = (enemy.global_position - parry_instance.global_position).normalized()
	var angle_offset = direction.angle_to(to_enemy)
	var max_angle = deg_to_rad(angle)
	angle_offset = clamp(angle_offset, -max_angle, max_angle)
	direction = direction.rotated(angle_offset)

	var ray = RayCast2D.new()
	ray.target_position = direction * push_distance
	enemy.add_child(ray)
	ray.enabled = true
	ray.force_raycast_update()

	var safe_distance = push_distance
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


func get_duration():
	return duration*duration_multiplier


func get_cooldown():
	return cooldown*cooldown_multiplier
