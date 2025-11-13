@tool
class_name HealthBarUI

extends NinePatchRect

const ANIMATION_DURATION : float = 0.5

@export var min_value: float = 0.0
@export var max_value: float = 100.0:
	set = set_max_value
@export var value: float = 100.0:
	set = set_value

var _tween: Tween

@onready var progress_shader: ShaderMaterial = %ProgressShader.material
@onready var current_value_label: Label = %CurrentValue
@onready var max_value_label: Label = %MaxValue


func _ready() -> void:
	update_texture(0)


func set_max_value(p_value: float):
	max_value = p_value

	if max_value_label == null:
		return
	max_value_label.text = "%.0f" % p_value


func set_value(p_value: float):
	var diff = p_value-value
	value = clampf(p_value,min_value,max_value)
	if progress_shader:
		update_texture(sign(diff))

	if current_value_label == null:
		return
	current_value_label.text = "%.0f" % value

func update_texture(direction: int):
	var progress = value / (max_value - min_value)

	if direction<0:
		get_tween().tween_property(
		progress_shader
		,"shader_parameter/progress_tail"
		,progress
		,ANIMATION_DURATION)
		progress_shader.set_shader_parameter("progress",progress)
	elif direction>0:
		get_tween().tween_property(
		progress_shader
		,"shader_parameter/progress"
		,progress
		,ANIMATION_DURATION)
		progress_shader.set_shader_parameter("progress_tail",progress)
	else:
		progress_shader.set_shader_parameter("progress_tail",progress)
		progress_shader.set_shader_parameter("progress",progress)

func get_tween() -> Tween:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT)
	return _tween
