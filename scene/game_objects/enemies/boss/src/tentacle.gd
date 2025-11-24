class_name Tentacle

extends CharacterBody2D

signal tentacle_died(id: int)
signal tentacle_health_changed(current_health, max_health, id: int)

@export var effect_receiver: EffectReceiver
@export var stats: TentacleStatData

var id: int

@onready var health_component: HealthComponent = %HealthComponent
@onready var armor_component: ArmorComponent = %ArmorComponent

func _ready() -> void:
	_connect_signals()

func _connect_signals():
	health_component.died.connect(_on_died)
	health_component.health_decreased.connect(_on_health_changed)
	health_component.health_increased.connect(_on_health_changed)

func get_effect_receiver():
	return effect_receiver


func get_stats():
	return stats


func _on_health_changed(current_health, max_health):
	tentacle_health_changed.emit(current_health, max_health, id)


func _on_died():
	tentacle_died.emit(id)
