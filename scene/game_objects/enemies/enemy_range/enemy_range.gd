class_name EnemyRangeController
extends CharacterBody2D

@export var effects: Array[Effect]
@onready var enemy_state_machine: StateMachine = %EnemyRangeStateMachine
@onready var movement_component: MovementComponent = %EnemyRangeMovementComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var effect_receiver: EffectReceiver = %EffectReceiver
@onready var progress_bar: ProgressBar = $TestProgressBarOnlyForTest

@onready var agro_zone: Area2D = %AgroZone
@onready var hit_box: Area2D = %EnemyHitBox

var spawn_position: Vector2

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
		EnemyRangeAgroState.new(self),
		EnemyRangeIdleState.new(self),
		EnemyRangeAttackState.new(self),
		EnemyRangeBackState.new(self)  
	]
	enemy_state_machine.start_machine(states)
	enemy_state_machine.transition(EnemyRangeIdleState.state_name)
	
