extends Area2D

signal melee_detected(enemy_melee_targets: Array[Node2D])

var melee_targets: Array[Node2D] = []


func _on_area_entered(area: Area2D) -> void:
	if area is EnemyHurtBoxComponent:
		if area.owner.is_in_group("enemy"):
			melee_targets.append(area.owner)
			melee_detected.emit(melee_targets)


func _on_area_exited(area: Area2D) -> void:
	if area is EnemyHurtBoxComponent:
		if area.owner.is_in_group("enemy"):
			melee_targets.erase(area.owner)
			melee_detected.emit(melee_targets)
