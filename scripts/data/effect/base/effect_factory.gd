class_name EffectFactory

extends Node
static func _create_from_data(effect_data: Dictionary) -> Effect:
	if typeof(effect_data) != TYPE_DICTIONARY:
		push_error("EffectFactory.create_effect: effect_data must be a Dictionary")
		return null
	var effect_name_str = ""
	if effect_data.has("effect_name"):
		effect_name_str = String(effect_data.get("effect_name", "")).to_upper()
	else:
		push_error("EffectFactory.create_effect: effect_data missing 'effect_name'.")
		return null

	var e: Effect = Effect.new()
	match effect_name_str:
		"BURN", "POISON", "BLEED", "CORROSION":
			return _create_dot_effect(e, effect_data)
		"SLOW", "CURSE", "ARMOR_DEBUFF", "DAMAGE_REDUCTION":
			return _create_debuff_effect(e, effect_data)
		_:
			return _create_special_effect(e, effect_data)

static func create_effect(params := {}) -> Array[Effect]:
	# Создаёт массив Effect по переданным параметрам.
	# Поддерживаемые формы params:
	# 1) один словарь с ключом "effect_name": {"effect_name":"BURN", "duration":2.0, ...}
	# 2) массив словарей: [{...}, {...}]
	# 3) словарь, где значения — словари эффектов: {"0": {...}, "1": {...}}
	var result: Array[Effect] = []
	# Если передали массив — обрабатываем каждый элемент
	if typeof(params) == TYPE_ARRAY:
		for effect_data in params:
			var created = _create_from_data(effect_data)
			if created != null:
				result.append(created)
		return result

	# Если передан одиночный словарь с ключом effect_name — создаём один эффект
	if typeof(params) == TYPE_DICTIONARY and params.has("effect_name"):
		var single = _create_from_data(params)
		if single != null:
			result.append(single)
		return result

	# Если передан словарь, содержащий несколько эффектов (map) — перебираем значения
	if typeof(params) == TYPE_DICTIONARY:
		for k in params.keys():
			var effect_data = params[k]
			var created = _create_from_data(effect_data)
			if created != null:
				result.append(created)
		return result

	# Неопознанный тип параметров
	push_error("EffectFactory.create_effect: unsupported params type: %s" % typeof(params))
	return result


static func _create_dot_effect(e: Effect, effect_data: Dictionary) -> Effect:
	e.effect_type = Util.EffectType.get(effect_data.get("effect_name", ""))
	e.behavior = Util.EffectBehavior.DOT
	# defaults
	e.damage = DamageData.new()
	e.damage.amount = float(effect_data.get("damage", 1.0))
	e.damage.damage_category = Util.DamageCategory.DEFAULT
	e.duration = float(effect_data.get("duration", 2.0))
	e.tick_interval = float(effect_data.get("tick_interval", 1.0))
	# дополнительные поля (опционально)
	# применяем любые переданные переопределения (stat_modifiers, damage и т.д.)
	_apply_overrides(e, effect_data)
	return e


static func _create_debuff_effect(e: Effect, effect_data: Dictionary) -> Effect:
	e.effect_type = Util.EffectType.get(effect_data.get("effect_name", ""))
	e.behavior = Util.EffectBehavior.DEBUFF
	# defaults
	e.stat_modifiers = StatModifierData.new()
	e.stat_modifiers.speed_multiplier = float(effect_data.get("speed_multiplier", 1.0))
	e.stat_modifiers.attack_multiplier = float(effect_data.get("attack_multiplier", 1.0))
	e.stat_modifiers.armor_multiplier = float(effect_data.get("armor_multiplier", 1.0))
	e.stat_modifiers.forward_receiving_damage_multiplier = \
	float(effect_data.get("forward_receiving_damage_multiplier", 1.0))
	e.duration = float(effect_data.get("duration", 1.0))
	# применяем любые переданные переопределения (stat_modifiers, damage и т.д.)
	_apply_overrides(e, effect_data)
	return e

static func _create_special_effect(e: Effect, effect_data: Dictionary) -> Effect:
	e.effect_type = Util.EffectType.get(effect_data.get("effect_name", ""))
	e.behavior = Util.EffectBehavior.SPECIAL
	# defaults
	e.duration = float(effect_data.get("duration", 2.0))
	# поведение для специальных эффектов — можно передать имя скрипта/класс поведения
	e.behavior_script = effect_data.get("behavior_script", e.behavior_script)
	# применяем любые переданные переопределения (stat_modifiers, damage и т.д.)
	_apply_overrides(e, effect_data)
	return e


static func _apply_overrides(e: Effect, effect_data: Dictionary) -> void:
	# Обрабатываем stat_modifiers (можно передать как словарь)
	if effect_data.has("stat_modifiers"):
		var sm = effect_data.get("stat_modifiers")
		if e.stat_modifiers == null:
			e.stat_modifiers = StatModifierData.new()
		if typeof(sm) == TYPE_DICTIONARY:
			# применяем значения по ключам, если свойство существует
			var prop_list = e.stat_modifiers.get_property_list()
			var props := {}
			for p in prop_list:
				props[p.name] = p
			for k in sm.keys():
				if props.has(k):
					var val = sm[k]
					if props[k].has("type") and props[k].type == TYPE_FLOAT:
						val = float(val)
					e.stat_modifiers.set(k, val)
				else:
					push_warning("EffectFactory: unknown stat_modifier %s" % k)

	# Обрабатываем damage — можно передать число или словарь
	if effect_data.has("damage"):
		var dmg = effect_data.get("damage")
		if e.damage == null:
			e.damage = DamageData.new()
		if typeof(dmg) == TYPE_DICTIONARY:
			var dprops = {}
			for p in e.damage.get_property_list():
				dprops[p.name] = p
			for k in dmg.keys():
				if dprops.has(k):
					var val = dmg[k]
					if dprops[k].has("type") and dprops[k].type == TYPE_FLOAT:
						val = float(val)
					e.damage.set(k, val)
				else:
					push_warning("EffectFactory: unknown damage field %s" % k)
		else:
			# если число — считаем это как amount
			if typeof(dmg) in [TYPE_INT, TYPE_FLOAT]:
				e.damage.amount = float(dmg)
			else:
				push_warning("EffectFactory: unsupported damage type: %s" % typeof(dmg))

	# Общие простые переопределения для полей Effect
	for k in effect_data.keys():
		if k in ["effect_name", "stat_modifiers", "damage"]:
			continue
		var val = effect_data[k]
		# Проверим, есть ли такое свойство у Effect
		var prop_list = e.get_property_list()
		var props := {}
		for p in prop_list:
			props[p.name] = p
		if props.has(k):
			if props[k].has("type") and props[k].type == TYPE_FLOAT:
				val = float(val)
			e.set(k, val)
