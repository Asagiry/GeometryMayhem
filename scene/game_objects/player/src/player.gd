class_name PlayerController

extends CharacterBody2D

#region var
@export var grace_period_time: float = 0.5
@export var effects: Array[Effect]
@export var effect_receiver: EffectReceiver

var dash_from_mouse: bool = false
var parry_from_mouse: bool = false
var is_input_blocked: bool = false
var is_stunned: bool = false

@onready var player_state_machine: StateMachine = %PlayerStateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var grace_period: Timer = %GracePeriod
@onready var movement_component: PlayerMovementComponent = %MovementComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var player_attack_controller: PlayerAttackController = %PlayerAttackController
@onready var parry_controller: ParryController = %ParryController
@onready var collision: CollisionShape2D = %CollisionShape2D

#endregion

func _ready():
	Global.player_spawned.emit(self)
	_enter_variables()
	_connect_signals()
	Engine.time_scale = 1


func _enter_variables():
	var states: Array[State] = [
		PlayerIdleState.new(self),
		PlayerMovementState.new(self),
		PlayerDashState.new(self),
		PlayerParryState.new(self),
		PlayerStunState.new(self)]
	player_state_machine.start_machine(states)


func _connect_signals():
	health_component.died.connect(_on_died)
	effect_receiver.input_disabled.connect(_on_input_disabled)


func _on_died():
	Global.player_died.emit()
	queue_free()


func _on_input_disabled(status: bool):
	is_input_blocked = status
