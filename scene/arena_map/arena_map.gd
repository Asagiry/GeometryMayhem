class_name ArenaMap

extends Node

signal player_entered(zone: ArenaZone)
signal player_exited(zone: ArenaZone)


@export_group("ChunkLoader")
@export_enum("8", "16", "32") var chunk_size_str: String = "16"
@export var draw_distance: int = 1
@export var frequency_wait_time: float = 0.1
@export var query_wait_time: float = 0.1
@export var is_enabled_Chunk_loader = true

@export_group("SpawnerController")
@export var is_enabled_Spawner_controller: bool = false

@export_group("BossArena")
@export var tiles_per_frame = 32

var player: PlayerController
var arena_zones: Array[ArenaZone]
var chunk_size: float:
	get:
		return float(chunk_size_str)

var boss_arena_tiles: Dictionary = {}
var floor_index: int = 0
var wall_index: int = 0

@onready var basic_wall: TileMapLayer = %BasicWall
@onready var details: TileMapLayer = %Details
@onready var chunks: Node = %Chunks

@onready var stability_zone: TileMapLayer = %StabilityZone
@onready var flux_zone: TileMapLayer = %FluxZone
@onready var overload_zone: TileMapLayer = %OverloadZone
@onready var chaotic_zone: TileMapLayer = %ChaoticZone
@onready var outside_zone: TileMapLayer = %OutsideZone
@onready var enemy_spawner_controller: EnemySpawnerController = %EnemySpawnerController
@onready var chunk_loader: ChunkLoader = %ChunkLoader

@onready var boss_arena_floor: TileMapLayer = %BossArenaFloor
@onready var boss_arena_walls: TileMapLayer = %BossArenaWalls


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	player.change_current_zone(stability_zone)
	arena_zones = [stability_zone,flux_zone,overload_zone,chaotic_zone,outside_zone]
	create_areas()

	chunk_loader.setup()
	enemy_spawner_controller.setup()

	set_process(false)
	boss_arena_tiles["floor"] = _extract_tiles(boss_arena_floor)
	boss_arena_tiles["walls"] = _extract_tiles(boss_arena_walls)
	boss_arena_floor.clear()
	boss_arena_walls.clear()


	Global.game_timer_timeout.connect(func():
		set_process(true)
		boss_arena_floor.collision_enabled = false
		boss_arena_walls.collision_enabled = false)

	Global.player_pulled.connect(func():
		boss_arena_walls.collision_enabled = true
		chunk_loader.is_enabled = false
		chunk_loader.unload_all()
		chunk_loader.load_around_boss_arena())


func _process(_delta):
	var done = true

	# Пол
	for i in range(tiles_per_frame):
		if floor_index >= boss_arena_tiles["floor"].size():
			break
		var tile = boss_arena_tiles["floor"][floor_index]
		boss_arena_floor.set_cell(tile.pos, tile.source, tile.atlas, tile.alt)
		floor_index += 1
		done = false

	# Стены
	for i in range(tiles_per_frame):
		if wall_index >= boss_arena_tiles["walls"].size():
			break
		var tile = boss_arena_tiles["walls"][wall_index]
		boss_arena_walls.set_cell(tile.pos, tile.source, tile.atlas, tile.alt)
		wall_index += 1
		done = false

	if done:
		set_process(false)



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
		chaotic_zone:
			return outside_zone


func get_previous_zone(current_zone: ArenaZone):
	match current_zone:
		flux_zone:
			return stability_zone
		overload_zone:
			return flux_zone
		chaotic_zone:
			return overload_zone


func _extract_tiles(layer: TileMapLayer) -> Array:
	var tiles = []
	var used = layer.get_used_cells()
	for pos in used:
		tiles.append({
			"pos": pos,
			"source": layer.get_cell_source_id(pos),
			"atlas": layer.get_cell_atlas_coords(pos),
			"alt": layer.get_cell_alternative_tile(pos),
			"flip_h": layer.is_cell_flipped_h(pos),
			"flip_v": layer.is_cell_flipped_v(pos),
			"transpose": layer.is_cell_transposed(pos)
		})
	return tiles
