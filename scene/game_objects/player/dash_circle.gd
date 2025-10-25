class_name DashCircle

extends Control

var circle_range: float
var circle_color: Color = Color.RED
var circle_thickness: float = 1.0
var circle_alpha: float = 0.1

var show_circle: bool = false


func set_range(dash_range):
	circle_range = dash_range


func _draw():
	if show_circle:
		var color_with_alpha = circle_color
		color_with_alpha.a = circle_alpha
		draw_arc(Vector2.ZERO, circle_range, 0, TAU, 64, color_with_alpha, circle_thickness)


func show_dash_range():
	show_circle = true
	queue_redraw()


func hide_dash_range():
	show_circle = false
	queue_redraw()
