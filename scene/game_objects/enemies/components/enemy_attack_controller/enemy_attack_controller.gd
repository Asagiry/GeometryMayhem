class_name EnemyAttackController

extends Node

var attack_damage: float
var attack_duration: float
var attack_cd: float


func _init(p_attack_damage: float = 0.0,
p_attack_duration: float = 0.0,
p_attack_cd: float = 0.0):
	attack_damage = p_attack_damage
	attack_duration = p_attack_duration
	attack_cd = p_attack_cd
