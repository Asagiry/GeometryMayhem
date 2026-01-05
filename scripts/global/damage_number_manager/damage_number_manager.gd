class_name DamageNumberManager

extends Node


var damage_popup_scene: PackedScene = \
preload("res://scripts/global/damage_number_manager/damage_popup.tscn")

func display_number(
	value: float,
	position: Vector2,
	category: Util.DamageCategory = Util.DamageCategory.DEFAULT
):
	if value <= 1: return
	var popup = damage_popup_scene.instantiate() as DamagePopup
	get_tree().current_scene.add_child(popup)
	popup.setup(position, value, category)
