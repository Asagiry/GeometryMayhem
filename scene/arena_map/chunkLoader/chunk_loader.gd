class_name ChunkLoader
extends Node

@export var draw_distance: int
@export var arena_map: ArenaMap
@export var query_wait_time: float
@export var life_time_enabled: bool
@export var chunk_life_time: int


var tile_data: Dictionary = {}
var chunk_by_coord: Dictionary = {}
var chunks_loaded: Dictionary = {}
var chunk_areas: Array[ChunkData] = []

var is_enabled: bool = true
var current_chunk: ChunkData = null

var chunks_to_load: Array[ChunkData] = []
var chunks_to_unload: Array[ChunkData] = []

@onready var chunks: Node = %Chunks
@onready var query_timer: Timer = %QueryTimer
@onready var unload_timer: Timer = %UnloadTimer



func setup():
	chunk_areas.clear()
	tile_data.clear()

	query_timer.start(query_wait_time)

	if life_time_enabled:
		unload_timer.autostart = true
		unload_timer.start(1.0)

	for arena_zone in arena_map.arena_zones:
		_get_tile_data(arena_zone)
		arena_zone.clear()
		_create_chunk_areas(arena_zone)


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
		var chunk_key = Vector2i(floor(cell_pos.x / 16.0), floor(cell_pos.y / 16.0))
		if not chunks_map.has(chunk_key):
			chunks_map[chunk_key] = []
		chunks_map[chunk_key].append(cell_pos)

	for chunk_key in chunks_map:
		var area = Area2D.new()
		area.name = "ChunkArea_%d_%d" % [chunk_key.x, chunk_key.y]
		area.z_index = 1
		area.monitoring = true
		area.collision_layer = 0      # не участвует в коллизиях
		area.collision_mask = 0
		area.set_collision_mask_value(10,true)

		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(256, 256)
		shape.shape = rect

		area.add_child(shape)
		area.position = Vector2(
			chunk_key.x * 256.0 + 128.0,
			chunk_key.y * 256.0 + 128.0)

		var chunk_res = ChunkData.new(arena_map, chunk_life_time)

		chunk_res.arena_zone = arena_zone
		chunk_res.area = area
		chunk_res.chunk_coord = chunk_key

		var tile_array: Array[Dictionary] = []
		for cell_pos in chunks_map[chunk_key]:
			tile_array.append({
				"pos": cell_pos,
				"data": tile_data[arena_zone][cell_pos]
			})
		chunk_res.tile_array = tile_array

		if (arena_zone.get_zone_name() == "stability"):
			chunk_res.load_chunk()
			chunks_loaded[chunk_res.chunk_coord] = chunk_res

		chunk_areas.append(chunk_res)

		chunk_by_coord[chunk_key] = chunk_res

		area.connect("body_entered", Callable(self, "_on_chunk_body_entered").bind(chunk_res))


func _on_chunk_body_entered(body: Node2D, chunk_entered: ChunkData):
	if body is not PlayerController:
		return

	current_chunk = chunk_entered

	var chunk_disk = get_disk_chunks_around_chunk(chunk_entered, draw_distance)

	var unloaded = []
	for chunk in chunk_disk:
		if not chunk.is_loaded and not chunks_loaded.has(chunk.chunk_coord):
			unloaded.append(chunk)
	chunks_to_load.append_array(unloaded)

	if not life_time_enabled:
		var current_set = {}
		for c in chunk_disk:
			current_set[c] = true

		for chunk in chunks_loaded.values():
			if not current_set.has(chunk):
				# Избегаем дублей
				if not chunks_to_unload.has(chunk):
					chunks_to_unload.append(chunk)

func _on_query_timer_timeout() -> void:

	if chunks_to_load.size()>0:
		var chunk = chunks_to_load.get(0)
		chunk.load_chunk()
		chunks_loaded[chunk.chunk_coord] = chunk
		chunks_to_load.remove_at(0)

	if chunks_to_unload.size()>0:
		var chunk = chunks_to_unload.get(0)
		chunk.unload_chunk()
		chunks_loaded.erase(chunk.chunk_coord)
		chunks_to_unload.remove_at(0)


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


func _on_unload_timer_timeout() -> void:
	var current_chunks = get_disk_chunks_around_chunk(current_chunk, draw_distance)
	var current_set = {}
	for c in current_chunks:
		current_set[c] = true

	for chunk : ChunkData in chunks_loaded.values():
		if not current_set.has(chunk):
			chunk.decrease_life_time()
			if chunk.get_life_time_left() <= 0:
				chunks_to_unload.append(chunk)
		else:
			chunk.reset_life_time()


func get_disk_chunks_around_chunk(center_chunk: ChunkData, radius: int) -> Array[ChunkData]:
	var result: Array[ChunkData] = []

	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var target_coord = center_chunk.chunk_coord + Vector2i(dx, dy)
			if chunk_by_coord.has(target_coord):
				result.append(chunk_by_coord[target_coord])

	return result
