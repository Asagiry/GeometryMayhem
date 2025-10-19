class_name TalentSlot

extends VBoxContainer

signal talent_selected()

@export var arrow_visible = true

@onready var texture_button: TextureButton = %TextureButton
@onready var added_points: Label = %AddedPoints
@onready var arrow_down: TextureRect = %ArrowDown



func _ready():
	arrow_down.visible = arrow_visible


func _on_texture_button_pressed() -> void:
	talent_selected.emit()
