class_name PlayerController

extends CharacterBody2D

#region var
@export var rotation_speed: float = 9.0 #9.0(AI)
@export var grace_period_time: float = 0.5
@export var effects: Array[Effect]

var last_direction: Vector2 = Vector2.UP
var base_speed: float
var dash_from_mouse := false
var parry_from_mouse := false
var is_input_blocked := false

@onready var player_state_machine: StateMachine = %PlayerStateMachine
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
	var states: Array[State] = [
		PlayerIdleState.new(self),
		PlayerMovementState.new(self),
		PlayerDashState.new(self),
		PlayerParryState.new(self)]
	player_state_machine.start_machine(states)
	base_speed = movement_component.max_speed


func _connect_signals():
	health_component.died.connect(_on_died)


func handle_movement(delta: float):
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	if direction != Vector2.ZERO:
		last_direction = direction
	velocity = movement_component.accelerate_to_direction(direction)
	if direction!=Vector2.ZERO:
		var target_angle = last_direction.angle() + PI / 2
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	move_and_slide()


func get_movement_vector() -> Vector2:
	var vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return vector


func _on_died():
	queue_free()
