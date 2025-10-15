class_name HealthComponent

extends Node

signal died
signal health_changed(current_health, max_health)

@export var max_health: float = 0

var current_health: float

@onready var armor_component: ArmorComponent = %ArmorComponent


func _ready():
	current_health = max_health


func take_damage(damage: DamageData):
	var final_damage = damage.amount
	current_health = max(current_health - final_damage, 0)
	emit_signal("health_changed", current_health, max_health)
	#print(owner, "=", current_health)
	if current_health <= 0:
		died.emit()
