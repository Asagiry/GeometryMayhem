class_name EnemyController
extends CharacterBody2D

@export var stats: EnemyStatData
@export var effects: Array[Effect]

@onready var enemy_state_machine: StateMachine
@onready var effect_receiver: EffectReceiver

@onready var health_component: HealthComponent

@onready var armor_component: ArmorComponent
@onready var movement_component: EnemyMovementComponent
@onready var attack_controller: EnemyAttackController
@onready var loot_component: EnemyLootComponent

@onready var animated_sprite_2d: AnimatedSprite2D
@onready var aggro_zone: Area2D
@onready var attack_zone: Area2D


func _ready():
	init()


func init():
	await get_tree().create_timer(3).timeout
	_enter_stats()
	_connect_signals()
	_start_state_machine()


func _connect_signals():
	health_component.died.connect(_on_died)


func _enter_stats():
	health_component = HealthComponent.new()

	armor_component = ArmorComponent.new(stats.armor)

	movement_component = EnemyMovementComponent.new(stats.max_speed,
	stats.acceleration,
	stats.rotation_speed)

	movement_component.set_spawn_point(stats.spawn_point)

	attack_controller = EnemyAttackController.new(stats.attack_damage,
	stats.attack_duration,
	stats.attack_cd)

	loot_component = EnemyLootComponent.new(stats.knowledge_count,
	stats.echo_chance,
	stats.echo_count,stats.impulse_count)

	# Создаем aggro_zone
	aggro_zone = Area2D.new()
	var aggro_collision = CollisionShape2D.new()
	var aggro_shape = CircleShape2D.new()
	aggro_shape.radius = stats.aggro_range
	aggro_collision.shape = aggro_shape
	aggro_zone.add_child(aggro_collision)

	# Создаем attack_zone
	attack_zone = Area2D.new()
	var attack_collision = CollisionShape2D.new()
	var attack_shape = CircleShape2D.new()
	attack_shape.radius = stats.attack_range  # должно быть attack_range, а не aggro_range
	attack_collision.shape = attack_shape
	attack_zone.add_child(attack_collision)

func _start_state_machine():
	var states: Array[State] = [
		#EnemyAgroState.new(self),
		EnemyIdleState.new(self),
		#EnemyAttackState.new(self),
		#EnemyBackState.new(self)
	]
	enemy_state_machine.start_machine(states)
	enemy_state_machine.transition(EnemyIdleState.state_name)


func _on_died():
	queue_free()
