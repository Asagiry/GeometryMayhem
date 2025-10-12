class_name DashAttackController

extends Node

@export var dash_attack_scene: PackedScene
@export var dash_attack_damage: float = 10.0
@export var dash_attack_range: float = 100.0
@export var damage_multiplier: float = 1.0
@export var attack_cd: float = 1.0
@export var dash_attack_width = 25

var is_dash_from_mouse: bool = false
var dash_duration: float = 0.2
var player

@onready var hurt_box_shape: CollisionShape2D = %HurtBoxShape
@onready var cooldown_timer: Timer = %CooldownTimer

func _ready():
	player = get_tree().get_first_node_in_group("player") as Node2D

func activate_dash(input_state: bool):
	is_dash_from_mouse = input_state
	if !cooldown_timer.is_stopped():
		return

	var dash_attack_instance = dash_attack_scene.instantiate() as DashAttack
	get_tree().get_first_node_in_group("front_layer").add_child(dash_attack_instance)
	dash_attack_instance.hit_box_component.damage = dash_attack_damage * damage_multiplier
	var forward := Vector2.UP.rotated(player.rotation)
	disable_player_hurt_box(true)
	disable_player_inputs(true)
	
	if is_dash_from_mouse:
		activate_mouse_click_dash(dash_attack_instance, forward)
	else:
		activate_space_dash(dash_attack_instance, forward)

func activate_mouse_click_dash(dash_attack_instance, forward):
	var mouse_pos = player.get_global_mouse_position()
	var direction = mouse_pos - player.global_position
	var distance = direction.length()
	mouse_pos = player.global_position + direction.normalized() * dash_attack_range
	player.last_direction = (mouse_pos - player.global_position).normalized()
	player.rotation = player.last_direction.angle() + PI / 2
	start_cooldown_timer()
	start_dash_tween(mouse_pos, dash_attack_instance)


func activate_space_dash(dash_attack_instance, forward):
	set_dash(dash_attack_instance, forward)
	start_cooldown_timer()
	start_dash_tween(player.global_position + forward * dash_attack_range, \
	dash_attack_instance)


func start_cooldown_timer():
	cooldown_timer.wait_time = attack_cd
	cooldown_timer.start()


func disable_player_hurt_box(disable: bool):
	hurt_box_shape.disabled = disable

func disable_player_inputs(disable: bool):
	player.is_input_blocked = disable

func start_dash_tween(target_position, dash_attack_instance: DashAttack):
	var tween = create_tween()
	tween.tween_property(player, "global_position", target_position, dash_duration) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

	var tween2 = create_tween()
	tween2.tween_property(player.animated_sprite_2d, "scale", Vector2(0.25, 1), dash_duration / 2) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	
	tween2.finished.connect(func():
		var back_tween = create_tween()
		back_tween.tween_property(player.animated_sprite_2d, "scale", Vector2(1, 1), dash_duration / 2) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	)

	tween.tween_callback(Callable(dash_attack_instance, "queue_free"))
	tween.finished.connect(func():
		disable_player_hurt_box(false)
		disable_player_inputs(false)
	)


func set_dash(dash_attack: DashAttack, forward):
	dash_attack.global_position = player.global_position
	dash_attack.dash_hit_box_shape.shape.size = Vector2(dash_attack_width, dash_attack_range)
	dash_attack.global_position = player.global_position + forward * (dash_attack_range / 2.0)
	dash_attack.rotation = player.rotation
