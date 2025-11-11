class_name ChunkLoader
extends Node

@export var draw_distance: int
@export var arena_map: ArenaMap

var tile_data: Dictionary = {}
var chunk_areas: Array[ChunkData] = []
var last_loaded_chunks: Array[ChunkData] = []
@onready var chunks: Node = %Chunks

func setup():
	chunk_areas.clear()
	tile_data.clear()

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
		area.set_collision_mask_value(2,true)
		area.z_index = 1
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(256, 256)
		shape.shape = rect
		area.add_child(shape)
		shape.owner = area

		area.position = Vector2(
			chunk_key.x * 256.0 + 128.0,
			chunk_key.y * 256.0 + 128.0
		)

		# Создаём ChunkData
		var chunk_res = ChunkData.new(arena_map)
		chunk_res.arena_zone = arena_zone
		chunk_res.area = area

		var tile_array: Array[Dictionary] = []
		for cell_pos in chunks_map[chunk_key]:
			tile_array.append({
				"pos": cell_pos,
				"data": tile_data[arena_zone][cell_pos]
			})
		chunk_res.tile_array = tile_array

		if (arena_zone.get_zone_name() == "stability"):
				chunk_res.load_chunk()
		chunk_areas.append(chunk_res)

		area.connect("body_entered", Callable(self, "_on_chunk_body_entered").bind(chunk_res))

func _on_chunk_body_entered(body: Node2D, chunk_entered: ChunkData):
	if body is not PlayerController:
		return

	var area = chunk_entered.area

	var current_coord = Vector2i(
		floor((area.position.x - 128.0) / 256.0),
		floor((area.position.y - 128.0) / 256.0)
	)

	# Собираем чанки, которые ДОЛЖНЫ быть загружены
	var chunks_to_load: Array[ChunkData] = []
	for chunk in chunk_areas:
		var coord = Vector2i(
			floor((chunk.area.position.x - 128.0) / 256.0),
			floor((chunk.area.position.y - 128.0) / 256.0)
		)
		var dist = max(abs(coord.x - current_coord.x), abs(coord.y - current_coord.y))
		if dist <= draw_distance:
			chunks_to_load.append(chunk)

	var i = 0
	for chunk in last_loaded_chunks:
		if chunk.is_loaded and not (chunk in chunks_to_load):
			i+=1
			chunk.unload_chunk()
	print(i)
	for chunk in chunks_to_load:
		if not chunk.is_loaded:
			chunk.load_chunk()

	# Обновляем список активных чанков
	last_loaded_chunks = chunks_to_load
