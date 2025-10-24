class_name EffectReceiver

extends Node

signal effect_started(effect_type: Util.EffectType)
signal effect_ended(effect_type: Util.EffectType)

const NUMBER_OF_BUFFS_AND_DEBUFFS: float = 6.0

var active_dots: Array[Dictionary] = []
var active_stat_modifiers: Dictionary = {}

var speed_multiplier: float = 1.0
var physical_attack_multiplier: float = 1.0
var magical_attack_multiplier: float = 1.0
var armor_multiplier: float = 1.0
var magical_resistance_multiplier: float = 1.0
var forward_receiving_damage_multiplier: float = 1.0

var active_states: Dictionary = {}     # { EffectType: true }
var state_timers: Dictionary = {}      # { EffectType: float }

@onready var health_component: HealthComponent = %HealthComponent

func _process(delta: float) -> void:
	_process_dots(delta)
	_process_stat_modifiers(delta)
	_process_state_timers(delta)


func apply_effect(effect: Effect):
	print(effect.name)
	emit_signal("effect_started", effect.effect_type)

	match effect.behavior:
		Util.EffectBehavior.INSTANT:
			_apply_instant_effect(effect)
		Util.EffectBehavior.DOT:
			_add_dot_effect(effect)
		Util.EffectBehavior.BUFF, Util.EffectBehavior.DEBUFF:
			_add_stat_modifier(effect)


func _apply_instant_effect(effect: Effect):
	emit_signal("effect_started", effect.effect_type)

	if effect.damage:
		health_component.take_damage(effect.damage)

	#if effect.effect_type in [Util.EffectType.STUN, Util.EffectType.ROOT, Util.EffectType.FEAR]:
		#_apply_state(effect.effect_type, effect.duration)

	if effect.stat_modifiers:
		_add_stat_modifier(effect)

	emit_signal("effect_ended", effect.effect_type)

func _apply_state(effect_type: Util.EffectType, duration: float):
	active_states[effect_type] = true
	state_timers[effect_type] = duration


func _process_state_timers(delta: float):
	for effect_type in state_timers.keys():
		state_timers[effect_type] -= delta
		if state_timers[effect_type] <= 0:
			active_states[effect_type] = false
			state_timers.erase(effect_type)
			emit_signal("effect_ended", effect_type)


func is_under(effect_type: Util.EffectType) -> bool:
	return active_states.get(effect_type, false)


func _add_dot_effect(effect: Effect):
	for dot_data in active_dots:
		var existing_effect: Effect = dot_data["effect"]
		if existing_effect.effect_type == effect.effect_type:
			if _should_replace_dot(existing_effect, effect):
				dot_data["elapsed"] = 0.0
				dot_data["effect"] = effect
				emit_signal("effect_started", effect.effect_type)
			else:
				dot_data["elapsed"] = 0.0
			return

	active_dots.append({
		"effect": effect,
		"timer": 0.0,
		"elapsed": 0.0
	})
	emit_signal("effect_started", effect.effect_type)


func _process_dots(delta: float):
	for i in range(active_dots.size() - 1, -1, -1):
		var dot = active_dots[i]
		var e: Effect = dot["effect"]

		dot["elapsed"] += delta
		dot["timer"] += delta

		# Пора тикать урон
		if dot["timer"] >= e.tick_interval:
			dot["timer"] = 0.0
			if e.damage:
				health_component.take_damage(e.damage)

		# Если время эффекта истекло — удаляем
		if dot["elapsed"] >= e.duration:
			active_dots.remove_at(i)
			emit_signal("effect_ended", e.effect_type)


func _should_replace_dot(old_dot: Effect, new_dot: Effect) -> bool:
	var old_total = old_dot.damage.amount * (old_dot.duration / old_dot.tick_interval)
	var new_total = new_dot.damage.amount * (new_dot.duration / new_dot.tick_interval)
	return new_total > old_total


func _add_stat_modifier(effect: Effect):
	if effect.stat_modifiers == null:
		return

	var new_type := effect.effect_type
	var new_mod := effect.stat_modifiers
	var new_duration := effect.duration

	if not active_stat_modifiers.has(new_type):
		active_stat_modifiers[new_type] = {
			"modifier": new_mod,
			"remaining_time": new_duration
		}
		_recalculate_stats()
		emit_signal("effect_started", new_type)
		return

	var existing_data = active_stat_modifiers[new_type]
	var existing_mod: StatModifierData = existing_data["modifier"]

	if _should_replace_modifier(existing_mod, new_mod, effect.behavior):
		active_stat_modifiers[new_type] = {
			"modifier": new_mod,
			"remaining_time": new_duration
		}
		_recalculate_stats()
		emit_signal("effect_started", new_type)
	else:
		# Просто обновляем таймер, если эффект слабее или равен
		existing_data["remaining_time"] = new_duration


