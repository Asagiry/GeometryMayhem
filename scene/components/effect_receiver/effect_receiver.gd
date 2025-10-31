class_name EffectReceiver

extends Node


signal effect_started(effect_type: Util.EffectType)
signal effect_ended(effect_type: Util.EffectType)

signal stun_applied(duration: float)

signal collision_disabled(status: bool)
signal attack_disabled(status: bool)

signal silenced(status: bool)

signal health_component_effects_changed(updated_stats: Dictionary)
signal armor_component_effects_changed(updated_stats: Dictionary)
signal movement_component_effects_changed(updated_stat: Dictionary)
signal attack_component_effects_changed(updated_stat: Dictionary)


const NUMBER_OF_BUFFS_AND_DEBUFFS: float = 6.0
const MAXIMUM_MULTIPLIER: float = 10.0

var active_dots: Array[Dictionary] = []
var active_stat_modifiers: Dictionary = {}

var stat_modifiers: StatModifierData = StatModifierData.new()

var active_special_states: Dictionary = {}

func _physics_process(delta: float) -> void:
	_process_dots(delta)
	_process_stat_modifiers(delta)


func apply_effect(effect: Effect):
	if is_under(Util.EffectType.BKB) \
	and effect.positivity == Util.EffectPositivity.NEGATIVE:
		return


	print("Наложен эффект: ", Util.EffectType.keys()[effect.effect_type] + \
	" ; длительность: ", effect.duration)

	match effect.behavior:
		Util.EffectBehavior.SPECIAL:
			_apply_special_effect(effect)
		Util.EffectBehavior.INSTANT:
			_apply_instant_effect(effect)
		Util.EffectBehavior.DOT:
			_add_dot_effect(effect)
		Util.EffectBehavior.BUFF, Util.EffectBehavior.DEBUFF:
			_add_stat_modifier(effect)

#region special
func _apply_special_effect(effect: Effect):
	if is_under(effect.effect_type):
		return

	active_special_states[effect.effect_type] = true
	emit_signal("effect_started", effect.effect_type)

	var path = "res://scripts/data/effect/behavior/"+\
	Util.get_effect_name(effect.effect_type).to_lower()+"_effect.gd"
	print(path)
	var instance = load(path).new()
	if instance == null:
		push_warning("⚠️ Special effect %s not found" % str(effect.effect_type))
		return

	add_child(instance)
	instance.apply(self, effect)

	if effect.stat_modifiers:
		_add_stat_modifier(effect)
#endregion special


#region instant
func _apply_instant_effect(effect: Effect):
	emit_signal("effect_started", effect.effect_type)

	if effect.effect_type == Util.EffectType.DISPEL:
		clear_effects(Util.EffectPositivity.NEGATIVE)
		set_leave_stun_state()

	if effect.damage:
		owner.health_component.take_damage(effect.damage)

	if effect.stat_modifiers:
		_add_stat_modifier(effect)

	emit_signal("effect_ended", effect.effect_type)
#endregion instant


#region dot
func _add_dot_effect(effect: Effect):
	if effect.effect_type == Util.EffectType.BLEED:
		effect.damage.amount = owner.stats.attack_damage.amount \
		* effect.percent_of_attack

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
		if dot["timer"]>= e.tick_interval:
			dot["timer"] = 0.0
			if e.damage:
				if e.positivity == Util.EffectPositivity.POSITIVE:
					owner.health_component.take_heal(e.damage.amount)
				else:
					owner.health_component.take_damage(e.damage)

		# Если время эффекта истекло — удаляем
		if dot["elapsed"] >= e.duration:
			active_dots.remove_at(i)
			emit_signal("effect_ended", e.effect_type)


func _should_replace_dot(old_dot: Effect, new_dot: Effect) -> bool:
	var old_total = old_dot.damage.amount * (old_dot.duration / old_dot.tick_interval)
	var new_total = new_dot.damage.amount * (new_dot.duration / new_dot.tick_interval)
	return new_total > old_total
#endregion dot


#region stat_modifiers
func _add_stat_modifier(effect: Effect):
	if effect.stat_modifiers == null:
		return

	var new_type := effect.effect_type
	var new_mod := effect.stat_modifiers
	var new_duration := effect.duration

	if not active_stat_modifiers.has(new_type):
		active_stat_modifiers[new_type] = {
			"modifier": new_mod,
			"remaining_time": new_duration,
			"positivity": effect.positivity
		}
		_recalculate_stats()
		emit_signal("effect_started", new_type)
		return

	var existing_data = active_stat_modifiers[new_type]
	var existing_mod: StatModifierData = existing_data["modifier"]

	if _should_replace_modifier(existing_mod, new_mod, effect.behavior):
		active_stat_modifiers[new_type] = {
			"modifier": new_mod,
			"remaining_time": new_duration,
			"positivity": effect.positivity
		}
		_recalculate_stats()
		emit_signal("effect_started", new_type)
	else:
		existing_data["remaining_time"] = new_duration


