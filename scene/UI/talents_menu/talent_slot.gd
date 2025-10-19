class_name TalentSlot

extends VBoxContainer

signal talent_selected()

@onready var texture_button: TextureButton = %TextureButton
@onready var added_points: Label = %AddedPoints
@onready var arrow_down: TextureRect = %ArrowDown

@export var ArrowDownVisible = true

func _ready():
	arrow_down.visible = ArrowDownVisible


func _on_texture_button_pressed() -> void:
	talent_selected.emit()
