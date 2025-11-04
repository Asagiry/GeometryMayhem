class_name Parry
extends Node2D

signal projectile_detected(projectile: Area2D)
signal melee_detected(enemy_melee_targets: Array[Node2D])

var parry_angle: float
var parry_radius: float
var collision_sector: CollisionShape2D

@onready var parry_area: Area2D = %ParryArea


func _ready() -> void:
	# Создаем начальный коллайдер если параметры уже установлены
	if parry_angle > 0 and parry_radius > 0:
		_update_collision_shape()


func init(angle: float, radius: float) -> void:
	parry_angle = angle
	parry_radius = radius

	# Обновляем коллизию (работает и в _ready и после)
	_update_collision_shape()


func update_parameters(angle: float, radius: float) -> void:
	"""Обновляет параметры и пересоздает коллизию"""
	if angle == parry_angle and radius == parry_radius:
		return  # Ничего не менялось

	parry_angle = angle
	parry_radius = radius
	_update_collision_shape()


func _update_collision_shape() -> void:
	"""Создает или обновляет коллизионную форму"""
	if not parry_area:
		push_error("ParryArea not found!")
		return

	# Удаляем старый коллайдер если есть
	_remove_old_collision_shape()

	# Создаем новый коллайдер
	collision_sector = CollisionShape2D.new()

	if parry_angle >= 360.0:
		# 🔹 Полный круг
		var circle := CircleShape2D.new()
		circle.radius = parry_radius
		collision_sector.shape = circle
	else:
		# 🔹 Сектор
		var shape = ConvexPolygonShape2D.new()
		var half_angle_rad = deg_to_rad(parry_angle / 2.0)
		var segments = max(8, int(parry_angle / 22.5))  # Автоматическое кол-во сегментов
		var points: PackedVector2Array = [Vector2.ZERO]

		for i in range(segments + 1):
			var angle_rad = -half_angle_rad + (i / float(segments)) * (half_angle_rad * 2.0)
			points.append(Vector2(cos(angle_rad) * parry_radius, sin(angle_rad) * parry_radius))

		shape.points = points
		collision_sector.shape = shape
		collision_sector.rotation = -PI / 2

	# Добавляем новый коллайдер
	parry_area.add_child(collision_sector)

	print("✅ Parry collision updated - Angle: ", parry_angle, "°, Radius: ", parry_radius)


func _remove_old_collision_shape() -> void:
	"""Удаляет старый коллайдер если он существует"""
	if collision_sector and is_instance_valid(collision_sector):
		if collision_sector.get_parent():
			collision_sector.get_parent().remove_child(collision_sector)
		collision_sector.queue_free()
		collision_sector = null

	# Также удаляем любые другие CollisionShape2D дети в parry_area
	for child in parry_area.get_children():
		if child is CollisionShape2D:
			parry_area.remove_child(child)
			child.queue_free()


# Дополнительные полезные методы
func enable_collision(enabled: bool) -> void:
	"""Включает/выключает коллизию"""
	if collision_sector:
		collision_sector.disabled = not enabled


func get_collision_shape() -> CollisionShape2D:
	"""Возвращает текущую коллизионную форму"""
	return collision_sector


func cleanup() -> void:
	"""Очищает ресурсы перед удалением"""
	_remove_old_collision_shape()
