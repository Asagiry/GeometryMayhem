class_name BossController

extends CharacterBody2D

signal boss_health_changed(current_health, max_health)

@export var stats: BossStatData
@export var effect_receiver: EffectReceiver

var tentacle_id: Array[int] = [1, 2, 3, 4]

@onready var movement_component: BossMovementComponent = %MovementComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var armor_component: ArmorComponent = %ArmorComponent
@onready var tentacle_controller: TentacleController = %TentacleController


func _ready():
	_set_id_to_tentacles()
	_connect_signals()


func _set_id_to_tentacles():
	for tentacle in tentacle_controller.tentacles:
		tentacle.id = _get_tentacle_id()


func _connect_signals():
	health_component.died.connect(_on_died)
	health_component.health_decreased.connect(_on_boss_health_changed)
	health_component.health_increased.connect(_on_boss_health_changed)


func _physics_process(delta: float) -> void:
	movement_component.chase_player(delta)


func _get_tentacle_id():
	var id = tentacle_id.pick_random()
	tentacle_id.erase(id)
	return id


func get_stats():
	return stats


func get_effect_receiver():
	return effect_receiver


func _on_boss_health_changed(current_health, max_health):
	print("BOSS HEALTH = ", current_health)
	boss_health_changed.emit(current_health, max_health)


func _on_died():
	queue_free()