func _remove_stat(data: StatModifierData):
	if active_stat_modifiers.has(data):
		active_stat_modifiers.erase(data)
	_recalculate_stats()


func _recalculate_stats():
	speed_multiplier = 1.0
	physical_attack_multiplier = 1.0
	magical_attack_multiplier = 1.0
	armor_multiplier = 1.0
	magical_resistance_multiplier = 1.0
	forward_receiving_damage_multiplier = 1.0

	for effect_type in active_stat_modifiers.keys():
		var mod = active_stat_modifiers[effect_type]["modifier"]
		speed_multiplier *= mod.speed_multiplier
		physical_attack_multiplier *= mod.physical_attack_multiplier
		magical_attack_multiplier *= mod.magical_attack_multiplier
		armor_multiplier *= mod.armor_multiplier
		magical_resistance_multiplier *= mod.magical_resistance_multiplier
		forward_receiving_damage_multiplier *= mod.forward_receiving_damage_multiplier


func _process_stat_modifiers(delta: float):
	var expired_effects: Array = []

	for effect_type in active_stat_modifiers.keys():
		active_stat_modifiers[effect_type]["remaining_time"] -= delta
		if active_stat_modifiers[effect_type]["remaining_time"] <= 0:
			expired_effects.append(effect_type)

	# Если какие-то эффекты закончились, пересчитываем один раз
	if expired_effects.size() > 0:
		for effect_type in expired_effects:
			active_stat_modifiers.erase(effect_type)
			emit_signal("effect_ended", effect_type)
		_recalculate_stats()


func _should_replace_modifier(
	old_mod: StatModifierData,
	new_mod: StatModifierData,
	behavior: Util.EffectBehavior
	) -> bool:
	match behavior:
		Util.EffectBehavior.DEBUFF:
			# Для дебаффов – чем меньше множитель, тем сильнее эффект
			return _is_new_debuff_stronger(old_mod, new_mod)
		Util.EffectBehavior.BUFF:
			# Для баффов – чем больше множитель, тем сильнее эффект
			return _is_new_buff_stronger(old_mod, new_mod)
		_:
			# Для прочих эффектов можно всегда обновлять
			return true


func _is_new_debuff_stronger(old_mod: StatModifierData, new_mod: StatModifierData) -> bool:
	var old_total := (
		old_mod.speed_multiplier +
		old_mod.physical_attack_multiplier +
		old_mod.magical_attack_multiplier +
		old_mod.armor_multiplier +
		old_mod.magical_resistance_multiplier +
		old_mod.forward_receiving_damage_multiplier
	) / NUMBER_OF_BUFFS_AND_DEBUFFS

	var new_total := (
		new_mod.speed_multiplier +
		new_mod.physical_attack_multiplier +
		new_mod.magical_attack_multiplier +
		new_mod.armor_multiplier +
		new_mod.magical_resistance_multiplier +
		new_mod.forward_receiving_damage_multiplier
	) / NUMBER_OF_BUFFS_AND_DEBUFFS

	# Чем меньше средний множитель — тем сильнее дебафф
	return new_total < old_total


func _is_new_buff_stronger(old_mod: StatModifierData, new_mod: StatModifierData) -> bool:
	var old_total := (
		old_mod.speed_multiplier +
		old_mod.physical_attack_multiplier +
		old_mod.magical_attack_multiplier +
		old_mod.armor_multiplier +
		old_mod.magical_resistance_multiplier +
		old_mod.forward_receiving_damage_multiplier
	) / NUMBER_OF_BUFFS_AND_DEBUFFS

	var new_total := (
		new_mod.speed_multiplier +
		new_mod.physical_attack_multiplier +
		new_mod.magical_attack_multiplier +
		new_mod.armor_multiplier +
		new_mod.magical_resistance_multiplier +
		new_mod.forward_receiving_damage_multiplier
	) / NUMBER_OF_BUFFS_AND_DEBUFFS

	# Чем больше средний множитель — тем сильнее бафф
	return new_total > old_total
