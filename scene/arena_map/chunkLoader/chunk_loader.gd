class_name ChunkLoader
extends Node

@export var arena_map: ArenaMap

var chunk_size_str: String
var chunk_size: float:
	get:
		return float(chunk_size_str)
var draw_distance: int
var frequency_wait_time: float
var query_wait_time: float


var tile_data: Dictionary = {}
var chunk_by_coord: Dictionary = {}
var chunks_loaded: Dictionary = {}
var chunks_to_load: Array[ChunkData] = []
var chunks_to_unload: Array[ChunkData] = []

var player: PlayerController = null
var last_chunk: ChunkData = null
var is_enabled: bool = true

@onready var chunks: Node = %Chunks
@onready var query_timer: Timer = %QueryTimer
@onready var frequency_timer: Timer = %FrequencyTimer



func setup():
	chunk_size_str = arena_map.chunk_size_str
	draw_distance = arena_map.draw_distance
	frequency_wait_time = arena_map.frequency_wait_time
	query_wait_time = arena_map.query_wait_time
	is_enabled = arena_map.is_enabled_chunk_loader
	player = arena_map.player
	tile_data.clear()
	chunk_by_coord.clear()
	chunks_loaded.clear()

	frequency_timer.wait_time = frequency_wait_time
	frequency_timer.start()
	query_timer.wait_time = query_wait_time
	query_timer.start()
	for arena_zone in arena_map.arena_zones:
		_get_tile_data(arena_zone)
		arena_zone.clear()
		_create_chunk_areas(arena_zone)
	if Global.has_signal("player_died"):
		if not Global.player_died.is_connected(_on_player_died):
			Global.player_died.connect(_on_player_died)

func _on_player_died():
	is_enabled = false
	frequency_timer.stop()
	query_timer.stop()


func _get_tile_data(arena_zone: ArenaZone):
	var zone_data = {}
	var used_cells = arena_zone.get_used_cells()
	for cell_pos in used_cells:
		var source_id = arena_zone.get_cell_source_id(cell_pos)
		var atlas_coords = arena_zone.get_cell_atlas_coords(cell_pos)
		var alternative_tile = arena_zone.get_cell_alternative_tile(cell_pos)
		zone_data[cell_pos] = {
			"source": source_id,
			"atlas": atlas_coords,
			"alt": alternative_tile
		}
	tile_data[arena_zone] = zone_data


func _create_chunk_areas(arena_zone: ArenaZone):
	var zone_data = tile_data[arena_zone]

	var chunks_map: Dictionary = {}
	for cell_pos in zone_data:
		var chunk_key = Vector2i(floor(cell_pos.x / chunk_size), floor(cell_pos.y / chunk_size))
		if not chunks_map.has(chunk_key):
			chunks_map[chunk_key] = []
		chunks_map[chunk_key].append(cell_pos)

	for chunk_key in chunks_map:

		var chunk_res = ChunkData.new(arena_map,
		chunk_key,
		chunk_size)

		chunk_res.arena_zone = arena_zone
		chunk_res.chunk_coord = chunk_key

		var tile_array: Array[Dictionary] = []
		for cell_pos in chunks_map[chunk_key]:
			tile_array.append({
				"pos": cell_pos,
				"data": tile_data[arena_zone][cell_pos]
			})
		chunk_res.tile_array = tile_array
		chunk_by_coord[chunk_key] = chunk_res



func _on_query_timer_timeout() -> void:
	if !is_enabled:
		return
	var operations = 0

	if chunks_to_load.size()>0:
		var chunk = chunks_to_load[0]
		chunk.load_chunk()
		chunks_loaded[chunk.chunk_coord] = chunk
		chunks_to_load.remove_at(0)
		operations+=1

	if chunks_to_unload.size()>0:
		var chunk = chunks_to_unload[0]
		chunk.unload_chunk()
		chunks_loaded.erase(chunk.chunk_coord)
		chunks_to_unload.remove_at(0)
		operations+=1

	if (operations == 0):
		query_timer.stop()

func _on_frequency_timer_timeout() -> void:
	if !is_enabled:
		return

	var current_chunk = get_current_chunk()
	if current_chunk == null:
		return

	if current_chunk == last_chunk:
		return
	last_chunk = current_chunk
	_handle_chunks(current_chunk)
	query_timer.start(query_wait_time)


func _handle_chunks(current_chunk: ChunkData):
	chunks_to_load = []

	var chunks_in_radius: Array[ChunkData] = get_disk_chunks_around_chunk(current_chunk)

	for chunk in chunks_in_radius:
		if not chunks_loaded.has(chunk.chunk_coord):
			chunks_to_load.append(chunk)

	chunks_to_unload = []
	for coord in chunks_loaded.keys():
		var chunk: ChunkData = chunks_loaded[coord]
		if not (chunk in chunks_in_radius):
			chunks_to_unload.append(chunk)





func get_current_chunk() -> ChunkData:
	if not is_instance_valid(player):
		return null

	const TILE_SIZE = 16

	var player_tile = Vector2i(player.global_position) / TILE_SIZE

	var chunk_coord = Vector2i(
		floor(player_tile.x / chunk_size),
		floor(player_tile.y / chunk_size)
	)

	return chunk_by_coord.get(chunk_coord, null)


func get_ring_chunks_around_chunk(center_chunk: ChunkData,
radius: int = draw_distance) -> Array[ChunkData]:
	if radius == 0:
		return [center_chunk]

	var result: Array[ChunkData] = []

	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			if abs(dx) != radius and abs(dy) != radius:
				continue

			var target_coord = center_chunk.chunk_coord + Vector2i(dx, dy)
			if chunk_by_coord.has(target_coord):
				result.append(chunk_by_coord[target_coord])

	return result


func get_disk_chunks_around_chunk(center_chunk: ChunkData,
radius: int = draw_distance) -> Array[ChunkData]:
	var result: Array[ChunkData] = []

	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var target_coord = center_chunk.chunk_coord + Vector2i(dx, dy)
			if chunk_by_coord.has(target_coord):
				result.append(chunk_by_coord[target_coord])

	return result


func unload_all():
	for chunk: ChunkData in chunks_loaded.values():
		chunk.unload_chunk()
		chunks_loaded.erase(chunk.chunk_coord)


func load_around_boss_arena():
	for chunk: ChunkData in chunk_by_coord.values():
		if chunk.chunk_coord.x > -6 and chunk.chunk_coord.x < 5 \
		and chunk.chunk_coord.y >-6 and chunk.chunk_coord.y < 5:
			chunk.load_chunk()
