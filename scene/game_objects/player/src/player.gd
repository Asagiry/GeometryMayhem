class_name PlayerController

extends CharacterBody2D

#region var
@export var grace_period_time: float = 0.5
@export var effects: Array[Effect]

var dash_from_mouse: bool = false
var parry_from_mouse: bool = false
var is_input_blocked: bool = false

@onready var player_state_machine: StateMachine = %PlayerStateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var grace_period: Timer = %GracePeriod
@onready var movement_component: PlayerMovementComponent = %MovementComponent
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


func _connect_signals():
	health_component.died.connect(_on_died)


func _on_died():
	queue_free()
