extends CanvasLayer

signal resolution_changed

@onready var tabs: TabContainer = %TabContainer
@onready var resolution_mode_selector: HBoxContainer = %ResolutionModeSelector
@onready var resolution_label: Label = %ResolutionLabel


func _ready() -> void:
	_enter_variables()
	_connect_signals()


func _enter_variables():
	tabs.set_tab_title(0, "Game")
	tabs.set_tab_title(1, "Video")
	tabs.set_tab_title(2, "Controls")
	tabs.set_tab_title(3, "Sound")


func _connect_signals():
	resolution_mode_selector.resolution_mode_changed.connect(_on_resolution_mode_changed)


func get_resolution_mode() -> int:
	var mode = DisplayServer.window_get_mode()
	return 1 if mode == DisplayServer.WINDOW_MODE_FULLSCREEN else 0


func _on_resolution_mode_changed() -> void:
	var mode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	emit_signal("resolution_changed")


func _on_exit_button_pressed() -> void:
	queue_free()
