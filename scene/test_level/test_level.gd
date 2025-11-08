extends Node

const PAUSE_MENU_SCENE = preload("res://scene/UI/pause_menu/pause_menu.tscn")

@onready var camera_2d: Camera2D = %Camera2D
@onready var test_ui: CanvasLayer = $Test_ui
@onready var arena_time_ui: CanvasLayer = $ArenaTimeUI
@onready var enemy_spawner: EnemySpawnerController = $EnemySpawnerController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player_died.connect(_on_player_died)
	arena_time_ui.game_timer.timeout.connect(_on_game_timer_timeout)


func _input(event):
	if event.is_action_pressed("pause"):
		add_child(PAUSE_MENU_SCENE.instantiate())


func _on_player_died():
	await get_tree().process_frame

	var back_layer = get_tree().get_first_node_in_group("back_layer")
	if back_layer and is_instance_valid(back_layer):
		var player = preload("res://scene/game_objects/player/player.tscn").instantiate()
		back_layer.add_child(player)

		await get_tree().process_frame
		camera_2d.set_target(player)
		test_ui._connect_health_signal()
		test_ui.current_health_label.text = test_ui.max_health_label.text
		print("Player respawned successfully")


func _on_game_timer_timeout():
	enemy_spawner.disable_spawning()
	Global.game_timer_timeout.emit()
