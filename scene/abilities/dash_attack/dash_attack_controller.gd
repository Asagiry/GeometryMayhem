class_name DashAttackController

#region variables
extends Node

@export var dash_attack_scene: PackedScene
@export var damage_data: DamageData
@export var damage_type: Util.DamageCategory
@export var dash_range: float = 100.0
@export var attack_cd: float = 0.1
@export var dash_width: float = 25.0

var dash_effect = preload("res://assets/artefacts/vfx/AstralStepVFX/dash_attack_vfx_astral_step.tscn")
var damage_multiplier: float = 1.0
var is_dash_from_mouse: bool = false
var dash_duration: float = 0.2
var player: PlayerController
var is_on_cooldown: bool
var is_range_enable: bool = true

var _distance: float = 0
var _direction: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO
var _dash_circle: DashCircle

@onready var player_hurt_box: PlayerHurtBox = %PlayerHurtBox
@onready var cooldown_timer: Timer = %CooldownTimer
#endregion variables

func _create_vfx_effect(start_pos: Vector2, end_pos: Vector2):
	var dash_effect_instance = dash_effect.instantiate()
	get_tree().get_first_node_in_group("back_layer").add_child(dash_effect_instance)
	dash_effect_instance.setup(start_pos, end_pos)


func start_cooldown():
	is_on_cooldown = true
	cooldown_timer.start(attack_cd)


func _ready():
	player = get_tree().get_first_node_in_group("player") as Node2D
	_setup_dash_cirlce()


func _setup_dash_cirlce():
	_dash_circle = preload("res://scene/game_objects/player/dash_circle.tscn")\
	.instantiate() as DashCircle
	player.add_child.call_deferred(_dash_circle)
	enable_range(is_range_enable)


func enable_range(enable: bool):
	if (enable):
		_dash_circle.set_range(dash_range)
		_dash_circle.show_dash_range()
	else:
		_dash_circle.hide_dash_range()


func activate_dash(input_state: bool):
	var dash_attack_instance = _create_dash_instance()
	_set_damage(dash_attack_instance)
	_disable_player(true)
	is_dash_from_mouse = input_state
	if is_dash_from_mouse:
		_activate_mouse_click_dash(dash_attack_instance)
	else:
		_activate_keyboard_dash(dash_attack_instance)


func _create_dash_instance():
	var dash_attack_instance = dash_attack_scene.instantiate() as DashAttack
	get_tree().get_first_node_in_group("front_layer").add_child(dash_attack_instance)
	return dash_attack_instance


func _set_damage(dash_attack_instance: DashAttack):
	damage_data.amount *= damage_multiplier
	dash_attack_instance.hit_box_component.damage_data = damage_data


func _disable_player(disable:bool):
	_disable_player_hurt_box(disable)
	_disable_player_inputs(disable)


func _disable_player_hurt_box(disable: bool):
	player_hurt_box.hurt_box_shape.disabled = disable


func _disable_player_inputs(disable: bool):
	player.is_input_blocked = disable


func _activate_mouse_click_dash(dash_attack_instance):
	_set_target_position_from_mouse()
	_rotate_player_to_dash()
	_start_dash_tween(dash_attack_instance)


func _set_target_position_from_mouse():
	_target_position = player.get_global_mouse_position()
	var direction = _target_position - player.global_position
	var distance = direction.length()
	if distance > dash_range:
		_target_position = player.global_position + direction.normalized() * dash_range
		distance = dash_range


func _rotate_player_to_dash():
	player.movement_component.last_direction = (_target_position - player.global_position).normalized()
	player.rotation = player.movement_component.last_direction.angle() + PI / 2


func _activate_keyboard_dash(dash_attack_instance):
	_set_target_position_from_keyboard()
	_start_dash_tween(dash_attack_instance)


func _set_target_position_from_keyboard():
	var forward = Vector2.UP.rotated(player.rotation)
	_target_position = player.global_position + forward * dash_range


func _start_dash_tween(dash_attack_instance: DashAttack):
	_set_final_target_position()
	_direction = player.global_position.direction_to(_target_position)
	_distance = player.global_position.distance_to(_target_position)
	var tween = create_tween()
	tween.tween_property(player, "global_position", _target_position, dash_duration) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

	var start_position = player.global_position
	var start_size = Vector2(dash_width, 0)
	var end_size = Vector2(dash_width, _distance)
	dash_attack_instance.dash_hit_box_shape.shape.size = start_size
	dash_attack_instance.rotation = player.rotation

	tween.parallel().tween_method(
		func(size_value: Vector2):
			var safe_size = Vector2(max(0, size_value.x), max(0, size_value.y))
			dash_attack_instance.dash_hit_box_shape.shape.size = safe_size
			dash_attack_instance.global_position = start_position + _direction * (size_value.y / 2.0),
		start_size,
		end_size,
		dash_duration
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

	tween.tween_callback(Callable(dash_attack_instance, "queue_free"))
	tween.finished.connect(func():
		_disable_player(false)
		print(start_position)
		_create_vfx_effect(start_position, _target_position)
	)

#Проверка на столкновение со стенами и пересчёт если столкнулись
func _set_final_target_position():
	var test_body = CharacterBody2D.new()
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2(10, 10) # Размер коллайдера игрока
	test_body.add_child(collision_shape)
	test_body.global_position = player.global_position
	test_body.collision_mask = 1 << 0 # Environment слой
	add_child(test_body)
	var direction = player.global_position.direction_to(_target_position)
	var distance = player.global_position.distance_to(_target_position)
	var collision = test_body.move_and_collide(direction * distance)

	if collision:
		_target_position = player.global_position + direction * \
		(collision.get_travel().length() - 10)
	test_body.queue_free()


func _on_cooldown_timer_timeout() -> void:
	is_on_cooldown = false
