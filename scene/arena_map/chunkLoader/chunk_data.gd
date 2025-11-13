class_name ChunkData
extends Resource

var arena_zone: ArenaZone = null
var tile_array: Array[Dictionary] = []
var chunk_coord: Vector2i = Vector2i.ZERO
var area: Area2D = null
var is_loaded: bool = false
var life_time: int

var arena_map: ArenaMap = null
var chunks_folder: Node = null

var _thread: Thread = null
var _cancelled: bool = false
var _time_left: int = false

func _init(p_arena_map: ArenaMap,
p_life_time: int) -> void:
	arena_map = p_arena_map
	chunks_folder = arena_map.chunks
	life_time = p_life_time


func reset_life_time():
	_time_left = 0


func decrease_life_time():
	_time_left += 1


func get_life_time_left():
	return max(life_time - _time_left,0)

# ---------------------------
func load_chunk() -> void:
	if is_loaded or _thread:
		reset_life_time()
		return

	is_loaded = true
	_cancelled = false

	_thread = Thread.new()
	_thread.start(_thread_load_chunk)


func unload_chunk() -> void:
	if !is_loaded:
		return

	_cancelled = true
	is_loaded = false

	_unload_chunk_to_tilemap()

	if area and area.get_parent() == chunks_folder:
		chunks_folder.remove_child(area)

	if _thread:
		_thread.wait_to_finish()
		_thread = null


# ---------------------------
# Поток — подготавливает данные
# ---------------------------
func _thread_load_chunk() -> void:
	var prepared_data: Array = []

	for entry in tile_array:
		if _cancelled:
			return
		prepared_data.append(entry)

	# Передаём готовый массив в основной поток
	call_deferred("_apply_chunk_data", prepared_data)


# ---------------------------
# Применение в основном потоке
# ---------------------------
func _apply_chunk_data(prepared_data: Array) -> void:
	if _cancelled:
		return

	for entry in prepared_data:
		var pos: Vector2i = entry.pos
		var data: Dictionary = entry.data
		arena_zone.set_cell(pos, data.source, data.atlas, data.alt)

	# Добавляем area обратно в сцену
	if area and area.get_parent() != chunks_folder:
		chunks_folder.add_child(area)

	# Поток закончил
	if _thread:
		_thread.wait_to_finish()
		_thread = null


# ---------------------------
# Выгрузка чанка
# ---------------------------
func _unload_chunk_to_tilemap() -> void:
	for entry in tile_array:
		var pos: Vector2i = entry.pos
		arena_zone.set_cell(pos, -1)
