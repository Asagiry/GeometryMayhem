class_name PlayerAttackController

#region variables
extends OwnerAwareComponent

signal attack_started
signal attack_finished
signal attack_cd_timeout

@export var dash_attack_scene: PackedScene

var damage_data: DamageData

var is_dash_from_mouse: bool = false
var player: PlayerController
var is_on_cooldown: bool
var is_range_enable: bool = true

var dash_duration_multiplier: float = 1.0
var damage_multiplier: float = 1.0
var attack_cd_multiplier: float = 1.0
var attack_range_multiplier: float = 1.0

var _distance: float
var _direction: Vector2
var _dash_circle: DashCircle
var _start_pos: Vector2
var _end_pos: Vector2

@onready var player_hurt_box: HurtBox = %PlayerHurtBox
@onready var cooldown_timer: Timer = %CooldownTimer
#endregion variables


func _ready():
	_connect_signals()
	super._ready()  # Вызовет _setup_owner_reference() и _setup_stat_subscriptions()
	_setup_dash_circle()


func _setup_owner_reference():
	super._setup_owner_reference()

	# Получаем player из owner
	if owner_node is PlayerController:
		player = owner_node
	else:
		player = get_tree().get_first_node_in_group("player") as PlayerController

	# Инициализируем damage_data
	if player and player.stats:
		damage_data = player.stats.attack_damage
		print("Damage data инициализирована: ", damage_data)


func _setup_stat_subscriptions():
	subscribe_to_stat("attack_range", _on_attack_range_changed)


func _connect_signals():
	if player and player.effect_receiver:
		player.effect_receiver.attack_component_effects_changed.connect(_on_effect_stats_changed)


func _setup_dash_circle():
	_dash_circle = preload("res://scene/game_objects/player/dash_circle.tscn")\
	.instantiate() as DashCircle
	player.add_child.call_deferred(_dash_circle)
	enable_range(is_range_enable)


func get_start_pos()-> Vector2:
	return _start_pos


func get_end_pos()-> Vector2:
	return _end_pos


func enable_range(enable: bool):
	if (enable):
		_dash_circle.set_range(get_dash_range())
		_dash_circle.show_dash_range()
	else:
		_dash_circle.hide_dash_range()


func activate_dash(input_state: bool):

	_start_pos = player.global_position
	attack_started.emit()

	var dash_attack_instance = _create_dash_instance()
	_set_damage(dash_attack_instance)

	_disable_player_hurt_box(true)



	is_dash_from_mouse = input_state
	if is_dash_from_mouse:
		_activate_mouse_click_dash(dash_attack_instance)
	else:
		_activate_keyboard_dash(dash_attack_instance)


func _create_dash_instance():
	var dash_attack_instance = dash_attack_scene.instantiate() as DashAttack
	get_tree().get_first_node_in_group("front_layer").add_child(dash_attack_instance)
	return dash_attack_instance


func _set_damage(dash_attack_instance: DashAttack):
	damage_data.amount *= damage_multiplier
	dash_attack_instance.hit_box_component.damage_data = damage_data


func _disable_player_hurt_box(disable: bool):
	player_hurt_box.hurt_box_shape.disabled = disable


func _activate_mouse_click_dash(dash_attack_instance):
	_set_end_pos_from_mouse()
	_rotate_player_to_dash()
	_start_dash_tween(dash_attack_instance)


func _set_end_pos_from_mouse():
	var dash_range = get_dash_range()
	_end_pos = player.get_global_mouse_position()
	var direction = _end_pos - player.global_position
	var distance = direction.length()
	if distance > dash_range:
		_end_pos = player.global_position + direction.normalized() * dash_range
		distance = dash_range


func _rotate_player_to_dash():
	var direction = (_end_pos - player.global_position).normalized()
	player.rotation = direction.angle() + PI / 2


func _activate_keyboard_dash(dash_attack_instance):
	_set_end_pos_from_keyboard()
	_start_dash_tween(dash_attack_instance)


func _set_end_pos_from_keyboard():
	var forward = Vector2.UP.rotated(player.rotation)
	_end_pos = player.global_position + forward * get_dash_range()


func _start_dash_tween(dash_attack_instance: DashAttack):
	_set_final_end_pos()
	_direction = player.global_position.direction_to(_end_pos)
	_distance = player.global_position.distance_to(_end_pos)
	var tween = create_tween()
	var dash_duration = get_duration()
	tween.tween_property(player, "global_position", _end_pos, \
	dash_duration) \
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

	var dash_width = get_dash_width()
	var start_size = Vector2(dash_width, 0)
	var end_size = Vector2(dash_width, _distance)
	dash_attack_instance.dash_hit_box_shape.shape.size = start_size
	dash_attack_instance.rotation = player.rotation

	tween.parallel().tween_method(
		func(size_value: Vector2):
			var safe_size = Vector2(max(0, size_value.x), max(0, size_value.y))
			dash_attack_instance.dash_hit_box_shape.shape.size = safe_size
			dash_attack_instance.global_position = _start_pos + _direction \
			* (size_value.y / 2.0),
		start_size,
		end_size,
		dash_duration
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

	tween.tween_callback(Callable(dash_attack_instance, "queue_free"))
	tween.finished.connect(func():
		_disable_player_hurt_box(false)
		attack_finished.emit()
		start_cooldown()
	)

#Проверка на столкновение со стенами и пересчёт если столкнулись
func _set_final_end_pos():
	var test_body = CharacterBody2D.new()
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2(10, 10) # Размер коллайдера игрока
	test_body.add_child(collision_shape)
	test_body.global_position = player.global_position
	test_body.collision_mask = 1 << 0 # Environment слой
	add_child(test_body)
	var direction = player.global_position.direction_to(_end_pos)
	var distance = player.global_position.distance_to(_end_pos)
	var collision = test_body.move_and_collide(direction * distance)

	if collision:
		_end_pos = player.global_position + direction * \
		(collision.get_travel().length() - 10)
	test_body.queue_free()


func start_cooldown():
	cooldown_timer.start(get_cooldown())


func _on_cooldown_timer_timeout() -> void:
	attack_cd_timeout.emit()


func _on_effect_stats_changed(updated_stats) -> void:
	if updated_stats.has("attack_duration_multiplier"):
		dash_duration_multiplier = updated_stats["attack_duration_multiplier"]
	if updated_stats.has("attack_multiplier"):
		damage_multiplier = updated_stats["attack_multiplier"]
	if updated_stats.has("attack_cd_multiplier"):
		attack_cd_multiplier = updated_stats["attack_cd_multiplier"]
	if updated_stats.has("attack_range_multiplier"):
		attack_range_multiplier = updated_stats["attack_range_multiplier"]


func _on_attack_range_changed(new_range: float, old_range: float):
	print("Attack range changed: ", old_range, " -> ", new_range)
	if _dash_circle and is_range_enable:
		_dash_circle.set_range(new_range)


func get_dash_width() -> float:
	return get_stat("attack_width")


func get_attack_damage() -> DamageData:
	return get_stat("attack_damage") * damage_multiplier


func get_duration() -> float:
	return get_stat("attack_duration") * dash_duration_multiplier


func get_dash_range() -> float:
	return get_stat("attack_range")


func get_cooldown() -> float:
	return get_stat("attack_cd") * attack_cd_multiplier
