extends CanvasLayer

var settings_menu = preload("res://scene/UI/settings_menu/settings_menu.tscn")
var artefacts_menu = preload("res://scene/UI/artefacts_inventory/artefacts_inventory.tscn")
var talants_menu = preload("res://scene/UI/talents_menu/talents_menu.tscn")
var statistics = preload("res://scene/UI/statistics/statistics.tscn")
var achievements_menu = preload("res://scene/UI/achievements_menu/achievements_menu.tscn")

@onready var play_btn: Control = %PlayButton 


func _ready():
	var rt = get_tree().root.theme
	print("Root theme path:", rt.resource_path if rt else "NULL")

	print("play_btn class:", play_btn.get_class())
	print("play_btn.theme path:", play_btn.theme.resource_path if play_btn.theme else "NULL")
	print("override normal stylebox?:", play_btn.has_theme_stylebox_override("normal"))
	print("theme variation:", play_btn.theme_type_variation)


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


func _on_statistic_button_pressed() -> void:
	var statistics_instance = statistics.instantiate()
	add_child(statistics_instance)


func _on_achievements_button_pressed() -> void:
	var achievements_instance = achievements_menu.instantiate()
	add_child(achievements_instance)
