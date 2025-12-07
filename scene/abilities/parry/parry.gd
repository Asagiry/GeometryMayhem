class_name Parry
extends Node2D

var parry_angle: float
var parry_radius: float
var collision_sector: CollisionShape2D

# Списки активных целей внутри зоны
var enemies_in_range: Array[CharacterBody2D] = []
var projectiles_in_range: Array[Area2D] = []

@onready var parry_area: Area2D = %ParryArea

func _ready() -> void:
	# Подключаем сигналы для мониторинга
	parry_area.body_entered.connect(_on_body_entered)
	parry_area.body_exited.connect(_on_body_exited)
	parry_area.area_entered.connect(_on_area_entered)
	parry_area.area_exited.connect(_on_area_exited)

	if parry_angle > 0 and parry_radius > 0:
		_update_collision_shape()

func init(angle: float, radius: float) -> void:
	parry_angle = angle
	parry_radius = radius

func update_parameters(angle: float, radius: float) -> void:
	if angle == parry_angle and radius == parry_radius:
		return

	parry_angle = angle
	parry_radius = radius
	_update_collision_shape()
	_refresh_targets()


func _refresh_targets():
	enemies_in_range.clear()
	projectiles_in_range.clear()

	await get_tree().physics_frame

	if not is_instance_valid(parry_area): return

	for body in parry_area.get_overlapping_bodies():
		_on_body_entered(body)
	for area in parry_area.get_overlapping_areas():
		_on_area_entered(area)


func _on_body_entered(body: Node2D):
	# Проверяем, враг ли это (по классу или группе)
	if body is EnemyController:
		if not enemies_in_range.has(body):
			enemies_in_range.append(body)


func _on_body_exited(body: Node2D):
	if enemies_in_range.has(body):
		enemies_in_range.erase(body)


func _on_area_entered(area: Area2D):
	if area.is_in_group("projectile"):
		if not projectiles_in_range.has(area):
			projectiles_in_range.append(area)

func _on_area_exited(area: Area2D):
	if projectiles_in_range.has(area):
		projectiles_in_range.erase(area)

# --- Обновление Коллизии (без изменений логики) ---
func _update_collision_shape() -> void:
	if not parry_area: return

	_remove_old_collision_shape()
	collision_sector = CollisionShape2D.new()

	if parry_angle >= 360.0:
		var circle := CircleShape2D.new()
		circle.radius = parry_radius
		collision_sector.shape = circle
	else:
		var shape = ConvexPolygonShape2D.new()
		var half_angle_rad = deg_to_rad(parry_angle / 2.0)
		var segments = max(8, int(parry_angle / 22.5))
		var points: PackedVector2Array = [Vector2.ZERO]

		for i in range(segments + 1):
			var angle_rad = -half_angle_rad + (i / float(segments)) * (half_angle_rad * 2.0)
			points.append(Vector2(cos(angle_rad) * parry_radius, sin(angle_rad) * parry_radius))

		shape.points = points
		collision_sector.shape = shape
		collision_sector.rotation = -PI / 2

	parry_area.add_child(collision_sector)

func _remove_old_collision_shape() -> void:
	if collision_sector and is_instance_valid(collision_sector):
		collision_sector.queue_free()
		collision_sector = null
	for child in parry_area.get_children():
		if child is CollisionShape2D:
			child.queue_free()

func force_refresh_targets():
	if not is_instance_valid(parry_area): return
	enemies_in_range.clear()
	projectiles_in_range.clear()
	var bodies = parry_area.get_overlapping_bodies()
	for body in bodies:
		_on_body_entered(body)
	var areas = parry_area.get_overlapping_areas()
	for area in areas:
		_on_area_entered(area)


func cleanup() -> void:
	enemies_in_range.clear()
	projectiles_in_range.clear()
	_remove_old_collision_shape()
