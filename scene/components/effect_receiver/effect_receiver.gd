class_name EffectReceiver

extends Node

signal effect_started(effect_type: Util.EffectType)
signal effect_ended(effect_type: Util.EffectType)
signal stats_changed(updated_stats: Dictionary)
signal input_disabled(status: bool)
signal attack_disabled(status: bool)
signal player_stats_changed(updated_stats: Dictionary)
signal invulnerability_changed(status: bool)

const NUMBER_OF_BUFFS_AND_DEBUFFS: float = 6.0
const MAXIMUM_MULTIPLIER: float = 10.0

var active_dots: Array[Dictionary] = []
var active_stat_modifiers: Dictionary = {}

var invulnerable: bool = false
var speed_multiplier: float = 1.0
var attack_multiplier: float = 1.0
var armor_multiplier: float = 1.0
var forward_receiving_damage_multiplier: float = 1.0
var attack_duration_multiplier: float = 1.0
var attack_cd_multiplier: float = 1.0

var parry_duration_multiplier: float = 1.0

var active_special_states: Dictionary = {}     # { EffectType: true }
var active_special_timers: Dictionary = {}      # { EffectType: float }

var player: PlayerController

@onready var health_component: HealthComponent = %HealthComponent

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as PlayerController


func _process(delta: float) -> void:
	_process_dots(delta)
	_process_stat_modifiers(delta)


func apply_effect(effect: Effect):
	print("EFFECT EFFECTTYPE: = " , Util.EffectType.keys()[effect.effect_type])
	match effect.behavior:
		Util.EffectBehavior.SPECIAL:
			_apply_special_effect(effect)
		Util.EffectBehavior.INSTANT:
			_apply_instant_effect(effect)
		Util.EffectBehavior.DOT:
			_add_dot_effect(effect)
		Util.EffectBehavior.BUFF, Util.EffectBehavior.DEBUFF:
			_add_stat_modifier(effect)


func _apply_special_effect(effect: Effect):
	if is_under(effect.effect_type):
		return
	active_special_states[effect.effect_type] = true
	emit_signal("effect_started", effect.effect_type)
	var instance = SpecialEffectRegistry.create(Util.EffectType.keys()[effect.effect_type])

	if instance == null:
		push_warning("⚠️ Special effect %s not found" % str(effect.effect_type))
		return

	add_child(instance)
	instance.apply(self, effect)


func _apply_instant_effect(effect: Effect):
	emit_signal("effect_started", effect.effect_type)

	if effect.damage:
		health_component.take_damage(effect.damage)


	if effect.stat_modifiers:
		_add_stat_modifier(effect)

	emit_signal("effect_ended", effect.effect_type)


func is_under(effect_type: Util.EffectType) -> bool:
	return active_special_states.get(effect_type, false)


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
	attack_multiplier = 1.0
	armor_multiplier = 1.0
	forward_receiving_damage_multiplier = 1.0

	for effect_type in active_stat_modifiers.keys():
		var mod = active_stat_modifiers[effect_type]["modifier"]
		speed_multiplier *= mod.speed_multiplier
		attack_multiplier *= mod.attack_multiplier
		armor_multiplier *= mod.armor_multiplier
		forward_receiving_damage_multiplier *= mod.forward_receiving_damage_multiplier

	emit_signal("stats_changed", {
		"speed_multiplier": speed_multiplier,
		"attack_multiplier": attack_multiplier,
		"armor_multiplier": armor_multiplier,
		"damage_multiplier": forward_receiving_damage_multiplier
	})


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
		old_mod.attack_multiplier +
		old_mod.armor_multiplier +
		old_mod.forward_receiving_damage_multiplier +
		(MAXIMUM_MULTIPLIER - old_mod.attack_duration_multiplier) +
		(MAXIMUM_MULTIPLIER - old_mod.attack_cd_multiplier)
	) / NUMBER_OF_BUFFS_AND_DEBUFFS

	var new_total := (
		new_mod.speed_multiplier +
		new_mod.attack_multiplier +
		new_mod.armor_multiplier +
		new_mod.forward_receiving_damage_multiplier +
		(MAXIMUM_MULTIPLIER - new_mod.attack_duration_multiplier) +
		(MAXIMUM_MULTIPLIER - new_mod.attack_cd_multiplier)
	) / NUMBER_OF_BUFFS_AND_DEBUFFS

	# Чем меньше средний множитель — тем сильнее дебафф
	return new_total < old_total


