extends CanvasLayer

@onready var tabs: TabContainer = %TabContainer
@onready var resolution_mode_selector: HBoxContainer = %ResolutionModeSelector


func _ready() -> void:
	_enter_variables()
	_connect_signals()
	
func _enter_variables():
	tabs.set_tab_title(0, "Игра")
	tabs.set_tab_title(1, "Видео")
	tabs.set_tab_title(2, "Управление")
	tabs.set_tab_title(3, "Звук")
	
func _connect_signals():
	resolution_mode_selector.resolution_mode_changed.connect(_on_resolution_mode_changed)

func _on_resolution_mode_changed() -> void:
	var mode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_exit_button_pressed() -> void:
	queue_free()
