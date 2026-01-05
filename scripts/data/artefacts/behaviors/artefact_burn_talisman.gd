extends ArtefactBehavior

var runtime_effects: Array[Effect] = []
#TODO Мне кажется стоит использовать вот это в runtime_script
func apply_to_player(player: PlayerController, _params: Dictionary) -> void:
	var effect = EffectBuilder.new() \
		.set_basic(
			Util.EffectType.BURN,
			Util.EffectBehavior.DOT,
			Util.EffectPositivity.NEGATIVE,
			_params.get(0).get("duration")
		) \
		.with_damage(
			_params.get(0).get("damage")
		) \
		.with_tick_interval(
			_params.get(0).get("tick_interval")
		) \
		.with_chance(
			_params.get(0).get("chance")
		) \
		.build()
	player.effects.append(effect)
	runtime_effects.append(effect)


func remove_from_player(player: PlayerController, _params: Dictionary) -> void:
	for e in runtime_effects:
		player.effects.erase(e)


func _effect_to_string():
	var data: String = ""
	for e in runtime_effects:
		data += "name: " + e.name + "; type: " + str(e.effect_type) + \
		"; duration:  " + str(e.duration)
		data += "\n"
	return data
