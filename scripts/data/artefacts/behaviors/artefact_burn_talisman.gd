extends ArtefactBehavior

var effect: Effect

func apply_to_player(player: PlayerController, params: Dictionary) -> void:
	effect = EffectFactory.create_burn(params)
	player.effects.append(effect)

func remove_from_player(player: PlayerController, _params: Dictionary) -> void:
	player.effects.erase(effect)
