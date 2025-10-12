class_name ArmorComponent

extends Node

@export var physical_armor: float = 0.0


#формула дота2, 10 армора = 37% снижение физического урона
func calculate_reduced_damage(damage):
	return damage - (damage * ((0.052 * physical_armor) / (0.9 + 0.048 * physical_armor)))
