class_name CooldownBar
extends TextureRect

var player: PlayerController
var attack_tween: Tween
var parry_tween: Tween

@onready var shader_material: ShaderMaterial = material

func setup(p_player: PlayerController):
	player = p_player
	set_parry_progress(0.85)
	set_attack_progress(0.85)

func trigger_attack_cooldown():
	if attack_tween:
		attack_tween.kill()

	# Начинаем с пустого (progress = 0) и заполняем до полного (progress = 1)
	set_attack_progress(0.0)
	attack_tween = create_tween()
	attack_tween.tween_method(set_attack_progress, 0.0, 0.85,
	 player.stats.attack_cd+player.stats.attack_duration)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

func trigger_parry_cooldown():
	if parry_tween:
		parry_tween.kill()

	set_parry_progress(0.0)
	parry_tween = create_tween()
	parry_tween.tween_method(set_parry_progress, 0.0, 0.85,
	 player.stats.parry_cd+player.stats.parry_duration)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

func set_attack_progress(progress: float):
	shader_material.set_shader_parameter("attack_progress", progress)

func set_parry_progress(progress: float):
	shader_material.set_shader_parameter("parry_progress", progress)

# Сброс к пустому состоянию
func reset_attack_cooldown():
	if attack_tween:
		attack_tween.kill()
	set_attack_progress(0.0)

func reset_parry_cooldown():
	if parry_tween:
		parry_tween.kill()
	set_parry_progress(0.0)
