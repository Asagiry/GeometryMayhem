@tool
extends Control
class_name ColorPolygon

@export var color: Color = Color(1, 0.5, 0.3):
	set(value):
		color = value
		queue_redraw()

@export var outline_color: Color = Color(0, 0, 0, 0.5)
@export var outline_width: float = 2.0

# Массив локальных вершин (в нормализованных координатах от 0 до 1)
@export var points: Array[Vector2] = [
	Vector2(0, 1),
	Vector2(0.5, 0),
	Vector2(1, 1)
]:
	set(value):
		points = value
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
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _process(_delta):
	if Engine.is_editor_hint():
		queue_redraw()

func _draw():
	if points.is_empty():
		return

	var s = size
	if s.x <= 0 or s.y <= 0:
		return


	# Масштабируем нормализованные точки под rect_size
	var transformed_points: Array[Vector2] = []
	for p in points:
		var px = p.x * s.x
		var py = p.y * s.y
		if flip_x:
			px = s.x - px
		if flip_y:
			py = s.y - py
		transformed_points.append(Vector2(px, py))

	draw_colored_polygon(transformed_points, color)
	draw_multiline(transformed_points + [transformed_points[0]], outline_color, outline_width)