func _is_new_buff_stronger(old_mod: StatModifierData, new_mod: StatModifierData) -> bool:
	var old_total := (
		old_mod.speed_multiplier +
		old_mod.attack_multiplier +
		old_mod.armor_multiplier +
		old_mod.forward_receiving_damage_multiplier +
		(1.0 - old_mod.attack_duration_multiplier) +
		(1.0 - old_mod.attack_cd_multiplier)
	) / NUMBER_OF_BUFFS_AND_DEBUFFS

	var new_total := (
		new_mod.speed_multiplier +
		new_mod.attack_multiplier +
		new_mod.armor_multiplier +
		new_mod.forward_receiving_damage_multiplier +
		(1.0 - new_mod.attack_duration_multiplier) +
		(1.0 - new_mod.attack_cd_multiplier)
	) / NUMBER_OF_BUFFS_AND_DEBUFFS

	# Чем больше средний множитель — тем сильнее бафф
	return new_total > old_total


func set_speed_multiplier(value: float) -> void:
	speed_multiplier = value
	emit_signal("stats_changed", {
		"speed_multiplier": speed_multiplier
	})


func set_parry_duration_multiplier(value: float) -> void:
	parry_duration_multiplier = value
	emit_signal("player_stats_changed", {
		"parry_duration_multiplier": parry_duration_multiplier
	})


func set_attack_cd_multiplier(value: float) -> void:
	attack_cd_multiplier = value
	stats_changed.emit({
		"attack_cd_multiplier": attack_cd_multiplier
	})


func set_attack_duration_multiplier(value: float) -> void:
	attack_duration_multiplier = value
	stats_changed.emit({
		"attack_duration_multiplier": attack_duration_multiplier
	})


func set_invulnerability(value: bool) -> void:
	invulnerable = value
	invulnerability_changed.emit(invulnerable)


func clear_all_effects() -> void:
	if active_dots.size() > 0:
		for dot_data in active_dots:
			var e: Effect = dot_data["effect"]
			emit_signal("effect_ended", e.effect_type)
		active_dots.clear()

	if active_stat_modifiers.size() > 0:
		for effect_type in active_stat_modifiers.keys():
			emit_signal("effect_ended", effect_type)
		active_stat_modifiers.clear()

	if active_special_states.size() > 0:
		for effect_type in active_special_states.keys():
			emit_signal("effect_ended", effect_type)
		active_special_states.clear()
		active_special_timers.clear()

		for child in get_children():
			if child is SpecialEffectBehavior:
				child.queue_free()

	speed_multiplier = 1.0
	attack_multiplier = 1.0
	armor_multiplier = 1.0
	forward_receiving_damage_multiplier = 1.0
	attack_duration_multiplier = 1.0
	attack_cd_multiplier = 1.0
	parry_duration_multiplier = 1.0

	emit_signal("stats_changed", {
		"speed_multiplier": speed_multiplier,
		"attack_multiplier": attack_multiplier,
		"armor_multiplier": armor_multiplier,
		"damage_multiplier": forward_receiving_damage_multiplier,
		"attack_duration_multiplier": attack_duration_multiplier,
		"attack_cd_multiplier": attack_cd_multiplier,
		"parry_duration_multiplier": parry_duration_multiplier
	})

	print("All effects cleared and stats reset")
