class_name SummonAttackController
extends BaseBossAttackController

const DISTANCE_FROM_BOSS: float = 200.0
const AGGRO_RADIUS: float = 2000.0

const BASE_PATH_MELEE: String = "res://scene/game_objects/enemies/melee_enemy/"
const BASE_PATH_RANGE: String = "res://scene/game_objects/enemies/range_enemy/"
const BASE_PATH_BOMB: String = "res://scene/game_objects/enemies/bomb_enemy/"

var zone: Util.Zone
var number_of_enemies: int

var is_parallel_mode: bool = true

@onready var cooldown_timer: Timer = %CooldownTimer

func activate_attack():
	attack_started.emit()
	spawn_enemies()
	attack_finished.emit()


func activate_parallel_attack():
	await activate_attack()
	if not is_parallel_mode:
		return
	_start_cooldown()


func spawn_enemies():
	var zone_folder = _get_zone_folder_name()
	for i in range(number_of_enemies):
		var archetype_base_path = _get_random_archetype_path()
		var full_path = archetype_base_path + zone_folder + "/"
		var enemy_scene = _get_random_scene_from_dir(full_path)
		if enemy_scene:
			var enemy_instance = enemy_scene.instantiate()
			var spawn_pos = _get_random_spawn_position()
			enemy_instance.global_position = spawn_pos
			if "aggro_zone_radius" in enemy_instance:
				enemy_instance.aggro_zone_radius = AGGRO_RADIUS
			get_tree().get_first_node_in_group("back_layer").add_child(enemy_instance)
			if enemy_instance.has_method("transition_to_aggro_state"):
				enemy_instance.transition_to_aggro_state()
		else:
			push_warning("SummonAttack: Не удалось найти сцены врагов в пути: ", full_path)


func _get_random_spawn_position() -> Vector2:
	var random_angle = randf() * TAU
	var offset = Vector2(cos(random_angle), sin(random_angle)) * DISTANCE_FROM_BOSS
	return owner.global_position + offset


func _get_random_archetype_path() -> String:
	var types = [BASE_PATH_MELEE, BASE_PATH_RANGE, BASE_PATH_BOMB]
	return types.pick_random()


func _get_zone_folder_name() -> String:
	match zone:
		Util.Zone.STABILITY: return "stability"
		Util.Zone.FLUX: return "flux"
		Util.Zone.OVERLOAD: return "overload"
		Util.Zone.CHAOTIC: return "chaotic"
		_: return "flux"


func _get_random_scene_from_dir(path: String) -> PackedScene:
	var dir = DirAccess.open(path)
	if not dir:
		push_error("Cannot open directory: " + path)
		return null
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var valid_scenes: Array[String] = []
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(".tscn") or file_name.ends_with(".scn") \
			or file_name.ends_with(".tscn.remap"):
				var clean_name = file_name.replace(".remap", "")
				valid_scenes.append(clean_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	if valid_scenes.is_empty():
		return null
	var random_file = valid_scenes.pick_random()
	return load(path + random_file) as PackedScene


func set_zone(value: Util.Zone) -> void:
	zone = value


func set_number_of_enemies(value: int) -> void:
	number_of_enemies = value


func set_cooldown_time(value: float) -> void:
	cooldown_timer.wait_time = value


func _start_cooldown():
	cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	if is_parallel_mode:
		activate_parallel_attack()
