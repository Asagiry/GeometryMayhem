extends SpecialEffectBehavior

#прелоад vignette
var vignette = preload("res://scene/UI/vignette/vignette.tscn")
var vignette_instance: CanvasLayer

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	vignette_instance = vignette.instantiate()
	get_tree().get_first_node_in_group("level").add_child(vignette_instance)
	print("Blind applied for ", effect.duration, " seconds")

func end() -> void:
	vignette_instance.queue_free()
	_receiver.active_special_states[_effect.effect_type] = false
	print("Blind ended")
	super.end()
