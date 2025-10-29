class_name EnemyBombController

extends CharacterBody2D


@export var effects: Array[Effect]

var spawn_position: Vector2

@onready var enemy_state_machine: StateMachine = %EnemyStateMachine
@onready var movement_component: MovementComponent = %EnemyBombMovementComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var effect_receiver: EffectReceiver = %EffectReceiver
@onready var progress_bar: ProgressBar = $TestProgressBarOnlyForTest

@onready var agro_zone: Area2D = %AgroZone
@onready var hit_box: Area2D = %EnemyHitBox



func _ready():
	spawn_position = global_position
	health_component.died.connect(_on_died)
	_enter_variables()


func _process(_delta):
	progress_bar.value = health_component.current_health


func _on_died():
	queue_free()


func _enter_variables():
	var states: Array[State] = [
		EnemyBombAgroState.new(self),
		EnemyBombIdleState.new(self),
		EnemyBombAttackState.new(self),
		EnemyBombBackState.new(self)
	]
	enemy_state_machine.start_machine(states)
	enemy_state_machine.transition(EnemyBombIdleState.state_name)
