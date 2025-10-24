class_name MetaProgression

extends Node

signal meta_updated(player_data: PlayerData)

const DEFAULT_INDEX = 0

var player_data: PlayerData
var _db: DatabaseManager

func _init(database: DatabaseManager) -> void:
	_db = database


func _ready() -> void:
	_get_all_meta()


func _get_all_meta():
	var player_meta = _db.get_player_meta()
	player_data = PlayerData.new()
	player_data.level = player_meta[DEFAULT_INDEX]["level"]
	player_data.currency = player_meta[DEFAULT_INDEX]["currency"]
	player_data.talent_points = player_meta[DEFAULT_INDEX]["talent_points"]
	emit_signal("meta_updated", player_data)


func player_data_to_string():
	return "level: " + str(player_data.level) + "; currency: " \
	+ str(player_data.currency) + "; talent_points: " + str(player_data.talent_points)


func update_currency(new_value: int):
	player_data.currency = new_value
	emit_signal("meta_updated", player_data)


func update_talent_points(new_value: int):
	player_data.talent_points = new_value
	emit_signal("meta_updated", player_data)


func update_player_level(new_value: int):
	player_data.level = new_value
	emit_signal("meta_updated", player_data)


func save_player_data():
	_db.insert_player_data(player_data)
