@tool
class_name ResonanceLevelUI

extends MarginContainer

const ANIMATION_DURATION: float = 1.0

@export var current_lvl: int = 0:
	set = set_current_lvl
@export var min_lvl: int = 0
@export var max_lvl: int = 10

var _tween_fill: Tween
var _tween_border: Tween

@onready var current_lvl_label: Label = %CurrentLvl
@onready var resonance_fill: ShaderMaterial = %ResonanceFill.material
@onready var progress_shader: ShaderMaterial = %ProgressShader.material


func set_current_lvl(p_current_lvl: int):
	if !progress_shader:
		return

	var new_progress = float(clamp(p_current_lvl, min_lvl, max_lvl)) / float(max_lvl - min_lvl)

	# Текущее значение
	var current_progress = progress_shader.get_shader_parameter("progress")
	if is_nan(current_progress):
		current_progress = 0.0

	# Останавливаем твины
	if _tween_fill and _tween_fill.is_running():
		_tween_fill.kill()
	if _tween_border and _tween_border.is_running():
		_tween_border.kill()

	# Создаём твины
	_tween_fill = create_tween().set_ease(Tween.EASE_OUT)
	_tween_fill.tween_property(
		progress_shader,
		"shader_parameter/progress",
		new_progress,
		ANIMATION_DURATION
	)

	_tween_border = create_tween().set_ease(Tween.EASE_OUT)
	_tween_border.tween_property(
		resonance_fill,
		"shader_parameter/progress",
		new_progress,
		ANIMATION_DURATION
	)

	current_lvl = p_current_lvl
	current_lvl_label.text = str(current_lvl)
