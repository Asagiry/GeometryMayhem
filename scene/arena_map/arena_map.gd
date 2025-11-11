class_name ArenaMap

extends Node

signal player_entered(zone: ArenaZone)
signal player_exited(zone: ArenaZone)

var player: PlayerController
var arena_zones: Array[ArenaZone]

@onready var basic_wall: TileMapLayer = %BasicWall
@onready var details: TileMapLayer = %Details
@onready var chunks: Node2D = %Chunks

@onready var stability_zone: TileMapLayer = %StabilityZone
@onready var flux_zone: TileMapLayer = %FluxZone
@onready var overload_zone: TileMapLayer = %OverloadZone
@onready var chaotic_zone: TileMapLayer = %ChaoticZone
@onready var outside_zone: TileMapLayer = %OutsideZone
@onready var chunk_loader: ChunkLoader = %ChunkLoader



func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	player.change_current_zone(stability_zone)
	arena_zones = [stability_zone,flux_zone,overload_zone,chaotic_zone,outside_zone]
	create_areas()
	chunk_loader.setup()


func create_areas():
	for area in arena_zones:
		area.create_area()
		area.entered_zone.connect(_on_entered_zone)
		area.exited_zone.connect(_on_exited_zone)


func _on_entered_zone(zone: ArenaZone):
	player.change_current_zone(zone)
	player_entered.emit(zone)


func _on_exited_zone(zone: ArenaZone):
	var next_zone = get_next_zone(zone)
	player.change_current_zone(next_zone)
	player_entered.emit(next_zone)
	player_exited.emit(zone)


func get_next_zone(current_zone: ArenaZone):
	match current_zone:
		stability_zone:
			return flux_zone
		flux_zone:
			return overload_zone
		overload_zone:
			return chaotic_zone


func get_previous_zone(current_zone: ArenaZone):
	match current_zone:
		flux_zone:
			return stability_zone
		overload_zone:
			return flux_zone
		chaotic_zone:
			return overload_zone
