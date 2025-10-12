extends CharacterBody2D

#region var
enum PlayerStates {
	DASH_STATE,
	PARRY_STATE,
	MOVE_STATE,
}

@export var rotation_speed: float = 9.0 #9.0(AI)
@export var grace_period_time: float = 0.5

var last_direction: Vector2 = Vector2.ZERO
var enemies_colliding: int
var enemy_damage: float
var base_speed: float
var current_player_state: PlayerStates
var is_input_blocked: bool
var dash_from_mouse := false

@onready var animated_sprite_2d = %AnimatedSprite2D
@onready var grace_period = %GracePeriod
@onready var movement_component = %MovementComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var dash_attack_controller: DashAttackController = %DashAttackController
@onready var parry_controller: ParryController = %ParryController

#endregion


func _ready():
	_enter_variables()
	_connect_signals()
	#Engine.time_scale = 0.3


func _enter_variables():
	enemies_colliding = 0
	current_player_state = PlayerStates.MOVE_STATE
	base_speed = movement_component.max_speed


func _connect_signals():
	health_component.died.connect(_on_died)
	health_component.health_decreased.connect(_on_health_decreased)


func _process(delta: float):
	_handle_input(delta)
	check_if_damaged()


func _handle_input(delta: float):
	if !is_input_blocked:
		match current_player_state:
			PlayerStates.MOVE_STATE:
				_handle_move_state(delta)
			PlayerStates.PARRY_STATE:
				_handle_parry_state()
			PlayerStates.DASH_STATE:
				_handle_dash_state()


#func _change_current_state():
	#if Input.is_action_just_pressed("left_mouse_click_dash") or \
	#Input.is_action_just_pressed("space_dash"):
		#current_player_state = PlayerStates.DASH_STATE
	#elif Input.is_action_just_pressed("parry"):
		#current_player_state = PlayerStates.PARRY_STATE
	#else:
		#current_player_state = PlayerStates.MOVE_STATE


func _handle_move_state(delta: float):
	var movement_vector = _get_movement_vector()
	var direction = movement_vector.normalized()
	if direction != Vector2.ZERO:
		last_direction = direction
	velocity = movement_component.accelerate_to_direction(direction)
	if direction != Vector2.ZERO:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	var target_angle = last_direction.angle() + PI / 2
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	move_and_slide()

	if Input.is_action_just_pressed("left_mouse_click_dash"):
		dash_from_mouse = true
		current_player_state = PlayerStates.DASH_STATE
	elif Input.is_action_just_pressed("space_dash"):
		dash_from_mouse = false
		current_player_state = PlayerStates.DASH_STATE
	elif Input.is_action_just_pressed("parry"):
		current_player_state = PlayerStates.PARRY_STATE

func _handle_parry_state():
	animated_sprite_2d.speed_scale = 1 / (parry_controller.push_duration)
	animated_sprite_2d.play("block")
	parry_controller.activate_parry()
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.speed_scale = 1
	current_player_state = PlayerStates.MOVE_STATE


func _handle_dash_state():
	var tween2 = create_tween()

	tween2.tween_property(
		animated_sprite_2d,
		"scale", 
		Vector2(0.25, 1), 
		dash_attack_controller.dash_duration) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	dash_attack_controller.activate_dash(dash_from_mouse)

	tween2.finished.connect(func():
		var back_tween = create_tween()
		back_tween.tween_property(
			animated_sprite_2d, 
			"scale", 
			Vector2(1, 1),  
			dash_attack_controller.dash_duration / 2) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		current_player_state = PlayerStates.MOVE_STATE
	)


func _get_movement_vector() -> Vector2:
	var vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return vector


func check_if_damaged():
	if enemies_colliding == 0 || !grace_period.is_stopped():
		return
	health_component.take_damage(enemy_damage)
	grace_period.start(grace_period_time)


func _on_player_hurt_box_area_entered(area: Area2D) -> void:
	if not area.has_method("enemy_damage"):
		return
	enemy_damage = area.enemy_damage()
	enemies_colliding += 1
	check_if_damaged()


func _on_player_hurt_box_area_exited(_area: Area2D) -> void:
	enemies_colliding -= 1


func _on_died():
	queue_free()


func _on_health_decreased():
	pass
