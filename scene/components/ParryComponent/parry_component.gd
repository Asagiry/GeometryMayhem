extends Node2D
class_name ParryComponent

@onready var parry_projectile_area: Area2D = %ParryProjectileArea
@onready var parry_melee_area: Area2D = %ParryMeleeArea
@onready var parry_cooldown: Timer = $ParryCooldown

@export var parry_cd: float = 0.2
@export var parry_window: float = 0.25
@export var push_duration: float = 0.3 
@export var push_angle_range: float = 30.0 
@export var push_distance: float = 80.0

var melee_targets: Array[Node2D]
var is_parrying: bool = false

func _ready():
	parry_projectile_area.projectile_detected.connect(_on_projectile_detected)
	parry_melee_area.melee_detected.connect(_on_melee_detected)

func activate_parry():
	if is_parrying or !parry_cooldown.is_stopped():
		return
	parry_cooldown.start(parry_cd)
	is_parrying = true
	melee_parry()
	await get_tree().create_timer(parry_window).timeout
	is_parrying = false
	
func melee_parry():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	for enemy in melee_targets.duplicate():
		if not is_instance_valid(enemy):
			continue
		push_enemy(enemy, player.last_direction)

func push_enemy(enemy: Node2D, facing_direction: Vector2) -> void:
	var direction = facing_direction.normalized()
	var angle_offset = deg_to_rad(randf_range(-push_angle_range, push_angle_range))
	direction = direction.rotated(angle_offset)
	
	var ray = RayCast2D.new()
	ray.target_position = direction * push_distance 
	enemy.add_child(ray)
	ray.enabled = true
	ray.force_raycast_update()
	
	var safe_distance = push_distance
	if ray.is_colliding():
		safe_distance = (ray.get_collision_point() - enemy.global_position).length() - 1
	ray.queue_free()
	
	var target_pos = enemy.global_position + direction * safe_distance
	
	var tween = get_tree().create_tween()
	tween.tween_property(enemy, "global_position", target_pos, push_duration)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	

#TODO тут пока не ясно, как отражать урон от projectile мобу, который его вызвал(AI)
func _on_projectile_detected(projectile: Area2D):
	if not is_parrying:
		return
	if projectile.has_method("reflect"):
		projectile.reflect()
	
func _on_melee_detected(enemies: Array[Node2D]):
	melee_targets = enemies.duplicate()
