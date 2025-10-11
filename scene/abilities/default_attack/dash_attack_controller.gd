extends Node

@export var dash_attack_scene: PackedScene
@export var dash_attack_damage: float = 10.0
@export var dash_attack_range: float = 100.0
@export var damage_multiplier: float = 1.0
@export var attack_cd: float = 1.0
@export var dash_attack_width = 25

@onready var hurt_box_shape: CollisionShape2D = %HurtBoxShape
@onready var cooldown_timer = $CooldownTimer

#TODO можно дешнуться за карту - исправить
#решение 1 - кидать рейкаст и не давать нажать деш
#решение 2 - деш укорачивается до стены

func _process(delta):
	if Input.is_action_just_pressed("left_mouse_click"):
		activate_dash()

func activate_dash():
	if cooldown_timer.time_left > 0:
		return
		
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
		
	var dash_attack_instance = dash_attack_scene.instantiate() as DashAttack
	get_tree().get_first_node_in_group("front_layer").add_child(dash_attack_instance)
	dash_attack_instance.hit_box_component.damage = dash_attack_damage * damage_multiplier
	
	var forward := Vector2.UP.rotated(player.rotation)
	set_dash(dash_attack_instance, player, forward)
	
	hurt_box_shape.disabled = true
	#TODO посмотреть, не дохнут ли крипы до дэша, если дохнут до дэша - исправить тут
	var tween = create_tween()
	tween.tween_property(player, "global_position", player.global_position + forward * dash_attack_range, 0.2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(Callable(dash_attack_instance, "queue_free"))
	
	await tween.finished
	hurt_box_shape.disabled = false
	
	cooldown_timer.wait_time = attack_cd
	cooldown_timer.start()
	
func set_dash(dash_attack: DashAttack, player: Node2D, forward):
	dash_attack.global_position = player.global_position
	dash_attack.dash_hit_box_shape.shape.size = Vector2(dash_attack_width, dash_attack_range)
	dash_attack.global_position = player.global_position + forward * (dash_attack_range / 2.0)
	dash_attack.rotation = player.rotation
	
	
