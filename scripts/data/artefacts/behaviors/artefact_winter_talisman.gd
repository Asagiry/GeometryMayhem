extends ArtefactBehavior

var runtime_effects: Array[Effect] = []

func apply_to_player(player: PlayerController, params: Dictionary) -> void:
	var effect = EffectFactory.create_slow(params)
	player.effects.append(effect)
	runtime_effects.append(effect)

func remove_from_player(player: PlayerController, _params: Dictionary) -> void:
	for e in runtime_effects:
		player.effects.erase(e)
