class_name EnemyController
extends CharacterBody2D

signal enemy_died()

@export var stats: EnemyStatData
@export var effects: Array[Effect]
@export var effect_receiver: EffectReceiver

var enemy_type: Util.EnemyType = Util.EnemyType.NORMAL
var is_stunned: bool = false
var get_back: bool = false

var aggro_zone_radius = null
var attack_zone_radius = null

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
	_enter_variables()
	_connect_signals()
	_start_state_machine()


func _enter_stats():
	var aggro_collision = CollisionShape2D.new()
	var aggro_shape = CircleShape2D.new()
	if aggro_zone_radius != null:
		aggro_shape.radius = aggro_zone_radius
	else:
		aggro_shape.radius = stats.aggro_range
	aggro_collision.shape = aggro_shape
	aggro_zone.add_child(aggro_collision)
	var attack_collision = CollisionShape2D.new()
	var attack_shape = CircleShape2D.new()
	if attack_zone_radius != null:
		attack_shape.radius = attack_zone_radius
	else:
		attack_shape.radius = stats.attack_range_zone
	attack_collision.shape = attack_shape
	attack_zone.add_child(attack_collision)


func _connect_signals():
	health_component.died.connect(_on_died)


func _enter_variables():
	effects = effects.duplicate(true)


func _start_state_machine():
	var states: Array[State] = [
		EnemyIdleState.new(self),
		EnemyAttackState.new(self),
		EnemyAggroState.new(self),
		EnemyStunState.new(self)
	]
	state_machine.start_machine(states)


func transition_to_aggro_state():
	state_machine.transition(EnemyAggroState.state_name)


func apply_knockback(force: Vector2):
	if movement_component:
		movement_component.apply_knockback(force)


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

func set_facing_direction(dir: Vector2,attack_spawn_point : Node2D) -> void:
	if abs(dir.x) < 0.01:
		return
	var facing_left := dir.x < 0
	animated_sprite_2d.flip_h = facing_left
	var p = attack_spawn_point.position
	var sign = -1.0 if facing_left else 1.0
	p.x = abs(p.x) * sign
	attack_spawn_point.position = p


func set_facing_direction_360(dir: Vector2, attack_spawn_point: Node2D) -> void:
	# угол направления до игрока
	var target_dir_angle := dir.angle()
	var angle := target_dir_angle - PI / 2.0
	animated_sprite_2d.rotation = angle
	hurt_box_shape.rotation = angle
	var dist_to_mouth := 20.0
	attack_spawn_point.position = Vector2.DOWN * dist_to_mouth
