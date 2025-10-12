class_name HealthComponent

extends Node

signal died
signal health_decreased

@export var max_health: float = 0

var current_health: float

@onready var armor_component: ArmorComponent = %ArmorComponent


func _ready():
	current_health = max_health


func take_damage(damage):
	var reduced_damage = damage
	if armor_component != null:
		reduced_damage = armor_component.calculate_reduced_damage(damage)
	current_health = max(current_health - reduced_damage, 0)
	#print(owner.get_groups()," = ", current_health)
	health_decreased.emit()
	Callable(check_death).call_deferred()


func check_death():
	if current_health == 0:
		died.emit()
