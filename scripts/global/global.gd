extends Node

signal enemy_died(stats)

signal impulse_amount_changed(
	current_impulse: int,
	current_level: int,
	requirment_impulse: int
	)

signal boss_died
signal player_died
signal player_spawned(player: PlayerController)
signal player_damage_done
signal player_successful_parry
signal player_stats_changed(updated_stats)
signal player_successful_dash

signal game_timer_timeout
signal player_pulled
 
signal game_started
signal game_ended


const DELAY_IN_CLOSING: float = 0.5

var meta_ui_instance
var runtime_script: RuntimeScript
var base_total_kills: int = 0
var base_max_kills_in_game: int = 0
var base_games_played: int = 0
var base_boss_killed: int = 0
var session_total_kills_add: int = 0
var session_games_played_add: int = 0
var session_best_kills_in_game: int = 0
var session_boss_killed_add: int = 0
var _run_saved: bool = false

@onready var database: DatabaseManager = DatabaseManager.new()
@onready var artefact_database: ArtefactDatabase = ArtefactDatabase.new()
@onready var inventory: InventoryManager = InventoryManager.new(database, artefact_database)
@onready var meta_progression: MetaProgression = MetaProgression.new(database)
@onready var meta_ui = preload("res://scene/UI/meta/meta.tscn")
@onready var loot_manager: LootManager = LootManager.new()


func _ready():
	add_child(database)
	add_child(artefact_database)
	add_child(inventory)
	add_child(meta_progression)
	add_child(loot_manager)
	game_ended.connect(_on_game_ended)
	_load_stats_from_db_once()
	game_started.connect(_on_game_started)
	boss_died.connect(_on_boss_died)
	get_tree().root.close_requested.connect(_on_close_requested)

func _on_boss_died():
	get_tree().change_scene_to_file("res://scene/UI/end_game_screen/end_game_screen.tscn")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().set_auto_accept_quit(false)
		save_and_quit()


func _on_game_started():
	_run_saved = false
	runtime_script = RuntimeScript.new()
	add_child(runtime_script)


func _on_game_ended():
	_collect_run_stats_to_session()
	runtime_script.queue_free()


func _save():
	_collect_run_stats_to_session()
	print(inventory.inventory_to_string())
	print(meta_progression.player_data_to_string())
	inventory.save_inventory()
	meta_progression.save_player_data()
	_save_stats_to_db_once()



func request_quit():
	get_tree().set_auto_accept_quit(false)
	save_and_quit()

func _load_stats_from_db_once():
	var res = database.get_player_stats()
	if res.is_empty():
		base_total_kills = 0
		base_max_kills_in_game = 0
		base_games_played = 0
		base_boss_killed = 0
		return

	var row: Dictionary = res[0]
	base_total_kills = int(row.get("total_kills", 0))
	base_max_kills_in_game = int(row.get("max_kills_in_game", 0))
	base_games_played = int(row.get("games_played", 0))
	base_boss_killed = int(row.get("boss_killed", 0))

func _collect_run_stats_to_session():
	if _run_saved:
		return
	if runtime_script == null:
		return

	_run_saved = true

	var kills_in_run := runtime_script.killed_creeps
	session_total_kills_add += kills_in_run
	session_best_kills_in_game = max(session_best_kills_in_game, kills_in_run)
	session_games_played_add += 1



#TODO ADD TRANSACTION CHECK BEFORE QUITING
func save_and_quit():
	_save()
	await get_tree().create_timer(DELAY_IN_CLOSING).timeout
	get_tree().quit()
	
	

func _save_stats_to_db_once():
	var new_total_kills = base_total_kills + session_total_kills_add
	var new_games_played = base_games_played + session_games_played_add
	var new_boss_killed = base_boss_killed + session_boss_killed_add
	var new_max_kills = max(base_max_kills_in_game, session_best_kills_in_game)
	database.insert_player_stats(
		new_total_kills,
		new_max_kills,
		new_games_played,
		new_boss_killed
	)
	var after = database.get_player_stats()

func _on_close_requested():
	get_tree().set_auto_accept_quit(false)
	save_and_quit()
