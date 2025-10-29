class_name ParryController
extends Node

@export var parry_scene: PackedScene
var parry_cd: float
var push_distance: float
var parry_angle: float
var parry_radius: float
var parry_duration: float = 0.3

var push_duration: float = 0.2 #время перемещения моба от точка А до точки Б(отталкивание)

var parry_duration_multiplier: float = 1.0

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


func _process(_delta):
	if parry_instance and is_instance_valid(player):
		parry_instance.global_position = player.global_position
		parry_instance.rotation = player.rotation


func _enter_variables():
	player = get_tree().get_first_node_in_group("player") as PlayerController
	parry_instance = parry_scene.instantiate() as Parry
	parry_cd = player.stats.parry_cd
	push_distance = player.stats.parry_push_distance
	parry_angle = player.stats.parry_angle
	parry_radius = player.stats.parry_radius
	parry_duration = player.stats.parry_duration
	parry_instance.init(parry_angle,parry_radius)
	get_tree().get_first_node_in_group("front_layer").add_child(parry_instance)


func _connect_signals():
	parry_instance.projectile_detected.connect(_on_projectile_detected)
	parry_instance.melee_detected.connect(_on_melee_detected)
	player.effect_receiver.player_stats_changed.connect(_on_stats_changed)


func start_cooldown():
	is_on_cooldown = true
	parry_cooldown.start(parry_cd)


func activate_parry(input_state:bool):
	is_parry_from_mouse = input_state

	if is_parry_from_mouse:
		var mouse_dir = player.global_position.direction_to(player.get_global_mouse_position())
		player.rotation = mouse_dir.angle() + deg_to_rad(90)
		player.movement_component.last_direction = mouse_dir

	for i in range(2):
		await get_tree().create_timer(parry_duration / 2).timeout
		await _melee_parry()

func _melee_parry():
	for enemy in melee_targets.duplicate():
		if not is_instance_valid(enemy):
			continue
		_push_enemy(enemy, player.movement_component.last_direction)


func _push_enemy(enemy: Node2D, facing_direction: Vector2) -> void:
	var target_pos = _calculate_push_target(enemy, facing_direction)
	_animate_enemy_push(enemy, target_pos)


func _calculate_push_target(enemy: Node2D, facing_direction: Vector2) -> Vector2:
	var direction = facing_direction.normalized()
	var to_enemy = (enemy.global_position - parry_instance.global_position).normalized()
	var angle_offset = direction.angle_to(to_enemy)
	var max_angle = deg_to_rad(parry_angle)
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


func _on_projectile_detected(projectile: Area2D):
	if not is_parrying:
		return
	if projectile.has_method("reflect"):
		projectile.reflect()


func _on_melee_detected(enemies: Array[Node2D]):
	melee_targets = enemies.duplicate()


func _on_parry_cooldown_timeout() -> void:
	is_on_cooldown = false


func _on_stats_changed(updated_stats: Dictionary) -> void:
	if updated_stats.has("parry_duration_multiplier"):
		parry_duration_multiplier = updated_stats["parry_duration_multiplier"]
