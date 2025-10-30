class_name EnemyAttackController

extends Node

var attack_damage: float
var attack_duration: float
var attack_cd: float

func _ready():
	attack_damage = owner.stats.attack_damage
	attack_duration = owner.stats.attack_duration
	attack_cd = owner.stats.attack_cd
