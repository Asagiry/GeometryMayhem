class_name EnemySpawnerController

extends Node

@export var enabled: bool = false
@export var arena_map: ArenaMap

var player: PlayerController
var current_zone: ArenaZone
var zone_current_enemy: Dictionary[ArenaZone,int]

@onready var spawn_timer: Timer = %SpawnTimer


func _ready() -> void:
	arena_map.player_entered.connect(_on_player_entered)
	arena_map.player_exited.connect(_on_player_exited)
	if !enabled:
		queue_free()

func _on_player_entered(zone: ArenaZone):
	if zone.get_name() != "StabilityZone":
		current_zone = zone
		print("Спавн начат в зоне ",zone.get_zone_name())
		spawn_timer.start(zone.arena_stat_data.spawn_interval)
	else:
		print("Спавн окончен")
		spawn_timer.stop()

func _on_player_exited(_zone: ArenaZone):
	pass

func _on_spawn_timer_timeout() -> void:
	_spawn_enemy()

func _spawn_enemy():
	if current_zone:
		if zone_current_enemy.get(current_zone, 0) < current_zone.arena_stat_data.max_enemies:
			var spawn_point = current_zone.get_random_tile_point()
			var enemy_scene: PackedScene = _get_random_enemy_scene(current_zone)
			if (enemy_scene == null):
				return
			var enemy_instance = enemy_scene.instantiate() as EnemyController
			enemy_instance.global_position = spawn_point
			enemy_instance.stats.spawn_point = spawn_point
			get_tree().get_first_node_in_group("back_layer").call_deferred("add_child",
			enemy_instance)
			zone_current_enemy[current_zone] = zone_current_enemy.get(current_zone, 0) + 1
			enemy_instance.enemy_died.connect(_on_enemy_died.bind(current_zone))

func _get_random_enemy_scene(zone: ArenaZone):
	var path = "res://scene/game_objects/enemies/"
	var enemy_index = randi_range(1,3)#до трех
	var enemy_type: String
	match enemy_index:
		1:
			enemy_type = "melee_enemy"
		2:
			enemy_type = "range_enemy"
		3:
			enemy_type = "bomb_enemy"


	path += enemy_type + "/"
	path += zone.get_zone_name()+"/"

	var enemy_variant_count = _get_enemy_variant_count(path)
	var enemy_variant = randi_range(1,enemy_variant_count)

	path += enemy_type + "_" + str(enemy_variant)
	path += ".tscn"
	return load(path)


func _get_enemy_variant_count(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_count = 0
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():  # Только файлы, не папки
				file_count += 1
			file_name = dir.get_next()
		dir.list_dir_end()
		return file_count
	return 0


func _on_enemy_died(zone: ArenaZone):
	zone_current_enemy[zone] -= 1
	print("Текущее количество врагов в зоне ", zone.get_name(),
	zone_current_enemy[zone])
