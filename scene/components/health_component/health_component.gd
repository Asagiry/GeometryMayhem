class_name HealthComponent

extends Node

signal died
signal health_changed(current_health, max_health)

const ROUNDING_ACCURACY: float = 0.1

@export var max_health: float = 0

var current_health: float
var forward_damage_multiplier: float = 1.0

@onready var armor_component: ArmorComponent = %ArmorComponent


func _ready():
	current_health = max_health


func take_damage(damage: DamageData):
	var final_damage = armor_component.calculate_reduced_damage(
		damage.amount * forward_damage_multiplier,
	)
	current_health = snappedf(max(current_health - final_damage, 0), ROUNDING_ACCURACY)
	emit_signal("health_changed", current_health, max_health)
	#print(owner, "=", current_health)
	if current_health <= 0:
		died.emit()
