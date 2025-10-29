class_name ArmorComponent

extends Node

@export var armor: float = 0.0

#TODO реализовать
func calculate_reduced_damage(damage):
	return snappedf(damage, 0.1)
