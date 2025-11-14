extends MenuButton

var selected_effect_type : Util.EffectType

func _ready() -> void:
	for effect_type in Util.EffectType:
		get_popup().add_item(effect_type)
	get_popup().id_pressed.connect(_on_exited)


func update_effect_type(effect_type: Util.EffectType):
	selected_effect_type = effect_type
	text = "EFFECT : "+ Util.get_effect_name(effect_type)


func _on_exited(id :int):
	text = "EFFECT : "+ Util.get_effect_name(id)
	selected_effect_type = id as Util.EffectType

func get_effect_type():
	return selected_effect_type
