class_name ArtefactsInventory

extends CanvasLayer

@onready var artefact_name: Label = %ArtefactName
@onready var artefact_description: Label = %ArtefactDescription
@onready var artefact_stats: Label = %ArtefactStats
@onready var artefact_texture: TextureRect = %ArtefactTexture

@onready var upgrade_button: Button = %UpgradeButton
@onready var cost_label: Label = %CostLabel
@onready var search_edit: LineEdit = %SearchEdit
@onready var artefact_slots: CircularContainer = %ArtefactSlots
@onready var equip_buttion: Button = %EquipButtion




func _on_quit_button_pressed() -> void:
	queue_free()


func _on_artefacts_inventory_child_entered_tree(node: Node) -> void:
	if (node is ArtefactSlot):
		node.artefact_selected.connect(_on_artefact_selected)

func _on_artefact_slots_child_entered_tree(node: Node) -> void:
	if (node is ArtefactSlot):
		node.artefact_selected.connect(_on_artefact_selected_from_slots)


func _on_artefact_selected(name,description,stats,texture):
	self.artefact_name.text = name
	self.artefact_description.text = description
	self.artefact_stats.text = stats
	self.artefact_texture.texture = texture
	self.equip_buttion.text = "Equip"


func _on_artefact_selected_from_slots(name,description,stats,texture):
	self.artefact_name.text = name
	self.artefact_description.text = description
	self.artefact_stats.text = stats
	self.artefact_texture.texture = texture
	self.equip_buttion.text = "Unequip"
