extends CanvasLayer

var settings_menu = preload("res://scene/UI/settings_menu/settings_menu.tscn")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/UI/loading_screen/loading_screen.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	var settings_menu_instance = settings_menu.instantiate()
	add_child(settings_menu_instance)
