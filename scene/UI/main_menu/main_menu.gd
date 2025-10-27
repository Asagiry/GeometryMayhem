extends CanvasLayer

var settings_menu = preload("res://scene/UI/settings_menu/settings_menu.tscn")
var artefacts_menu = preload("res://scene/UI/artefacts_inventory/artefacts_inventory.tscn")
var talants_menu = preload("res://scene/UI/talents_menu/talents_menu.tscn")

func _on_play_button_pressed() -> void:
	Global.game_started.emit()
	get_tree().change_scene_to_file("res://scene/UI/loading_screen/loading_screen.tscn")


func _on_exit_button_pressed() -> void:
	Global.request_quit()


func _on_settings_button_pressed() -> void:
	var settings_menu_instance = settings_menu.instantiate()
	add_child(settings_menu_instance)


func _on_artefact_button_pressed() -> void:
	var artefacts_menu_instance = artefacts_menu.instantiate()
	add_child(artefacts_menu_instance)


func _on_talants_button_pressed() -> void:
	var talants_menu_instance = talants_menu.instantiate()
	add_child(talants_menu_instance)
