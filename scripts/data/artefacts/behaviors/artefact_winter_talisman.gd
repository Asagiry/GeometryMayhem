extends ArtefactBehavior

var runtime_effects: Array[Effect] = []

func apply_to_player(_player: PlayerController, _params: Dictionary) -> void:
	var effect = EffectBuilder.new() \
			.set_basic(
				Util.EffectType.SLOW,
				Util.EffectBehavior.DEBUFF,
				Util.EffectPositivity.NEGATIVE,
				_params.get(0).get("duration")
			) \
			.with_stat_modifiers(
				StatModifierBuilder.new()
				.speed_multiplier(
					_params.get(0).get("speed_multiplier")
				)
				.build()
			) \
			.with_chance(
				_params.get(0).get("chance")
			) \
			.build()
	print(_params)
	print(_params.get(0).get("chance"))
	_player.effects.append(effect)
	runtime_effects.append(effect)

func remove_from_player(_player: PlayerController, _params: Dictionary) -> void:
	for e in runtime_effects:
		_player.effects.erase(e)


func _effect_to_string():
	var data: String = ""
	for e in runtime_effects:
		data += "name: " + e.name + "; type: " + str(e.effect_type) + \
		"; duration:  " + str(e.duration)
		data += "\n"
	return data
