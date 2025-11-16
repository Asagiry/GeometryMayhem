class_name Effect
extends Resource

### Кэш предзагруженных скриптов по умолчанию
static var _default_scripts_cache: Dictionary = {}

### Тип эффекта (Slow, Burn, Freeze и т.д.)
var effect_type: Util.EffectType = Util.EffectType.NONE

### Поведение эффекта (DOT, BUFF, DEBUFF, SPECIAL, INSTANT)
var behavior: Util.EffectBehavior = Util.EffectBehavior.NONE

### Позитивность эффекта (POSITIVE, NEGATIVE, NONE)
var positivity: Util.EffectPositivity = Util.EffectPositivity.NONE

### Длительность эффекта в секундах. 0.0 - мгновенный эффект
var duration: float = 0.0

### Данные об уроне, который наносит эффект
var damage: DamageData

### Модификаторы характеристик, которые применяет эффект
var stat_modifiers: StatModifierData

### Интервал между тиками для DOT-эффектов в секундах
var tick_interval: float = 1.0

### Используется для bleed, wounded. В первом случае считает процент урона
### от атаки, во втором случае считает процент урона от max_hp сущности.
var percent: float

### Скрипт поведения для SPECIAL эффектов
var behavior_script: Script

### Шанс применения эффекта (0.0 - 1.0). 1.0 - всегда применяется
var chance_to_apply: float = 1.0

### Создает и возвращает инстанс behavior скрипта для этого эффекта
func create_behavior_instance() -> Object:
	if behavior_script:
		return behavior_script.new()

	if behavior == Util.EffectBehavior.SPECIAL:
		var script = _get_default_behavior_script()
		if script:
			return script.new()

	return null


### Получает скрипт по умолчанию для типа эффекта (с кэшированием)
func _get_default_behavior_script() -> Script:
	var effect_name = Util.get_effect_name(effect_type).to_lower()

	if not _default_scripts_cache.has(effect_name):
		var path = "res://scripts/data/effect/behavior/" + effect_name + "_effect.gd"
		if ResourceLoader.exists(path):
			_default_scripts_cache[effect_name] = load(path)
		else:
			_default_scripts_cache[effect_name] = null
			push_warning("Default behavior script not found: " + path)

	return _default_scripts_cache[effect_name]

### Установить damage_data у эффекта
func set_damage_data(damage_data: DamageData) -> void:
	damage = damage_data
