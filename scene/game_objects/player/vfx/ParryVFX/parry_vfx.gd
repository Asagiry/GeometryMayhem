extends Node2D

@export var color: Color = Color(0,255, 255, 0.6)
@export var width: float = 3.0
@export var lifetime: float = 0.3
@export var fade_time: float = 0.2
@export var segments: int = 32

var angle: float
var radius: float

var _line: Line2D

func _ready():
	_line = Line2D.new()
	_line.width = width
	_line.default_color = color
	add_child(_line)


func setup(player: PlayerController):
	position = player.global_position
	rotation = player.rotation - PI/2
	angle = player.stats.parry_angle
	radius = player.stats.parry_radius

func show_parry():
	var points: Array[Vector2] = []
	var half_angle_rad = deg_to_rad(angle / 2.0)
	for i in range(segments + 1):
		var a = -half_angle_rad + (i / float(segments)) * (half_angle_rad * 2.0)
		points.append(Vector2(cos(a) * radius, sin(a) * radius))
	_line.points = points
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(lifetime).timeout
	var fade_tween = create_tween()
	fade_tween.tween_property(_line, "modulate:a", 0.0, fade_time)
	await fade_tween.finished
	queue_free()

func show_parry_v1():
	var points: Array[Vector2] = []
	var half_angle_rad = deg_to_rad(angle / 2.0)

	# Левая граница
	points.append(Vector2.ZERO)
	points.append(Vector2(cos(-half_angle_rad) * radius, sin(-half_angle_rad) * radius))

	# Дуга
	for i in range(1, segments):
		var a = -half_angle_rad + (i / float(segments)) * (half_angle_rad * 2.0)
		points.append(Vector2(cos(a) * radius, sin(a) * radius))

	# Правая граница
	points.append(Vector2(cos(half_angle_rad) * radius, sin(half_angle_rad) * radius))
	points.append(Vector2.ZERO)

	_line.points = points

	# Анимация появления и исчезновения
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(lifetime).timeout
	var fade_tween = create_tween()
	fade_tween.tween_property(_line, "modulate:a", 0.0, fade_time)
	await fade_tween.finished
	queue_free()
