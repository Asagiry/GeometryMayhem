class_name EnemyController
extends CharacterBody2D

signal enemy_died()

@export var stats: EnemyStatData
@export var effects: Array[Effect]
@export var effect_receiver: EffectReceiver

var is_stunned: bool = false
var get_back: bool = false

@onready var state_machine: EnemyStateMachine = %EnemyStateMachine

@onready var health_component: HealthComponent = %HealthComponent
@onready var armor_component: ArmorComponent = %ArmorComponent
@onready var movement_component: EnemyMovementComponent = %EnemyMovementComponent
@onready var attack_controller: EnemyAttackController = %EnemyAttackController

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@onready var aggro_zone: Area2D = %AggroZone
@onready var attack_zone: Area2D = %AttackZone
@onready var collision = %EnvironmentCollision
@onready var hurt_box_shape: CollisionShape2D = %HurtBoxShape
@onready var hurt_box: HurtBox = %HurtBox


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
	effects = effects.duplicate(true)


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
		EnemyAggroState.new(self),
		EnemyStunState.new(self)
	]
	state_machine.start_machine(states)


func _on_died():
	enemy_died.emit()
	Global.enemy_died.emit(stats)
	queue_free()


func set_stun(duration):
	is_stunned = true
	state_machine.set_stun(duration)


func set_spawn_point(spawn_point: Vector2):
	stats.spawn_point = spawn_point


func get_stats():
	return stats


func get_effect_receiver():
	return effect_receiver


func _on_attack_zone_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_attack_zone_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_attack_deal_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
