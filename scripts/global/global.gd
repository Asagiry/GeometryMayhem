extends Node

signal enemy_died(stats)

signal impulse_amount_changed(
	current_impulse: int,
	current_level: int,
	requirment_impulse: int
	)
signal player_died
signal player_spawned(player: PlayerController)
signal player_damage_done
signal player_successful_parry
signal player_stats_changed(updated_stats)
signal game_timer_timeout

signal game_started
signal game_ended


const DELAY_IN_CLOSING: float = 0.5
var meta_ui_instance

@onready var database := DatabaseManager.new()
@onready var artefact_database := ArtefactDatabase.new()
@onready var inventory := InventoryManager.new(database, artefact_database)
@onready var meta_progression := MetaProgression.new(database)
@onready var meta_ui := preload("res://scene/UI/meta/meta.tscn")


func _ready():
	add_child(database)
	add_child(artefact_database)
	add_child(inventory)
	add_child(meta_progression)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().set_auto_accept_quit(false)
		save_and_quit()


func _save():
	print(inventory.inventory_to_string())
	print(meta_progression.player_data_to_string())
	inventory.save_inventory()
	meta_progression.save_player_data()


func request_quit():
	_notification(NOTIFICATION_WM_CLOSE_REQUEST)



#TODO ADD TRANSACTION CHECK BEFORE QUITING
func save_and_quit():
	_save()
	await get_tree().create_timer(DELAY_IN_CLOSING).timeout
	get_tree().quit()
