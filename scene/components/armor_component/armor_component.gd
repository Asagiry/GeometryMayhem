class_name ArmorComponent

extends Node

var armor: float


func _ready():
	armor = owner.stats.armor

func calculate_reduced_damage(damage):
	return snappedf(damage, 0.1)
