class_name BossController

extends CharacterBody2D

signal tentacle_died(id: int)

@export var stats: BossStatData
@export var effect_receiver: EffectReceiver

@onready var movement_component: BossMovementComponent = %MovementComponent

@onready var health_component: BossHealthComponent = %HealthComponent
@onready var armor_component: BossArmorComponent = %ArmorComponent


func _ready():
	pass

func _physics_process(delta: float) -> void:
	movement_component.chase_player(delta)


func get_stats():
	return stats


func get_effect_receiver():
	return effect_receiver
