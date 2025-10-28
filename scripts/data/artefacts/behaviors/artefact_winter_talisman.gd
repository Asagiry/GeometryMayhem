extends ArtefactBehavior

var runtime_effects: Array[Effect] = []

func apply_to_player(player: PlayerController, params: Dictionary) -> void:
	runtime_effects = EffectFactory.create_effect(params)
	for e in runtime_effects:
		player.effects.append(e)

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
