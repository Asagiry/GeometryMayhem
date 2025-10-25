class_name DatabaseManager

extends Node

const PLAYER_ID: String = "player1"
const _DATABASE_PATH: String = "user://save/save.db"

var _database: SQLite

func _ready():
	_create_folder_if_needed()
	_init_database()


func _create_folder_if_needed():
	var dir := DirAccess.open("user://")
	if dir.dir_exists("save"):
		return
	var err := dir.make_dir("save")
	if err != OK:
		push_error("Не удалось создать папку save/: %s" % str(err))
		return


func _init_database():
	_database = SQLite.new()
	_database.path = _DATABASE_PATH
	var open_result = _database.open_db()

	if !open_result:
		push_error("Не удалось открыть или создать базу данных: %s" % str(open_result))
		return

	_create_tables_if_needed()
	_create_player_record_if_needed()
	print("Успешная инициализация БД")


func _create_tables_if_needed():
	_database.query("""
		CREATE TABLE IF NOT EXISTS player_meta (
			id TEXT PRIMARY KEY UNIQUE,
			level INTEGER DEFAULT 1,
			currency INTEGER DEFAULT 0,
			talent_points INTEGER DEFAULT 0
		);
	""")

	_database.query("""
		CREATE TABLE IF NOT EXISTS player_artefacts (
			id TEXT PRIMARY KEY UNIQUE,
			equipped INTEGER DEFAULT 0,
			level INTEGER DEFAULT 1
		);
	""")


func _create_player_record_if_needed():
	_database.query(
		"""SELECT * FROM player_meta WHERE id = '%s'
		""" % [PLAYER_ID]
	)

	if _database.query_result.is_empty():
		_database.query("INSERT INTO player_meta (id) VALUES('%s')" % [PLAYER_ID])


func insert_player_artefact(player_art: PlayerArtefact):
	_database.query("""
	INSERT INTO player_artefacts (id, equipped, level)
	VALUES ('%s', %d, %d)
	ON CONFLICT(id) DO UPDATE SET
	equipped = excluded.equipped,
	level = excluded.level;
	""" % [
	player_art.artefact.id,
	1 if player_art.equipped else 0,
	player_art.level
	])


func insert_player_data(player_data: PlayerData):
	_database.query("""
	INSERT INTO player_meta (id, currency, level, talent_points)
	VALUES ('%s', %d, %d, %d)
	ON CONFLICT(id) DO UPDATE SET
	currency = excluded.currency,
	level = excluded.level,
	talent_points = excluded.talent_points;
	""" % [
		PLAYER_ID,
		player_data.currency,
		player_data.level,
		player_data.talent_points
		]
	)

#возвращает массив словарей такого вида { "id":..., "equipped": 1/0, "level": 1-4}
func get_player_artefacts():
	_database.query("""SELECT * FROM player_artefacts""")
	return _database.query_result


func get_player_meta():
	_database.query("""SELECT level, currency, talent_points FROM player_meta;""")
	return _database.query_result
