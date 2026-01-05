class_name ChunkData
extends Resource

const TILE_PIXEL_SIZE = 16

var arena_zone: ArenaZone = null
var tile_array: Array[Dictionary] = []
var chunk_coord: Vector2i = Vector2i.ZERO
var chunk_size: float = 16
var area: Area2D = null
var is_loaded: bool = false

var arena_map: ArenaMap = null
var chunks_folder: Node = null

func _init(p_arena_map: ArenaMap,
p_chunk_coords,
p_chunk_size
) -> void:
	arena_map = p_arena_map
	chunks_folder = arena_map.chunks
	chunk_coord = p_chunk_coords
	chunk_size = p_chunk_size
	_create_area()


func _create_area():
	var chunk_size_px = chunk_size * TILE_PIXEL_SIZE
	area = Area2D.new()
	area.name = "ChunkArea_%d_%d" % [chunk_coord.x, chunk_coord.y]
	area.z_index = 1
	area.monitorable = false
	area.monitoring = false
	area.collision_layer = 0
	area.collision_mask = 0

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(chunk_size_px, chunk_size_px)
	shape.shape = rect

	area.add_child(shape)
	area.position = Vector2(
		chunk_coord.x * chunk_size_px + chunk_size_px / 2,
		chunk_coord.y * chunk_size_px + chunk_size_px / 2
	)



func load_chunk() -> void:
	if is_loaded:
		return

	for entry in tile_array:
		var pos: Vector2i = entry.pos
		var data: Dictionary = entry.data
		arena_zone.set_cell(pos, data.source, data.atlas, data.alt)
	if area and area.get_parent() != chunks_folder:
		chunks_folder.add_child(area)
	is_loaded = true


func unload_chunk() -> void:
	if not is_loaded:
		return

	_unload_chunk_to_tilemap()

	if area and area.get_parent() == chunks_folder:
		chunks_folder.remove_child(area)

	is_loaded = false


func _unload_chunk_to_tilemap() -> void:
	for entry in tile_array:
		var pos: Vector2i = entry.pos
		arena_zone.set_cell(pos, -1)
