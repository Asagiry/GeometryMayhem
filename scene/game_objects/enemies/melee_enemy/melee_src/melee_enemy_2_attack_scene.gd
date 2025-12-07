class_name MeleeEnemyAttackScene2
extends Node2D

signal attack_finished

const PARTICLES_MULTIPLIER: int = 40
# Скорость полета огня (пикселей в секунду).
# Настройте это число под себя (300 - медленный огонь, 600 - быстрый)
const FIRE_SPEED: float = 200.0

var attacked: bool = false
var effects: Array[Effect]
var magic_find: float

var _attack_range: float = 0.0
var _attack_angle: float = 90.0
var _attack_duration: float = 1.0

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var fire_particles: CPUParticles2D = %FireParticles
@onready var collision_polygon_2d: CollisionPolygon2D = %HitBoxComponent/CollisionPolygon2D

func _ready() -> void:
	randomize()
	fire_particles.local_coords = false
	fire_particles.emitting = false

	# Сброс гравитации и других сил, чтобы полет был ровным
	fire_particles.gravity = Vector2.ZERO
	fire_particles.orbit_velocity_min = 0.0
	fire_particles.orbit_velocity_max = 0.0

	collision_polygon_2d.polygon = PackedVector2Array()
	collision_polygon_2d.disabled = true


func perform_attack() -> void:
	if _attack_range <= 0.0:
		push_warning("MeleeAttack: Radius is 0!")
		_finish_attack()
		return
	fire_particles.initial_velocity_min = FIRE_SPEED
	fire_particles.initial_velocity_max = FIRE_SPEED
	fire_particles.lifetime = _attack_range / FIRE_SPEED
	fire_particles.emitting = true
	collision_polygon_2d.disabled = false
	_start_fire_tween()


func set_attack_duration(duration: float) -> void:
	_attack_duration = duration


func set_enemy(p_enemy):
	effects = p_enemy.effects
	magic_find = p_enemy.stats.magic_find


func set_attack_range(attack_range: float, angle_deg: float) -> void:
	_attack_range = attack_range
	_attack_angle = angle_deg
	fire_particles.amount = max(1, int(_attack_range) * PARTICLES_MULTIPLIER)


# --- TWEEN (Хитбокс) ---
# Хитбокс расширяется независимо от скорости частиц, за время _attack_duration
func _start_fire_tween() -> void:
	var tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)

	tween.tween_method(
		func(progress: float): _update_collision_sector(progress),
		0.0,
		1.0,
		_attack_duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(_finish_attack)


func _update_collision_sector(progress: float) -> void:
	var radius = _attack_range * clamp(progress, 0.0, 1.0)
	var half_angle_rad = deg_to_rad(_attack_angle / 2.0)
	var segments = max(8, int(_attack_angle / 22.5))
	var points: PackedVector2Array = [Vector2.ZERO]
	for i in range(segments + 1):
		var angle_rad = -half_angle_rad + (i / float(segments)) * (half_angle_rad * 2.0)
		points.append(Vector2(cos(angle_rad) * radius, sin(angle_rad) * radius))
	collision_polygon_2d.polygon = points
	if not attacked and not collision_polygon_2d.disabled:
		var overlapping_areas = hit_box_component.get_overlapping_areas()
		for area in overlapping_areas:
			_on_hit_box_component_area_entered(area)


# --- ЗАВЕРШЕНИЕ ---
func _finish_attack():
	fire_particles.emitting = false
	collision_polygon_2d.disabled = true
	attack_finished.emit()
	# Ждем, пока последние выпущенные частицы долетят свой путь (lifetime)
	# Lifetime теперь рассчитан точно под дистанцию
	await get_tree().create_timer(fire_particles.lifetime).timeout
	queue_free()


func _on_hit_box_component_area_entered(area: Area2D) -> void:
	if area is not HurtBox: return
	if area.has_method("deal_damage") and not attacked:
		area.deal_damage(hit_box_component.damage_data)
		attacked = true
	if area.has_method("apply_effect"):
		area.apply_effect(effects, magic_find, hit_box_component.damage_data)
