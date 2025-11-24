class_name EnemySpawnerController

extends Node

@export var arena_map: ArenaMap

var is_enabled: bool = false
var player: PlayerController
var current_zone: ArenaZone
var zone_current_enemy: Dictionary[ArenaZone, int] = {}
var spawn_active: bool = true
var _enemy_scene_cache: Dictionary = {}

@onready var spawn_timer: Timer = %SpawnTimer


func setup() -> void:
	is_enabled = arena_map.is_enabled_spawner_controller

	arena_map.player_entered.connect(_on_player_entered)
	arena_map.player_exited.connect(_on_player_exited)


func _on_player_entered(zone: ArenaZone) -> void:
	if not is_enabled:
		return

	if zone.get_name() == "StabilityZone":
		_stop_spawning()
		return

	_start_spawning(zone)


func _on_player_exited(_zone: ArenaZone) -> void:
	pass


func _start_spawning(zone: ArenaZone) -> void:
	current_zone = zone
	print("Спавн начат в зоне ", zone.get_zone_name())
	spawn_timer.start(zone.arena_stat_data.spawn_interval)


func _stop_spawning() -> void:
	print("Спавн окончен")
	spawn_timer.stop()
	current_zone = null


func _on_spawn_timer_timeout() -> void:
	if spawn_active:
		_spawn_enemy()


func disable_spawning():
	spawn_active = false
	spawn_timer.stop()
	print("Спавн отключен")


func enable_spawning():
	spawn_active = true
	print("Спавн включен")


func _spawn_enemy():
	if current_zone:
		if zone_current_enemy.get(current_zone, 0) < current_zone.arena_stat_data.max_enemies:
			var spawn_point: Vector2 = current_zone.get_random_tile_point()
			var enemy_scene: PackedScene = _get_random_enemy_scene(current_zone)
			if (enemy_scene == null):
				return
			var enemy_instance = enemy_scene.instantiate() as EnemyController
			enemy_instance.stats = enemy_instance.stats.duplicate(true)
			enemy_instance.global_position = spawn_point
			enemy_instance.stats.spawn_point = spawn_point
			get_tree().get_first_node_in_group("back_layer").add_child(enemy_instance)
			zone_current_enemy[current_zone] = zone_current_enemy.get(current_zone, 0) + 1
			enemy_instance.enemy_died.connect(_on_enemy_died.bind(current_zone))


func _get_random_enemy_scene(zone: ArenaZone) -> PackedScene:
	var zone_name: String = zone.get_zone_name()

	if zone_name in ["overload", "chaotic"]:
		return null

	var cache_key: String = "%s_%d" % [zone_name, randi()]
	if _enemy_scene_cache.has(cache_key):
		return _enemy_scene_cache[cache_key]

	var enemy_types: Array = ["melee_enemy", "range_enemy", "bomb_enemy"]
	var enemy_type: String = enemy_types[randi() % enemy_types.size()]

	var path: String = "res://scene/game_objects/enemies/%s/%s/" % [enemy_type, zone_name]
	var enemy_variant_count: int = _get_enemy_variant_count(path)

	if enemy_variant_count <= 0:
		return null

	var enemy_variant: int = randi_range(1, enemy_variant_count)
	path += "%s_%d.tscn" % [enemy_type, enemy_variant]

	var scene: PackedScene = load(path) as PackedScene
	if scene:
		_enemy_scene_cache[cache_key] = scene

	return scene


func _get_enemy_variant_count(path: String) -> int:
	var dir: DirAccess = DirAccess.open(path)
	if not dir:
		return 0

	dir.list_dir_begin()
	var file_count: int = 0
	var file_name: String = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			file_count += 1
		file_name = dir.get_next()

	dir.list_dir_end()
	return file_count


func _on_enemy_died(zone: ArenaZone) -> void:
	if zone_current_enemy.has(zone):
		zone_current_enemy[zone] = max(0, zone_current_enemy[zone] - 1)
		print("Текущее количество врагов в зоне %s: %d" % [zone.get_name(), zone_current_enemy[zone]])
