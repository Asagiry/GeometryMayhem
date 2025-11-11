class_name ChunkLoader
extends Node

@export var draw_distance: int
@export var arena_map: ArenaMap

var tile_data: Dictionary = {}
var chunk_areas: Array[ChunkData] = []
var last_loaded_chunks: Array[ChunkData] = []

@onready var chunks: Node2D = %Chunks

func setup():
	chunk_areas.clear()
	tile_data.clear()

	for arena_zone in arena_map.arena_zones:
		_get_tile_data(arena_zone)
		arena_zone.clear()
		_create_chunk_areas(arena_zone)
	print(chunk_areas.size())

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

	# Группируем тайлы по чанкам
	var chunks_map: Dictionary = {}
	for cell_pos in zone_data:
		var chunk_key = Vector2i(floor(cell_pos.x / 16.0), floor(cell_pos.y / 16.0))
		if not chunks_map.has(chunk_key):
			chunks_map[chunk_key] = []
		chunks_map[chunk_key].append(cell_pos)

	# Создаём ChunkData для каждого чанка
	for chunk_key in chunks_map:
		var area = Area2D.new()
		area.name = "ChunkArea_%d_%d" % [chunk_key.x, chunk_key.y]
		area.collision_mask = arena_zone.arena_stat_data.collision_mask
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

		area.connect("body_entered", Callable(self, "_on_chunk_body_entered").bind(area, arena_zone))
		area.connect("body_exited", Callable(self, "_on_chunk_body_exited").bind(area, arena_zone))

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

		chunk_areas.append(chunk_res)

		if arena_zone.get_zone_name() == "stability":
			chunks.add_child(area)
			chunk_res.load_chunk_to_tilemap()


func _on_chunk_body_entered(body, area: Area2D, zone: ArenaZone):
	# Находим текущий чанк
	var current_chunk: ChunkData = null
	for chunk in chunk_areas:
		if chunk.area == area:
			current_chunk = chunk
			break
	if not current_chunk:
		return

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

	# Выгрузка: удаляем всё, что загружено, но не в chunks_to_load
	for chunk in last_loaded_chunks:
		if chunk.is_loaded and not (chunk in chunks_to_load):
			chunk.unload_chunk()

	# Загрузка: добавляем всё, что нужно, но ещё не загружено
	for chunk in chunks_to_load:
		if not chunk.is_loaded:
			chunk.load_chunk()

	# Обновляем список активных чанков
	last_loaded_chunks = chunks_to_load

func _on_chunk_body_exited(body, area: Area2D, zone: ArenaZone):
	pass
