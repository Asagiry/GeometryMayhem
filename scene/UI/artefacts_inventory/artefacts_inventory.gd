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
	upgrade_button.hide()
	equip_button.hide()


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


func _on_artefact_selected(_artefact_slot, player_artefact: PlayerArtefact):
	selected_artefact = player_artefact
	equip_pressed = false
	artefact_slots.stop_shake()
	_setup_artefact(player_artefact)
	_update_equip_button_state(player_artefact)
	upgrade_button.show()


func _on_artefact_selected_from_slots(artefact_slot, player_artefact: PlayerArtefact):
	selected_artefact_slot = artefact_slot

	if equip_pressed:
		# Экипируем артефакт
		_equip_artefact(selected_artefact, artefact_slot, player_artefact)
	else:
		# Просто выбрали артефакт в слоте
		selected_artefact = player_artefact
		_setup_artefact(player_artefact)
		_update_equip_button_state(player_artefact)
		upgrade_button.show()

	equip_pressed = false


func _on_equip_buttion_pressed() -> void:
	if equip_button.text == "Equip":
		equip_pressed = true
		artefact_slots.start_shake()
	elif equip_button.text == "Unequip":
		_unequip_artefact(selected_artefact)


# =========================
#     ЛОГИКА ЭКИПИРОВКИ
# =========================

func _equip_artefact(artefact: PlayerArtefact, target_slot: ArtefactSlot, replaced_artefact: PlayerArtefact):
	if not artefact:
		return

	# Если слот был занят — снимаем старый артефакт
	if replaced_artefact:
		Global.inventory.update_equipped(replaced_artefact, false)

	# Экипируем новый
	Global.inventory.update_equipped(artefact, true)
	target_slot.player_artefact = artefact
	target_slot.setup_slot()

	artefact_slots.stop_shake()
	_setup_artefact(artefact)
	_update_equip_button_state(artefact)


func _unequip_artefact(artefact: PlayerArtefact):
	if not artefact:
		return

	# Если артефакт экипирован, снимаем его
	Global.inventory.update_equipped(artefact, false)

	# Ищем слот, где он находился
	for slot in artefact_slots.get_children():
		if slot.player_artefact == artefact:
			slot.setup_slot(null)
			break

	_clear_artefact()
	equip_button.hide()
	upgrade_button.hide()
	artefact_slots.stop_shake()
	_update_equip_button_state(null)


# =========================
#       ВСПОМОГАТЕЛЬНЫЕ
# =========================

func _update_equip_button_state(player_artefact: PlayerArtefact):
	if player_artefact == null:
		equip_button.hide()
		return

	equip_button.show()
	if player_artefact in Global.inventory.equipped_queue:
		equip_button.text = "Unequip"
	else:
		equip_button.text = "Equip"
