class_name ParryController
extends BaseComponent

signal parry_started()
signal parry_finished()
signal parry_cooldown_timeout()

@export var parry_scene: PackedScene

var duration_multiplier: float = 1.0
var cooldown_multiplier: float = 1.0

var is_parrying: bool = false
var parry_instance: Parry
var player: PlayerController
var is_on_cooldown: bool

@onready var parry_cooldown: Timer = $ParryCooldown

func _ready():
	super._ready()
	_connect_signals()

func _setup_owner_reference():
	super._setup_owner_reference()
	if owner_node is PlayerController:
		player = owner_node
	else:
		player = get_tree().get_first_node_in_group("player") as PlayerController

	if parry_scene and player:
		parry_instance = parry_scene.instantiate() as Parry
		parry_instance.init(get_angle(), get_radius())
		player.add_child.call_deferred(parry_instance)

func _setup_stat_subscriptions():
	subscribe_to_stat("parry_angle", func(new_val, _old_val):
		if parry_instance:
			parry_instance.update_parameters(new_val, get_radius())
	)

	subscribe_to_stat("parry_radius", func(new_val, _old_val):
		if parry_instance:
			parry_instance.update_parameters(get_angle(), new_val)
	)

func start_cooldown():
	is_on_cooldown = true
	parry_cooldown.start(get_cooldown())

func _on_parry_cooldown_timeout() -> void:
	is_on_cooldown = false
	parry_cooldown_timeout.emit()

func activate_parry(input_state: bool):
	if is_parrying or is_on_cooldown:
		return

	parry_started.emit()
	is_parrying = true

	if parry_instance:
		parry_instance.update_parameters(get_angle(), get_radius())

	if input_state and player:
		var mouse_pos = player.get_global_mouse_position()
		var direction = (mouse_pos - player.global_position).normalized()

		player.rotation = direction.angle() + deg_to_rad(90)

		if player.movement_component:
			player.movement_component.last_direction = direction

	await get_tree().physics_frame
	await get_tree().physics_frame

	_parry_logic(input_state)

	await get_tree().create_timer(get_duration()).timeout

	is_parrying = false
	start_cooldown()
	parry_finished.emit()

func _parry_logic(input_state):
	if not parry_instance: return
	if input_state:
		parry_instance.force_refresh_targets()
	var successful_parry: bool = false
	for enemy in parry_instance.enemies_in_range:
		if is_instance_valid(enemy):
			var direction = (enemy.global_position - player.global_position).normalized()
			if enemy.has_method("apply_knockback"):
				enemy.apply_knockback(direction * get_push_force())
				successful_parry = true


	for proj in parry_instance.projectiles_in_range:
		if is_instance_valid(proj):
			print("SUCCESSFUL PROJECTILE PARRY")
			successful_parry = true

	if successful_parry:
		Global.player_successful_parry.emit()

func get_cooldown() -> float: return get_stat("parry_cd") * cooldown_multiplier
func get_angle() -> float: return get_stat("parry_angle")
func get_radius() -> float: return get_stat("parry_radius")
func get_duration() -> float: return get_stat("parry_duration") * duration_multiplier
func get_push_force() -> float: return get_stat("parry_push_force")

func _connect_signals():
	if player and player.effect_receiver:
		if not player.effect_receiver.attack_component_effects_changed \
		.is_connected(_on_effect_stats_changed):
			player.effect_receiver.attack_component_effects_changed \
			.connect(_on_effect_stats_changed)

	if not parry_cooldown.timeout.is_connected(_on_parry_cooldown_timeout):
		parry_cooldown.timeout.connect(_on_parry_cooldown_timeout)

func _on_effect_stats_changed(updated_stats) -> void:
	if updated_stats.has("attack_duration_multiplier"):
		duration_multiplier = updated_stats["attack_duration_multiplier"]
