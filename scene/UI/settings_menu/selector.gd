class_name Selector

extends HBoxContainer

@export var options: Array[String] = []
@export var option_label: Label
@export var selected_index: int = 0
@export var left_button: TextureButton
@export var right_button: TextureButton
@export var dots: Array[TextureRect] = []
@export var selected_texture: Texture
@export var unselected_texture: Texture

func _ready() -> void:
	_update_display()
	left_button.connect("pressed", Callable(self, "_on_left_arrow_pressed"))
	right_button.connect("pressed", Callable(self, "_on_right_arrow_pressed"))

func _on_left_arrow_pressed():
	selected_index = (selected_index - 1 + options.size()) % options.size()
	_update_display()

func _on_right_arrow_pressed():
	selected_index = (selected_index + 1) % options.size()
	_update_display()

func _update_display():
	option_label.text = options[selected_index]
	left_button.disabled = selected_index == 0
	right_button.disabled = selected_index == options.size() - 1
	for i in dots.size():
		if i == selected_index:
			dots[i].texture = selected_texture
		else:
			dots[i].texture = unselected_texture
