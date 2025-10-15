class_name EffectReceiver

extends Node

signal effect_started(effect_type: Util.EffectType)
signal effect_ended(effect_type: Util.EffectType)

var active_dots: Array[Dictionary] = []
var active_stat_modifiers: Dictionary = {}

var speed_multiplier := 1.0
var attack_multiplier := 1.0
var defense_multiplier := 1.0

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
	if effect.damage:
		health_component.take_damage(effect.damage)

	if effect.effect_type in [Util.EffectType.STUN, Util.EffectType.ROOT, Util.EffectType.FEAR]:
		_apply_state(effect.effect_type, effect.duration)

	if effect.stat_modifiers:
		_add_stat_modifier(effect)


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
	for dot in active_dots:
		var existing_effect: Effect = dot["effect"]
		if existing_effect.effect_type == effect.effect_type:
			dot["elapsed"] = 0.0
			dot["timer"] = 0.0
			dot["effect"] = effect
			return

	active_dots.append({
		"effect": effect,
		"timer": 0.0,
		"elapsed": 0.0
	})


func _process_dots(delta: float):
	for i in active_dots.size():
		var dot = active_dots[i]
		var e: Effect = dot.effect
		dot["elapsed"] += delta
		dot["timer"] += delta

		if dot["timer"] >= e.tick_interval:
			dot["timer"] = 0.0
			if e.damage:
				health_component.take_damage(e.damage)

		if dot["elapsed"] >= e.duration:
			emit_signal("effect_ended", e.effect_type)
			active_dots.remove_at(i)
			return


func _add_stat_modifier(effect: Effect):
	if effect.stat_modifiers == null:
		return

	active_stat_modifiers[effect.effect_type] = {
		"modifier": effect.stat_modifiers,
		"remaining_time": effect.duration
	}

	_recalculate_stats()


func _remove_stat(data: StatModifierData):
	if active_stat_modifiers.has(data):
		active_stat_modifiers.erase(data)
	_recalculate_stats()


func _recalculate_stats():
	speed_multiplier = 1.0
	attack_multiplier = 1.0
	defense_multiplier = 1.0

	for effect_type in active_stat_modifiers.keys():
		var mod = active_stat_modifiers[effect_type]["modifier"]
		speed_multiplier *= mod.speed_multiplier
		attack_multiplier *= mod.attack_multiplier
		defense_multiplier *= mod.defense_multiplier


func _process_stat_modifiers(delta: float):
	var to_remove: Array = []
	for effect_type in active_stat_modifiers.keys():
		active_stat_modifiers[effect_type].remaining_time -= delta
		if active_stat_modifiers[effect_type].remaining_time <= 0:
			to_remove.append(effect_type)

	for effect_type in to_remove:
		active_stat_modifiers.erase(effect_type)
		_recalculate_stats()
		emit_signal("effect_ended", effect_type)
