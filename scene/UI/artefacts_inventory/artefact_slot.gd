extends Control
class_name ArtefactSlot

signal artefact_selected(artefact_name,description,stats,image)

var artefact_name = "Artefact: 1"
var description = "Artefact: 1 description"
var stats = "25%"
@onready var texture_button: TextureButton = %TextureButton

func _on_texture_button_pressed() -> void:
	artefact_selected.emit(artefact_name,description,stats,
	texture_button.texture_normal)
