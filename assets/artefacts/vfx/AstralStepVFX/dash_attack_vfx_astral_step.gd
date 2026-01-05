extends Node2D

@export var life_time: float = 0.5

var _time_elapsed: float = 0.0
var _length: float = 0.0

@onready var sprite_2d: Sprite2D = $Sprite2D

func setup(start_pos: Vector2, end_pos: Vector2):
	sprite_2d.global_position = (start_pos + end_pos) * 0.5
	var direction = end_pos - start_pos
	_length = direction.length()
	sprite_2d.rotation = direction.angle() + PI / 2.0
	var width_scale = 3.0
	var height_scale = _length / float(sprite_2d.texture.get_height())
	sprite_2d.scale = Vector2(width_scale, height_scale)
	var aspect_ratio = _length / (sprite_2d.texture.get_width() * width_scale)
	sprite_2d.material.set_shader_parameter("aspect_ratio", aspect_ratio)
	set_process(true)

func _process(delta: float):
	_time_elapsed += delta
	var progress = _time_elapsed / life_time
	sprite_2d.material.set_shader_parameter("progress", progress)
	if progress >= 1.0:
		set_process(false)
		queue_free()
