@tool
extends Control
class_name ProgressBarPolygon

# Цвет фона (пустой части)
@export var background_color: Color = Color(0.2, 0.2, 0.2, 0.8)
# Цвет заполненной части
@export var fill_color: Color = Color(0.3, 0.8, 0.3, 1.0)
# Цвет обводки
@export var outline_color: Color = Color(0, 0, 0, 0.5)
@export var outline_width: float = 2.0

# Массив локальных вершин (в нормализованных координатах от 0 до 1)
@export var points: Array[Vector2] = [
	Vector2(0, 1),    # Левая нижняя
	Vector2(0.2, 0),  # Левая верхняя
	Vector2(0.8, 0),  # Правая верхняя
	Vector2(1, 1)     # Правая нижняя
]:
	set(value):
		points = value
		queue_redraw()

# Текущий прогресс (от 0.0 до 1.0)
@export var value: float = 0.0:
	set(v):
		value = clamp(v, 0.0, 1.0)
		queue_redraw()

@export var flip_x: bool = false:
	set(value):
		flip_x = value
		queue_redraw()

@export var flip_y: bool = false:
	set(value):
		flip_y = value
		queue_redraw()

func _ready():
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _process(_delta):
	if Engine.is_editor_hint():
		queue_redraw()

func _draw():
	if points.size() < 3:
		return

	var s = size
	if s.x <= 0 or s.y <= 0:
		return

	# Масштабируем нормализованные точки под размер узла
	var transformed_points: Array[Vector2] = []
	for p in points:
		var px = p.x * s.x
		var py = p.y * s.y
		if flip_x:
			px = s.x - px
		if flip_y:
			py = s.y - py
		transformed_points.append(Vector2(px, py))

	# Рисуем фон
	draw_colored_polygon(transformed_points, background_color)

	# Рисуем обводку
	if outline_width > 0:
		var outline_points = transformed_points.duplicate()
		outline_points.append(transformed_points[0])
		draw_polyline(outline_points, outline_color, outline_width)

	# Рисуем заполнение
	if value > 0:
		var fill_points = get_fill_polygon(transformed_points, value)
		draw_colored_polygon(fill_points, fill_color)

# Функция, которая возвращает полигональную область, заполненную до указанного значения
func get_fill_polygon(poly_points: Array[Vector2], fill_ratio: float) -> Array[Vector2]:
	if fill_ratio >= 1.0:
		return poly_points

	var left = float('inf')
	var right = float('-inf')
	for p in poly_points:
		left = min(left, p.x)
		right = max(right, p.x)

	var fill_x = lerp(left, right, fill_ratio)

	var fill_poly: Array[Vector2] = []
	var clip_line = PackedVector2Array([Vector2(fill_x, 0), Vector2(fill_x, size.y)])

	# Используем Clipper2D или просто обрезаем по вертикальной линии
	for i in range(poly_points.size()):
		var p0 = poly_points[i]
		var p1 = poly_points[(i + 1) % poly_points.size()]

		if p0.x <= fill_x:
			fill_poly.append(p0)
		if (p0.x < fill_x and p1.x > fill_x) or (p0.x > fill_x and p1.x < fill_x):
			# Пересечение с вертикальной линией
			var x = fill_x
			var y = p0.y + (p1.y - p0.y) * (x - p0.x) / (p1.x - p0.x)
			fill_poly.append(Vector2(x, y))

	return fill_poly
