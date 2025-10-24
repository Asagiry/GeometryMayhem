class_name ArtefactsInventory

extends CanvasLayer

@export var artefact_slot_scene: PackedScene

var equip_pressed: bool = false
var selected_artefact: PlayerArtefact
var selected_artefact_slot: ArtefactSlot

@onready var artefact_name: Label = %ArtefactName
@onready var artefact_description: Label = %ArtefactDescription
@onready var artefact_stats: Label = %ArtefactStats
@onready var artefact_texture: TextureRect = %ArtefactTexture
@onready var artefacts_inventory: FlowContainer = %ArtefactsInventory
@onready var upgrade_button: Button = %UpgradeButton
@onready var cost_label: Label = %CostLabel
@onready var search_edit: LineEdit = %SearchEdit
@onready var artefact_slots: CircularContainer = %ArtefactSlots
@onready var equip_button: Button = %EquipButtion

func _ready() -> void:
	_clear_artefact()
	upgrade_button.hide()
	equip_button.hide()
	_load_artefacts()


func _load_artefacts():
	for child in artefacts_inventory.get_children():
		child.queue_free()

	for art in Global.inventory.inventory:
		_create_artefact_slot(art, artefacts_inventory)
		if art.equipped:
			_create_artefact_slot(art, artefact_slots)

	if artefact_slots.get_children().size() < 4:
		for i in 4 - artefact_slots.get_children().size():
			_create_artefact_slot(null, artefact_slots)


func _create_artefact_slot(player_artefact: PlayerArtefact, container):
	var artefact_slot_instance = artefact_slot_scene.instantiate() as ArtefactSlot
	container.add_child(artefact_slot_instance)
	artefact_slot_instance.setup_slot(player_artefact)


func _clear_artefact():
	self.artefact_name.text = ""
	self.artefact_description.text = ""
	self.artefact_stats.text = ""
	self.artefact_texture.texture = null


func _setup_artefact(player_artefact: PlayerArtefact):
	if player_artefact == null:
		_clear_artefact()
		return
	self.artefact_name.text = player_artefact.artefact.display_name
	self.artefact_description.text = player_artefact.artefact.description
	self.artefact_stats.text = "50% TODO"
	self.artefact_texture.texture = player_artefact.artefact.icon


func _on_quit_button_pressed() -> void:
	queue_free()


func _on_artefacts_inventory_child_entered_tree(node: Node) -> void:
	if (node is ArtefactSlot):
		node.artefact_selected.connect(_on_artefact_selected)


func _on_artefact_slots_child_entered_tree(node: Node) -> void:
	if (node is ArtefactSlot):
		node.artefact_selected.connect(_on_artefact_selected_from_slots)


func _on_artefact_selected(artefact_slot, player_artefact: PlayerArtefact):
	if player_artefact not in Global.inventory.equipped_queue:
		equip_button.show()
	else:
		equip_button.hide()
	upgrade_button.show()
	artefact_slots.stop_shake()
	equip_pressed = false
	selected_artefact = player_artefact
	_setup_artefact(player_artefact)
	self.equip_button.text = "Equip"


func _on_artefact_selected_from_slots(artefact_slot, player_artefact: PlayerArtefact):
	if not artefact_slot.player_artefact:
		upgrade_button.hide()
		equip_button.hide()
	else:
		equip_button.show()
		upgrade_button.show()

	if equip_pressed:
		Global.inventory.update_equipped(selected_artefact, true)
		artefact_slot.player_artefact = selected_artefact
		artefact_slot.setup_slot()
		equip_pressed = false
		equip_button.hide()
		artefact_slots.stop_shake()
		_setup_artefact(selected_artefact)
		if player_artefact != null:
			Global.inventory.update_equipped(player_artefact, false)
	else:
		selected_artefact = player_artefact
		selected_artefact_slot = artefact_slot
		_setup_artefact(player_artefact)

	self.equip_button.text = "Unequip"


func _on_equip_buttion_pressed() -> void:
	if equip_button.text == "Equip":
		equip_pressed = true
		artefact_slots.start_shake()
	elif equip_button.text == "Unequip":
		if selected_artefact_slot == null:
			return
		Global.inventory.update_equipped(selected_artefact_slot.player_artefact, false)
		selected_artefact_slot.player_artefact = null
		selected_artefact_slot.setup_slot()
		equip_button.hide()
		upgrade_button.hide()
		_clear_artefact()
