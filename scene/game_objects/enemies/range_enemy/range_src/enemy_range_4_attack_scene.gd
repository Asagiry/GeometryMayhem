class_name EnemyRange4AttackScene
extends Node2D

const LIFETIME_OF_PROJECTILE: float = 6.0
const PHASE_GROW := 0
const PHASE_STAY := 1
var projectile_speed: float = 200.0
var direction: Vector2 = Vector2.ZERO
var effects: Array[Effect] = []
var magic_find: float
var max_distance: float = 200.0
var total_attack_duration: float = 0.5
var grow_time: float = 0.3
var stay_time: float = 0.2

@export var segment_length: float = 16.0

var phase: int = PHASE_GROW
var phase_timer: float = 0.0
var segments: Array[Sprite2D] = []
var total_segments: int = 0

@onready var hit_box_component = %HitBoxComponent
@onready var queue_free_timer: Timer = $QueueFreeTimer
@onready var segments_root: Node2D = $SegmentsRoot
@onready var segment_template: Sprite2D = $SegmentTemplate
@onready var collision_shape: CollisionShape2D = %HitBoxComponent/CollisionShape2D


func _ready() -> void:
	set_physics_process(true)
	queue_free_timer.start(LIFETIME_OF_PROJECTILE)
	segment_template.visible = false


func setup_laser(dir: Vector2, max_dist: float, duration: float) -> void:
	direction = dir.normalized()
	rotation = direction.angle()
	max_distance = max_dist
	total_attack_duration = duration
	grow_time = max(total_attack_duration * 0.7, 0.1)
	stay_time = max(total_attack_duration - grow_time, 0.1)
	_build_segments()
	_setup_hitbox()
	phase = PHASE_GROW
	phase_timer = 0.0


func _build_segments() -> void:
	for c in segments_root.get_children():
		c.queue_free()
	segments.clear()
	total_segments = int(ceil(max_distance / segment_length))
	if total_segments <= 0:
		total_segments = 1
	for i in range(total_segments):
		var s: Sprite2D = segment_template.duplicate() as Sprite2D
		s.visible = false         
		s.centered = true
		var dist := segment_length * (i + 0.5)
		s.position = Vector2.RIGHT * dist
		segments_root.add_child(s)
		segments.append(s)


func _setup_hitbox() -> void:
	var full_length := total_segments * segment_length
	var rect := collision_shape.shape as RectangleShape2D
	rect.extents.x = 0.05
	collision_shape.position = Vector2.RIGHT * (full_length * 0.5)


func _physics_process(delta: float) -> void:
	match phase:
		PHASE_GROW:
			phase_timer += delta
			var t = min(phase_timer / grow_time, 1.0)
			var visible_segments = int(round(total_segments * t))
			for i in range(segments.size()):
					segments[i].visible = i < visible_segments
			var effective_segments = max(visible_segments - 1, 0)
			var current_length = effective_segments * segment_length

			var rect = collision_shape.shape as RectangleShape2D
			rect.extents.x = current_length * 0.5
			collision_shape.position = Vector2.RIGHT * rect.extents.x
			if t >= 1.0:
				phase = PHASE_STAY
				phase_timer = 0.0
		PHASE_STAY:
			phase_timer += delta
			if phase_timer >= stay_time:
				queue_free()


func _on_hit_box_component_area_entered(area: Area2D):
	if area is HurtBox:
		if area.has_method("deal_damage"):
			area.deal_damage(hit_box_component.damage_data)
		if area.has_method("apply_effect"):
			area.apply_effect(effects, magic_find, hit_box_component.damage_data)
	queue_free()


func _on_queue_free_timer_timeout():
	queue_free()


func change_collision():
	hit_box_component.set_collision_mask_value(9, false)
	hit_box_component.set_collision_mask_value(8, true)


func set_enemy(p_enemy: EnemyController):
	effects = p_enemy.effects
	magic_find = p_enemy.stats.magic_find


func set_projectile_speed(p_projectile_speed):
	projectile_speed = p_projectile_speed


func set_direction(p_direction):
	direction = p_direction
