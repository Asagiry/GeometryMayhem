extends Node

@export var dash_attack_scene: PackedScene
@export var dash_attack_damage: float = 10.0
@export var dash_attack_range: float = 100.0
@export var damage_multiplier: float = 1.0
@export var attack_cd: float = 1.0 + 0.2
@export var dash_attack_width = 25

@onready var hurt_box_shape: CollisionShape2D = %HurtBoxShape
@onready var cooldown_timer = $CooldownTimer

#TODO можно дешнуться за карту - исправить(AI)
#решение 1 - кидать рейкаст и не давать нажать деш
#решение 2 - деш укорачивается до стены


func _process(delta):
	if Input.is_action_just_pressed("left_mouse_click"):
		activate_dash()


func activate_dash():
	if !cooldown_timer.is_stopped():
		return

	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var dash_attack_instance = dash_attack_scene.instantiate() as DashAttack
	get_tree().get_first_node_in_group("front_layer").add_child(dash_attack_instance)
	dash_attack_instance.hit_box_component.damage = dash_attack_damage * damage_multiplier

	var forward := Vector2.UP.rotated(player.rotation)
	set_dash(dash_attack_instance, player, forward)

	disable_player_hurt_box(true)

	cooldown_timer.wait_time = attack_cd
	cooldown_timer.start()

	start_dash_tween(player, player.global_position + forward * dash_attack_range, dash_attack_instance)


func disable_player_hurt_box(disable: bool):
	hurt_box_shape.disabled = disable


#TODO посмотреть, не дохнут ли крипы до дэша, если дохнут до дэша - исправить тут(AI)
func start_dash_tween(player: Node2D, target_position, dash_attack_instance: DashAttack):
	var tween = create_tween()
	tween.tween_property(player, "global_position", target_position, 0.2) \
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(Callable(dash_attack_instance, "queue_free"))
	tween.finished.connect(func(): disable_player_hurt_box(false))


func set_dash(dash_attack: DashAttack, player: Node2D, forward):
	dash_attack.global_position = player.global_position
	dash_attack.dash_hit_box_shape.shape.size = Vector2(dash_attack_width, dash_attack_range)
	dash_attack.global_position = player.global_position + forward * (dash_attack_range / 2.0)
	dash_attack.rotation = player.rotation
