class_name ConcentricRingsAttackController
extends BaseBossAttackController

const DEFAULT_NUMBER_OF_PROJECTILES: int = 10
const DEFAULT_INITIAL_RADIUS: float = 150.0
const DEFAULT_SPEED_OF_RING: float = 50.0

var damage: DamageData = DamageData.new()
var rings_speed: Array[float] = []
var projectiles_per_ring: Array[int] = []
var number_of_rings: int
var distance_between_rings: float
var projectile_size: float
var duration: float

var is_parallel_mode: bool = true

var active_projectiles: Array[Node] = []

@onready var cooldown_timer: Timer = %CooldownTimer

func activate_attack():
	attack_started.emit()
	destroy_concentric_rings()
	_create_and_setup_attack()
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		destroy_concentric_rings()
	else:
		pass
	attack_finished.emit()


func activate_parallel_attack():
	await activate_attack()
	if not is_parallel_mode:
		return
	if duration > 0:
		_start_cooldown()
	else:
		pass


func destroy_concentric_rings():
	for projectile in active_projectiles:
		if is_instance_valid(projectile):
			projectile.queue_free()
	active_projectiles.clear()


func _create_and_setup_attack():
	for r in range(number_of_rings):
		var current_radius = DEFAULT_INITIAL_RADIUS + (r * distance_between_rings)
		var base_speed_deg = _get_speed_for_ring(r)
		var base_speed_rad = deg_to_rad(base_speed_deg)
		var direction_modifier = 1 if r % 2 == 0 else -1
		var current_ring_speed = base_speed_rad * direction_modifier
		var count_for_this_ring = _get_projectiles_count_for_ring(r)
		for p in range(count_for_this_ring):
			var angle_step = TAU / count_for_this_ring
			var start_angle = angle_step * p
			var attack_instance = _create_single_projectile()
			active_projectiles.append(attack_instance)
			_setup_projectile(
				attack_instance,
				current_radius,
				start_angle,
				current_ring_speed
			)


func _get_speed_for_ring(ring_index: int) -> float:
	if rings_speed.is_empty():
		return DEFAULT_SPEED_OF_RING
	if ring_index < rings_speed.size():
		return rings_speed[ring_index]
	return rings_speed.back()


func _get_projectiles_count_for_ring(ring_index: int) -> int:
	if projectiles_per_ring.is_empty():
		return DEFAULT_NUMBER_OF_PROJECTILES
	if ring_index < projectiles_per_ring.size():
		return projectiles_per_ring[ring_index]
	return projectiles_per_ring.back()


func _setup_projectile(
	attack_instance: ConcentricRingsAttackScene,
	radius: float,
	start_angle: float,
	speed: float
) -> void:
	attack_instance.global_position = owner.global_position
	attack_instance.set_enemy(owner)
	attack_instance.set_damage(damage)
	attack_instance.set_parameters(
		projectile_size,
		owner,
		radius,
		start_angle,
		speed
	)


func _create_single_projectile():
	var attack_instance = attack_scene.instantiate() as ConcentricRingsAttackScene
	get_tree().get_first_node_in_group("front_layer").add_child(attack_instance)
	return attack_instance


func set_damage(p_damage: DamageData):
	damage = p_damage


func set_rings_speed(values: Array) -> void:
	rings_speed.clear()
	for val in values:
		rings_speed.append(float(val))


func set_projectiles_per_ring(values: Array) -> void:
	projectiles_per_ring.clear()
	for val in values: projectiles_per_ring.append(int(val))


func set_number_of_rings(value: int) -> void:
	number_of_rings = max(1, value)


func set_distance_between_rings(value: float) -> void:
	distance_between_rings = value


func set_projectile_size(value: float) -> void:
	projectile_size = value


func set_duration(value: float) -> void:
	duration = value


func set_cooldown_time(value: float) -> void:
	cooldown_timer.wait_time = value


func _start_cooldown():
	cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	if is_parallel_mode:
		activate_parallel_attack()
