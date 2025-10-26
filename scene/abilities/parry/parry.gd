class_name Parry
extends Node2D

signal projectile_detected(projectile: Area2D)
signal melee_detected(enemy_melee_targets: Array[Node2D])

var melee_targets: Array[Node2D] = []
var parry_angle: float
var parry_radius: float
var collision_sector: CollisionShape2D

@onready var parry_area: Area2D = %ParryArea

func init(angle: float, radius: float) -> void:
	parry_angle = angle
	parry_radius = radius

	collision_sector = CollisionShape2D.new()

	if angle >= 360.0:
		# 🔹 Полный круг
		var circle := CircleShape2D.new()
		circle.radius = radius
		collision_sector.shape = circle
	else:
		var shape := ConvexPolygonShape2D.new()
		var half_angle_rad := deg_to_rad(parry_angle / 2.0)
		var segments := 16
		var points: Array[Vector2] = [Vector2.ZERO]
		for i in range(segments + 1):
			var a = -half_angle_rad + (i / float(segments)) * (half_angle_rad * 2.0)
			points.append(Vector2(cos(a) * radius, sin(a) * radius))
		shape.points = points
		collision_sector.shape = shape
		collision_sector.rotation = -PI/2

func _ready() -> void:
	parry_area.add_child(collision_sector)


func _on_parry_area_entered(area: Area2D) -> void:
	if area is EnemyHurtBoxComponent:
		if area.owner != null:
			if area.owner.is_in_group("enemy"):
				melee_targets.append(area.owner)
				melee_detected.emit(melee_targets)


func _on_parry_area_exited(area: Area2D) -> void:
	if area is EnemyHurtBoxComponent:
		if area.owner != null:
			if area.owner.is_in_group("enemy"):
				melee_targets.erase(area.owner)
				melee_detected.emit(melee_targets)
