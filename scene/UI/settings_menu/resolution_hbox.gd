extends HBoxContainer

@onready var resolution_label: Label = %ResolutionLabel
@onready var resolution_mode_selector: HBoxContainer = %ResolutionModeSelector

func _ready() -> void:
	owner.resolution_changed.connect(_on_resolution_changed)
	_get_and_update_resolution_size()


func _get_and_update_resolution_size():
	var window_size = DisplayServer.window_get_size()
	resolution_label.text = str(window_size.x) + "x" + str(window_size.y)


func _on_resolution_changed():
	_get_and_update_resolution_size()
