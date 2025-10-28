class_name StatModifierData

extends Resource

#DEBUFFS/BUFFS
@export var speed_multiplier: float = 1.0
@export var attack_multiplier: float = 1.0
@export var armor_multiplier: float = 1.0
@export var forward_receiving_damage_multiplier: float = 1.0
@export var attack_cd_multiplier: float = 1.0
@export var attack_duration_multiplier: float = 1.0

# Конструктор с параметрами по умолчанию
func _init(
	p_speed_multiplier: float = 1.0,
	p_attack_multiplier: float = 1.0,
	p_armor_multiplier: float = 1.0,
	p_forward_receiving_damage_multiplier: float = 1.0,
	p_attack_cd_multiplier: float = 1.0,
	p_attack_duration_multiplier: float = 1.0
) -> void:
	speed_multiplier = p_speed_multiplier
	attack_multiplier = p_attack_multiplier
	armor_multiplier = p_armor_multiplier
	forward_receiving_damage_multiplier = p_forward_receiving_damage_multiplier
	attack_cd_multiplier = p_attack_cd_multiplier
	attack_duration_multiplier = p_attack_duration_multiplier
