extends MenuButton

var selected_behavior: Util.EffectBehavior

func _ready() -> void:
	for effect_behavior in Util.EffectBehavior:
		get_popup().add_item(effect_behavior)
	get_popup().id_pressed.connect(_on_exited)

func _on_exited(id :int):
	text = "EFFECT : "+ Util.get_effect_behavior_name(id)
	selected_behavior = id as Util.EffectBehavior

func get_behavior():
	return selected_behavior
