class_name MetaProgression

extends Node

signal meta_updated(player_data: PlayerData)

const DEFAULT_INDEX = 0

var meta_progression_data: MetaProgressionData
var player_data: PlayerData
var _db: DatabaseManager


func _init(database: DatabaseManager) -> void:
	_db = database


func _ready() -> void:
	_get_all_meta()
	Global.enemy_died.connect(_on_enemy_died)
	meta_progression_data = MetaProgressionData.new()


func _get_all_meta():
	var player_meta = _db.get_player_meta()
	player_data = PlayerData.new()
	player_data.level = player_meta[DEFAULT_INDEX]["level"]
	player_data.currency = player_meta[DEFAULT_INDEX]["currency"]
	player_data.talent_points = player_meta[DEFAULT_INDEX]["talent_points"]
	player_data.knowledge_count = player_meta[DEFAULT_INDEX]["knowledge_count"]
	emit_signal("meta_updated", player_data)


func player_data_to_string():
	return "level: " + str(player_data.level) + "; currency: " \
	+ str(player_data.currency) + "; talent_points: " + str(player_data.talent_points)\
	+"; knowledge_count: " + str(player_data.knowledge_count)


func update_currency(new_value: int):
	player_data.currency += new_value
	emit_signal("meta_updated", player_data)


func update_talent_points(new_value: int):
	player_data.talent_points += new_value
	emit_signal("meta_updated", player_data)


func update_player_level(new_value: int):
	player_data.level += new_value
	emit_signal("meta_updated", player_data)


func update_player_knowledge(new_value:int):
	player_data.knowledge_count += new_value
	emit_signal("meta_updated", player_data)



func save_player_data():
	_db.insert_player_data(player_data)


func _on_enemy_died(stats: EnemyStatData):
	_calculate_echo(stats)
	_calculate_knowledge(stats)


func _calculate_echo(stats: EnemyStatData):
	var chance = stats.echo_chance
	if randf() <= chance:
		update_currency(stats.echo_count)


func _calculate_knowledge(stats: EnemyStatData):
	update_player_knowledge(stats.knowledge_count)
	var required = meta_progression_data._get_required_knowledge(player_data.level)
	while player_data.knowledge_count >= required:
		update_player_knowledge(-required)
		update_player_level(1)
		update_talent_points(1)
		required = meta_progression_data._get_required_knowledge(player_data.level)

	emit_signal("meta_updated", player_data)
