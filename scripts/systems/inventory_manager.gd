class_name InventoryManager

extends Node

const DEFAULT_LEVEL: int = 1
const DEFAULT_EQUIPPED_STATUS: bool = false

var inventory: Array[PlayerArtefact] = []
var equipped_queue: Array[PlayerArtefact] = []
var _database: DatabaseManager
var _artefact_db: ArtefactDatabase


func _init(db: DatabaseManager, adb:ArtefactDatabase) -> void:
	_database = db
	_artefact_db = adb


func _ready() -> void:
	Global.player_spawned.connect(_on_player_spawned)
	_load_inventory()


func _load_inventory():
	var rows = _database.get_player_artefacts()
	for row in rows:
		var id = row.id
		inventory.append(
			_init_player_artefact(
				_artefact_db.get_artefact_by_id(id),
				id,
				row.equipped == 1,
				row.level,
				row.params
			)
		)


func _init_player_artefact(
	res: ArtefactData,
	id: String,
	equipped: bool,
	level: int,
	params
	):
	if res == null:
		push_warning("Missing artefact resource: %s" % id)
		return
	var player_artefact = PlayerArtefact.new()
	player_artefact.artefact = res
	update_equipped(player_artefact, equipped)
	player_artefact.level = level
	if params:
		if not params.is_empty():
			player_artefact.params = JSON.parse_string(params)
		else:
			player_artefact.params = res.base_params
	else:
		player_artefact.params = res.base_params
	return player_artefact


func update_equipped(player_artefact: PlayerArtefact, status: bool):
	player_artefact.equipped = status
	if status:
		equipped_queue.append(player_artefact)
	else:
		equipped_queue.erase(player_artefact)


func add_artefact(artefact_id: String):
	var artefact = _artefact_db.get_artefact_by_id(artefact_id)
	inventory.append(
		_init_player_artefact(
			artefact,
			artefact_id,
			DEFAULT_EQUIPPED_STATUS,
			DEFAULT_LEVEL,
			artefact.base_params
		)
	)


func get_player_artefact_by_id(id: String) -> PlayerArtefact:
	for art in inventory:
		if art.artefact.id == id:
			return art
	return null


func inventory_to_string():
	var data = ""
	for art in inventory:
		data += "id = " + str(art.artefact.id) + "; equipped = " + \
		str(art.equipped) + "; level = " + str(art.level) + \
		"; params: " + str(art.params)
		data += "\n"
	return data


func update_level(player_artefact: PlayerArtefact, level: int):
	player_artefact.level = level


func save_inventory():
	for art in inventory:
		_database.insert_player_artefact(art)


func get_all_artefacts():
	return inventory.duplicate()


func _on_player_spawned(player: PlayerController):
	for player_art in equipped_queue:
		if player_art.artefact and player_art.artefact.behavior_script:
			var behavior_instance = player_art.artefact.behavior_script.new()
			behavior_instance.apply_to_player(player, player_art.params)
