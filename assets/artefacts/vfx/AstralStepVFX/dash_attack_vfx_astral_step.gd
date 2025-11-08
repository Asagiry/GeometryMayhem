extends Node2D

var life_time := 0.5
var fade := 1.0
@onready var sprite_2d: Sprite2D = $Sprite2D


func setup(start_pos: Vector2, end_pos: Vector2):
	sprite_2d.global_position = (start_pos + end_pos) * 0.5

	var direction = end_pos - start_pos
	var length = direction.length()

	sprite_2d.rotation = direction.angle() + PI / 2.0

	# Масштабируем спрайт
	sprite_2d.scale = Vector2(10.0, length / sprite_2d.texture.get_height())

	set_process(true)

func _process(delta):
	modulate.a = fade
	fade -= delta / life_time
	if fade <= 0:
		set_process(false)
		queue_free()
