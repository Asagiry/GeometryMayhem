class_name DashAttackController

#region variables
extends Node

@export var dash_attack_scene: PackedScene
@export var dash_attack_damage: float = 10.0
@export var dash_attack_range: float = 100.0
@export var damage_multiplier: float = 1.0
@export var attack_cd: float = 1.0
@export var dash_attack_width = 25.0

var is_dash_from_mouse: bool = false
var dash_duration: float = 0.2
var player

@onready var hurt_box_shape: CollisionShape2D = %HurtBoxShape
@onready var cooldown_timer: Timer = %CooldownTimer
#endregion variables

func _ready():
	player = get_tree().get_first_node_in_group("player") as Node2D


func activate_dash(input_state: bool):
	if !cooldown_timer.is_stopped():
		return

	var dash_attack_instance = _create_dash_instance()

	_set_damage(dash_attack_instance)
	_disable_player(true)

	is_dash_from_mouse = input_state
	if is_dash_from_mouse:
		_activate_mouse_click_dash(dash_attack_instance)
	else:
		_activate_shift_dash(dash_attack_instance)


func _create_dash_instance():
	var dash_attack_instance = dash_attack_scene.instantiate() as DashAttack
	get_tree().get_first_node_in_group("front_layer").add_child(dash_attack_instance)
	return dash_attack_instance


func _disable_player(disable:bool):
	_disable_player_hurt_box(disable)
	_disable_player_inputs(disable)


func _set_damage(dash_attack_instance: DashAttack):
	dash_attack_instance.hit_box_component.damage = dash_attack_damage * damage_multiplier


func _activate_mouse_click_dash(dash_attack_instance):
	var mouse_pos = player.get_global_mouse_position()
	var direction = mouse_pos - player.global_position
	var distance = direction.length()
	if distance > dash_attack_range:
		mouse_pos = player.global_position + direction.normalized() * dash_attack_range
		distance = dash_attack_range


	player.last_direction = (mouse_pos - player.global_position).normalized()
	player.rotation = player.last_direction.angle() + PI / 2
	_set_dash(dash_attack_instance,distance)
	_start_cooldown_timer()
	_start_dash_tween(mouse_pos, dash_attack_instance)


func _activate_shift_dash(dash_attack_instance):
	var forward = Vector2.UP.rotated(player.rotation)
	_set_dash(dash_attack_instance,dash_attack_range)
	_start_cooldown_timer()
	_start_dash_tween(player.global_position + forward * dash_attack_range, \
	dash_attack_instance)


func _start_cooldown_timer():
	cooldown_timer.wait_time = attack_cd
	cooldown_timer.start()


func _disable_player_hurt_box(disable: bool):
	hurt_box_shape.disabled = disable


func _disable_player_inputs(disable: bool):
	player.is_input_blocked = disable


func _start_dash_tween(target_position, dash_attack_instance: DashAttack):
	var direction = player.global_position.direction_to(target_position)
	var distance = player.global_position.distance_to(target_position)

	var test_body = CharacterBody2D.new()
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2(10, 10) # Размер коллайдера игрока
	test_body.add_child(collision_shape)
	test_body.global_position = player.global_position
	test_body.collision_mask = 1 << 0 # Environment слой
	add_child(test_body)

	var collision = test_body.move_and_collide(direction * distance)

	var final_target_position = target_position
	if collision:
		final_target_position = player.global_position + direction * \
		(collision.get_travel().length() - 10)

	test_body.queue_free()

	var tween = create_tween()
	tween.tween_property(player, "global_position", final_target_position, dash_duration) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)


	tween.tween_callback(Callable(dash_attack_instance, "queue_free"))
	tween.finished.connect(func():
		_disable_player(false)
	)


func _set_dash(dash_attack: DashAttack,distance: float):
	var forward = Vector2.UP.rotated(player.rotation)
	dash_attack.global_position = player.global_position
	dash_attack.dash_hit_box_shape.shape.size = Vector2(dash_attack_width, distance)
	dash_attack.global_position = player.global_position + forward * (distance/ 2.0)
	dash_attack.rotation = player.rotation
