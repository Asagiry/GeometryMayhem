extends Node

@export var transition_end_screen: PackedScene

var pause_menu_scene = preload("res://scene/UI/pause_menu/pause_menu.tscn")

@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	Global.player_died.connect(_on_player_died)

func _input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())


func _on_player_died():
	var screen = transition_end_screen.instantiate()
	add_child(screen)
	get_tree().change_scene_to_packed(transition_end_screen)
	#var screen = transition_end_screen.instantiate()
	#add_child(screen)
	#var position_screen = camera_2d.get_screen_center_position()
	#position_screen.x -= 720 / 2.0
	#position_screen.y -= 1280 / 2.0
	#print(camera_2d.get_screen_center_position())
	#screen.global_position = position_screen