func _recalculate_stats():
	var old_stats := stat_modifiers.to_dict()

	stat_modifiers.reset()

	for effect_type in active_stat_modifiers.keys():
		var mod = active_stat_modifiers[effect_type]["modifier"]
		for stat in mod:
			var value = mod[stat]
			if typeof(value) == TYPE_BOOL:
				stat_modifiers[stat] = value
			elif typeof(value) == TYPE_FLOAT:
				stat_modifiers[stat] *= value

	var new_stats := stat_modifiers.to_dict()
	for stat in old_stats.keys():
		var old_val = old_stats[stat]
		var new_val = new_stats[stat]

		if typeof(old_val) == TYPE_BOOL:
			if old_val != new_val:
				if stat == "invulnerable":
					health_component_effects_changed.emit({ "invulnerable": new_val })
		elif typeof(old_val) == TYPE_FLOAT:
			if not is_equal_approx(old_val, new_val):
				_signal_sender(stat, new_val)


func _signal_sender(stat: String, value: float):
	match stat:
		"speed_multiplier":
			movement_component_effects_changed.emit({
				"speed_multiplier": value
			})
		"attack_multiplier":
			attack_component_effects_changed.emit({
				"attack_multiplier": value
			})
		"armor_multiplier":
			armor_component_effects_changed.emit({
				"armor_multiplier": value
			})
		"forward_receiving_damage_multiplier":
			health_component_effects_changed.emit({
				"forward_receiving_damage_multiplier": value
			})
		"attack_cd_multiplier":
			attack_component_effects_changed.emit({
				"attack_cd_multiplier": value
			})
		"attack_duration_multiplier":
			attack_component_effects_changed.emit({
				"attack_duration_multiplier": value
			})
		"percent_of_max_health":
			print("percent_of_max_health = ", value)
			health_component_effects_changed.emit({
				"percent_of_max_health": value
			})


func _process_stat_modifiers(delta: float):
	var expired_effects: Array = []

	for effect_type in active_stat_modifiers.keys():
		active_stat_modifiers[effect_type]["remaining_time"] -= delta
		if active_stat_modifiers[effect_type]["remaining_time"] <= 0:
			expired_effects.append(effect_type)

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
#endregion stat_modifiers

func is_under(effect_type: Util.EffectType) -> bool:
	return active_special_states.get(effect_type, false)


func clear_effects(type: Util.EffectPositivity) -> void:
#-------------DOT_EFFECTS-------------------
	for i in range(active_dots.size() - 1, -1, -1):
		var dot_data = active_dots[i]
		var e: Effect = dot_data["effect"]
		if e.positivity == type:
			active_dots.remove_at(i)
			emit_signal("effect_ended", e.effect_type)

#--------------STAT_MODIFIERS-----------------------
	var expired_stat_modifiers := []
	for effect_type in active_stat_modifiers.keys():
		if active_stat_modifiers[effect_type].has("positivity"):
			var effect_positivity = active_stat_modifiers[effect_type]["positivity"]
			if  effect_positivity == type:
				expired_stat_modifiers.append(effect_type)

	for effect_type in expired_stat_modifiers:
		active_stat_modifiers.erase(effect_type)
		emit_signal("effect_ended", effect_type)


#--------SPECIAL_EFFECTS------------
	for child in get_children():
		if child is SpecialEffectBehavior \
		and child._effect.positivity == type:
			child.end()
			child.queue_free()

	_recalculate_stats()


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
		_recalculate_stats()

	if active_special_states.size() > 0:
		for effect_type in active_special_states.keys():
			emit_signal("effect_ended", effect_type)
		active_special_states.clear()

		for child in get_children():
			if child is SpecialEffectBehavior:
				child.end()
				child.queue_free()

	stat_modifiers.reset()


func set_freeze_multiplier(value: float):
	movement_component_effects_changed.emit({
		"freeze_multilier": value
	})


func set_attack_duration_multiplier(value: float) -> void:
	attack_component_effects_changed.emit({
		"attack_duration_multiplier": value
	})


func set_direction_modifier(value: float) -> void:
	movement_component_effects_changed.emit({
		"direction_modifier": value
	})


func set_leave_stun_state():
	owner.is_stunned = false


func set_stun_state(duration: float):
	if owner is PlayerController:
		stun_applied.emit(duration)
		owner.is_stunned = true
	else:
		pass
		#var stun_state = owner.enemy_state_machine.states["EnemyStunState"] as EnemyStunState
		#stun_state.set_duration(duration)
		#owner.is_stunned = true
