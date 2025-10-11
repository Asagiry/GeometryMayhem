extends Area2D

signal projectile_detected(projectile: Area2D)

func _on_area_entered(area: Area2D):
	if area.is_in_group("projectiles"):
		projectile_detected.emit(area)
