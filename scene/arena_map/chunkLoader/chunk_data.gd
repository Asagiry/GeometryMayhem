class_name ChunkData
extends Resource

var arena_zone: ArenaZone = null
var tile_array: Array[Dictionary] = []
var area: Area2D = null
var is_loaded: bool = false

var arena_map: ArenaMap = null
var chunks_folder: Node = null

func _init(p_arena_map) -> void:
	arena_map = p_arena_map
	chunks_folder = arena_map.chunks


func load_chunk_to_tilemap() -> void:
	for entry in tile_array:
		var pos: Vector2i = entry.pos
		var data: Dictionary = entry.data
		arena_zone.set_cell(pos, data.source, data.atlas, data.alt)
	is_loaded = true


func unload_chunk_to_tilemap() -> void:
	for entry in tile_array:
		var pos: Vector2i = entry.pos
		arena_zone.set_cell(pos, -1)
	is_loaded = false


func load_chunk() -> void:
	if is_loaded:
		return

	is_loaded = true

	load_chunk_to_tilemap()
	if area.get_parent() != chunks_folder:
		chunks_folder.add_child.call_deferred(area)


func unload_chunk() -> void:
	if !is_loaded:
		return

	is_loaded = false

	unload_chunk_to_tilemap()
	if area.get_parent() == chunks_folder:
		chunks_folder.remove_child(area)
