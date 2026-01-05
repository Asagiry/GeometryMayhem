class_name VFXEffectsComponent
extends Node

# --- ССЫЛКИ НА ШЕЙДЕРЫ ---
const BURN_SHADER = preload("res://scene/components/vfx_effect_component/burn.gdshader")
const SLOW_SHADER = preload("res://scene/components/vfx_effect_component/slow.gdshader")
const CURSE_SHADER = preload("res://scene/components/vfx_effect_component/curse.gdshader")
const REGEN_SHADER = preload("res://scene/components/vfx_effect_component/regeneration.gdshader")
const BLEED_SHADER = preload("res://scene/components/vfx_effect_component/bleed.gdshader")
const WOUNDED_SHADER = preload("res://scene/components/vfx_effect_component/wounded.gdshader")
const SILENCE_SHADER = preload("res://scene/components/vfx_effect_component/silence.gdshader")
const FREEZE_SHADER = preload("res://scene/components/vfx_effect_component/freeze.gdshader")
const RUPTURE_SHADER = preload("res://scene/components/vfx_effect_component/rupture.gdshader")
const SONIC_SHADER = preload("res://scene/components/vfx_effect_component/sonic.gdshader")
const PHASED_SHADER = preload("res://scene/components/vfx_effect_component/phased.gdshader")
const FORTIFY_SHADER = preload("res://scene/components/vfx_effect_component/fortify.gdshader")
const BKB_SHADER = preload("res://scene/components/vfx_effect_component/bkb.gdshader")
const DISPEL_SHADER = preload("res://scene/components/vfx_effect_component/dispel.gdshader")

@export var effect_receiver: EffectReceiver

var target_sprite: AnimatedSprite2D
var original_material: Material
var active_effects_materials: Dictionary = {}

# Приоритет эффектов
var effect_priority: Array[Util.EffectType] = [
	Util.EffectType.SONIC,
	Util.EffectType.PHASED,
	Util.EffectType.FORTIFY,
	Util.EffectType.SLOW,
	Util.EffectType.REGENERATION,
	Util.EffectType.BLEED,
	Util.EffectType.WOUNDED,
	Util.EffectType.RUPTURE,
	Util.EffectType.BURN,
	Util.EffectType.CURSE,
	Util.EffectType.SILENCE,
	Util.EffectType.FREEZE,
	Util.EffectType.DISPEL,
	Util.EffectType.BKB,
]

func _ready() -> void:
	await owner.ready
	if "animated_sprite_2d" in owner and owner.animated_sprite_2d:
		target_sprite = owner.animated_sprite_2d
	elif owner.has_node("AnimatedSprite2D"):
		target_sprite = owner.get_node("AnimatedSprite2D")
	if not target_sprite:
		push_error("VFXEffectsComponent: Не найден AnimatedSprite2D у %s" % owner.name)
		set_process(false)
		return

	original_material = target_sprite.material

	if not effect_receiver:
		effect_receiver = owner.find_child("EffectReceiver", true, false)
	if effect_receiver:
		effect_receiver.effect_started.connect(_on_effect_started)
		effect_receiver.effect_ended.connect(_on_effect_ended)
	else:
		push_warning("VFXEffectsComponent: EffectReceiver не найден!")


func _on_effect_started(effect_type: Util.EffectType, _duration: float) -> void:
	if effect_type == Util.EffectType.DISPEL:
		_play_dispel_animation()
		return
	var mat = _create_material_for_effect(effect_type)
	if mat:
		active_effects_materials[effect_type] = mat
		_update_current_visuals()



func _on_effect_ended(effect_type: Util.EffectType) -> void:
	if effect_type == Util.EffectType.DISPEL:
		return
	if active_effects_materials.has(effect_type):
		active_effects_materials.erase(effect_type)
		_update_current_visuals()


func _play_dispel_animation() -> void:
	var mat = _create_material_for_effect(Util.EffectType.DISPEL)
	if not mat: return
	active_effects_materials[Util.EffectType.DISPEL] = mat
	_update_current_visuals()
	var tween = create_tween()
	tween.tween_method(
		func(val): mat.set_shader_parameter("progress", val),
		0.0,
		1.0,
		1.0
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func():
		active_effects_materials.erase(Util.EffectType.DISPEL)
		_update_current_visuals()
	)


func _update_current_visuals() -> void:
	if active_effects_materials.is_empty():
		target_sprite.material = original_material
		return
	var best_effect = null
	for i in range(effect_priority.size() - 1, -1, -1):
		var type = effect_priority[i]
		if active_effects_materials.has(type):
			best_effect = type
			break
	if best_effect == null and not active_effects_materials.is_empty():
		best_effect = active_effects_materials.keys()[0]
	if best_effect != null:
		if target_sprite.material != active_effects_materials[best_effect]:
			target_sprite.material = active_effects_materials[best_effect]


