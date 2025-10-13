class_name Parry

extends Node2D

signal projectile_detected(projectile: Area2D)
signal melee_detected(enemy_melee_targets: Array[Node2D])

var melee_targets: Array[Node2D] = []

@onready var parry_melee_area: Area2D = %ParryMeleeArea
@onready var parry_projectile_area: Area2D = %ParryProjectileArea


func _on_parry_projectile_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("projectiles"):
		projectile_detected.emit(area)


func _on_parry_melee_area_area_entered(area: Area2D) -> void:
	if area is EnemyHurtBoxComponent:
		if area.owner != null:
			if area.owner.is_in_group("enemy"):
				melee_targets.append(area.owner)
				melee_detected.emit(melee_targets)


func _on_parry_melee_area_area_exited(area: Area2D) -> void:
	if area is EnemyHurtBoxComponent:
		if area.owner != null:
			if area.owner.is_in_group("enemy"):
				melee_targets.erase(area.owner)
				melee_detected.emit(melee_targets)
