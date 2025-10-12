extends CharacterBody2D

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

@onready var animated_sprite_2d = %AnimatedSprite2D
@onready var grace_period = %GracePeriod
@onready var movement_component = %MovementComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var dash_attack_controller: DashAttackController = %DashAttackController
@onready var parry_component: ParryComponent = %ParryComponent


func _ready():
	enemies_colliding = 0
	current_player_state = PlayerStates.MOVE_STATE
	base_speed = movement_component.max_speed
	health_component.died.connect(_on_died)
	health_component.health_decreased.connect(_on_health_decreased)


func _process(delta):
	if is_input_blocked:
		return  
	change_current_state()
	match current_player_state:
		PlayerStates.MOVE_STATE:
			var movement_vector = get_movement_vector()
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
		PlayerStates.PARRY_STATE:
			parry_component.activate_parry()
			animated_sprite_2d.play("block")
			await animated_sprite_2d.animation_finished
		PlayerStates.DASH_STATE:
			var input_state_for_dash = Input.is_action_just_pressed("left_mouse_click_dash")
			dash_attack_controller.activate_dash(input_state_for_dash)
				
	check_if_damaged()


func change_current_state():
	if Input.is_action_just_pressed("left_mouse_click_dash") or \
	Input.is_action_just_pressed("space_dash"):
		current_player_state = PlayerStates.DASH_STATE
	elif Input.is_action_just_pressed("parry"):
		current_player_state = PlayerStates.PARRY_STATE
	else:
		current_player_state = PlayerStates.MOVE_STATE

func get_movement_vector() -> Vector2:
	var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(movement_x, movement_y)


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
