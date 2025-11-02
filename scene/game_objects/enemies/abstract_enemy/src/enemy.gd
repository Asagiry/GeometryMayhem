class_name EnemyController
extends CharacterBody2D

signal enemy_died()

@export var stats: EnemyStatData
@export var effects: Array[Effect]
@export var effect_receiver: EffectReceiver

var is_stunned: bool = false

@onready var state_machine: StateMachine = %EnemyStateMachine

@onready var health_component: HealthComponent = %HealthComponent
@onready var armor_component: ArmorComponent = %ArmorComponent
@onready var movement_component: EnemyMovementComponent = %EnemyMovementComponent
@onready var attack_controller: EnemyAttackController = %EnemyAttackController

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@onready var aggro_zone: Area2D = %AggroZone
@onready var attack_zone: Area2D = %AttackZone
@onready var collision: CollisionShape2D = %EnviromentCollision
@onready var hurt_box_shape: CollisionShape2D = %HurtBoxShape


func _ready():
	init()


func init():
	_enter_stats()
	_enter_varibles()
	_connect_signals()
	_start_state_machine()



func _connect_signals():
	health_component.died.connect(_on_died)


func _enter_varibles():
	stats = stats.duplicate(true)
	effects = effects.duplicate(true)
	effect_receiver = effect_receiver.duplicate()


func _enter_stats():
	var aggro_collision = CollisionShape2D.new()
	var aggro_shape = CircleShape2D.new()
	aggro_shape.radius = stats.aggro_range
	aggro_collision.shape = aggro_shape
	aggro_zone.add_child(aggro_collision)

	var attack_collision = CollisionShape2D.new()
	var attack_shape = CircleShape2D.new()
	attack_shape.radius = stats.attack_range_zone
	attack_collision.shape = attack_shape
	attack_zone.add_child(attack_collision)


func _start_state_machine():
	var states: Array[State] = [
		EnemyIdleState.new(self),
		EnemyAttackState.new(self),
		EnemyBackState.new(self),
		EnemyAggroState.new(self),
		EnemyStunState.new(self)
	]
	state_machine.start_machine(states)

func _on_died():
	enemy_died.emit()
	Global.enemy_died.emit(stats)
	queue_free()


func set_spawn_point(spawn_point: Vector2):
	stats.spawn_point = spawn_point
