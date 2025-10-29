class_name ArmorComponent

extends Node

var armor: float

func _init(p_armor: float = 0.0):
	armor = p_armor

func calculate_reduced_damage(damage):
	return snappedf(damage, 0.1)