func _create_material_for_effect(type: Util.EffectType) -> ShaderMaterial:
	var mat = ShaderMaterial.new()
	var is_valid_effect = true # Флаг для проверки, нашли ли мы эффект

	match type:
		Util.EffectType.BURN:
			mat.shader = BURN_SHADER
			mat.set_shader_parameter("burn_color", Color(1.0, 0.35, 0.0))
			mat.set_shader_parameter("intensity", 0.6)
			mat.set_shader_parameter("speed", 4.0)

		Util.EffectType.SLOW:
			mat.shader = SLOW_SHADER
			mat.set_shader_parameter("slow_color", Color(0.3, 0.6, 0.7, 1.0))
			mat.set_shader_parameter("intensity", 0.7)

		Util.EffectType.CURSE:
			mat.shader = CURSE_SHADER
			mat.set_shader_parameter("curse_color", Color(0.5, 0.0, 0.8, 1.0))
			mat.set_shader_parameter("intensity", 0.8)
			mat.set_shader_parameter("frequency", 3.0)

		Util.EffectType.REGENERATION:
			mat.shader = REGEN_SHADER
			mat.set_shader_parameter("regen_color", Color(0.2, 1.0, 0.4, 1.0))
			mat.set_shader_parameter("speed", -3.0)
			mat.set_shader_parameter("intensity", 0.5)
			mat.set_shader_parameter("frequency", 15.0)

		Util.EffectType.BLEED:
			mat.shader = BLEED_SHADER
			mat.set_shader_parameter("bleed_color", Color(0.9, 0.0, 0.1, 1.0))
			mat.set_shader_parameter("intensity", 0.7)
			mat.set_shader_parameter("speed", 2.0)

		Util.EffectType.WOUNDED:
			mat.shader = WOUNDED_SHADER
			mat.set_shader_parameter("wounded_color", Color(0.5, 0.1, 0.1, 1.0))
			mat.set_shader_parameter("intensity", 1.0)
			mat.set_shader_parameter("crack_scale", 4.0)
			mat.set_shader_parameter("crack_thickness", 0.4)
			mat.set_shader_parameter("darken_factor", 0.3)

		Util.EffectType.RUPTURE:
			mat.shader = RUPTURE_SHADER
			mat.set_shader_parameter("rupture_color", Color(1.0, 0.0, 0.0, 1.0))
			mat.set_shader_parameter("intensity", 0.8)
			mat.set_shader_parameter("speed", 10.0)
			mat.set_shader_parameter("shake_power", 0.02)

		Util.EffectType.SILENCE:
			mat.shader = SILENCE_SHADER
			mat.set_shader_parameter("intensity", 0.8)
			mat.set_shader_parameter("speed", 8.0)

		Util.EffectType.FREEZE:
			mat.shader = FREEZE_SHADER
			mat.set_shader_parameter("ice_color", Color(0.0, 0.5, 1.0, 0.8))
			mat.set_shader_parameter("speed", 1.5)
			mat.set_shader_parameter("scale", 20.0)
			mat.set_shader_parameter("start_time", Time.get_ticks_msec() / 1000.0)

		Util.EffectType.SONIC:
			mat.shader = SONIC_SHADER
			mat.set_shader_parameter("sonic_color", Color(0.0, 1.0, 1.0, 1.0))
			mat.set_shader_parameter("speed", 15.0)
			mat.set_shader_parameter("intensity", 0.6)

		Util.EffectType.PHASED:
			mat.shader = PHASED_SHADER
			mat.set_shader_parameter("phase_color", Color(0.7, 0.3, 1.0, 1.0))
			mat.set_shader_parameter("intensity", 0.5)
			mat.set_shader_parameter("speed", 3.0)

		Util.EffectType.FORTIFY:
			mat.shader = FORTIFY_SHADER
			mat.set_shader_parameter("fortify_color", Color(1.0, 0.8, 0.2, 1.0))
			mat.set_shader_parameter("shine_color", Color(1.0, 1.0, 1.0, 1.0))
			mat.set_shader_parameter("speed", 2.0)
			mat.set_shader_parameter("intensity", 0.5)

		Util.EffectType.BKB:
			mat.shader = BKB_SHADER
			mat.set_shader_parameter("bkb_color", Color(1.0, 0.7, 0.0, 1.0))
			mat.set_shader_parameter("energy_color", Color(0.8, 0.5, 0.0, 1.0))
			mat.set_shader_parameter("scale_factor", 1.15)
			mat.set_shader_parameter("spin_speed", 2.0)
		Util.EffectType.DISPEL:
			mat.shader = DISPEL_SHADER
			mat.set_shader_parameter("dispel_color", Color(0.0, 1.0, 0.0, 1.0))
			mat.set_shader_parameter("density", 0.8)
			mat.set_shader_parameter("progress", 0.0)
		_:
			is_valid_effect = false
	if is_valid_effect:
		return mat
	return null
