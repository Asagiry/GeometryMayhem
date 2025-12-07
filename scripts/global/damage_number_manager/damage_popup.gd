class_name DamagePopup

extends Node2D

const COLOR_NORMAL_TOP := Color(1.0, 1.0, 1.0) # Чистый белый
const COLOR_NORMAL_BOT := Color(0.85, 0.85, 0.9) # Слегка голубовато-серый
const COLOR_CRIT_TOP := Color(1.0, 1.0, 0.4)
const COLOR_CRIT_BOT := Color(1.0, 0.5, 0.0)
const CRIT_SCALE := Vector2(1.5, 1.5)

@onready var label: Label = $Label

func setup(
	_position: Vector2,
	amount: float,
	category: Util.DamageCategory
) -> void:
	global_position = _position
	label.text = str(int(amount))

	# Сбрасываем масштаб на случай, если нода переиспользуется из пула
	scale = Vector2.ONE

	# Получаем доступ к материалу шейдера на лейбле
	var mat = label.material as ShaderMaterial
	if not mat:
		push_warning("DamagePopup: Label не имеет ShaderMaterial! Градиент не применится.")
		return

	match category:
		Util.DamageCategory.DEFAULT:
			# Устанавливаем параметры шейдера
			mat.set_shader_parameter("color_top", COLOR_NORMAL_TOP)
			mat.set_shader_parameter("color_bottom", COLOR_NORMAL_BOT)
			# Для обычного урона можно сделать текст чуть меньше
			scale = Vector2(0.9, 0.9)
		# Раскомментируй, когда добавишь CRITICAL в Util.DamageCategory
		#Util.DamageCategory.CRITICAL:
			#mat.set_shader_parameter("color_top", COLOR_CRIT_TOP)
			#mat.set_shader_parameter("color_bottom", COLOR_CRIT_BOT)
			#scale = CRIT_SCALE
			# Можно добавить дополнительный твин для "подпрыгивания" крита
		_:
			mat.set_shader_parameter("color_top", COLOR_NORMAL_TOP)
			mat.set_shader_parameter("color_bottom", COLOR_NORMAL_BOT)
	_animate()


func _animate() -> void:
	var random_x = randf_range(-30, 30)
	var end_position = position + Vector2(random_x, -60)
	var tween = create_tween()
	tween.set_parallel(true)
	# 1. ДВИЖЕНИЕ
	# Ставим время 1.5 секунды.
	# TRANS_ELASTIC или TRANS_BACK добавит "пружинистости" в начале (поп-ап),
	# но TRANS_CUBIC с EASE_OUT отлично подходит для эффекта "вылетел и завис".
	tween.tween_property(self, "position", end_position, 1.5) \
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# 2. ИСЧЕЗНОВЕНИЕ (Самое важное!)
	# set_delay(0.8) -> цифра будет висеть полностью видимой почти секунду (0.8с),
	# и только ПОТОМ начнет исчезать. Раньше было 0.3.
	# Сам процесс исчезновения (duration) тоже можно чуть растянуть (0.7).
	tween.tween_property(self, "modulate:a", 0.0, 0.7).set_ease(Tween.EASE_IN).set_delay(0.8)
	# 3. СКЕЙЛ (Уменьшение)
	# Синхронизируем с исчезновением, чтобы она не схлопывалась раньше времени.
	tween.tween_property(self, "scale", scale * 0.5, 0.7).set_delay(0.8)
	tween.chain().tween_callback(queue_free)
