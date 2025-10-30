class_name PlayerState

extends State

const MOVEMENT_ACTIONS = ["move_down","move_up","move_left","move_right"]
const ATTACK_ACTIONS = ["left_mouse_click_attack","shift_attack"]
const PARRY_ACTIONS = ["right_mouse_click_parry","space_parry"]

const ALLOWED_ACTIONS = MOVEMENT_ACTIONS+ATTACK_ACTIONS+PARRY_ACTIONS

var player: PlayerController
var animated_sprite_2d: PlayerAnimatedSprite2D
var attack_controller: PlayerAttackController
var parry_controller: ParryController
var state_machine: StateMachine
var effect_receiver : EffectReceiver


func _init(player_controller: PlayerController) -> void:
	player = player_controller
	animated_sprite_2d = player.animated_sprite_2d as PlayerAnimatedSprite2D
	state_machine = player.state_machine
	attack_controller = player.attack_controller
	parry_controller = player.parry_controller
	effect_receiver = player.effect_receiver
	effect_receiver.stun_applied.connect(_on_stun_applied)


func _on_stun_applied(duration: float):
	state_machine.states["PlayerStunState"].set_duration(duration)


func input(_event: InputEvent) -> void:
	var is_allowed = false
	for action in ALLOWED_ACTIONS:
		if _event.is_action(action):
			is_allowed = true
			break

	if not is_allowed:
		player.get_viewport().set_input_as_handled()
		return

	handle_input(_event)


func handle_input(_event: InputEvent):
	pass


func is_no_input_pressed() -> bool:
	# Проверяем все разрешенные действия
	for action in ALLOWED_ACTIONS:
		if Input.is_action_pressed(action):
			return false  # Если хоть одна кнопка нажата - возвращаем false
	return true  # Все кнопки отпущены


func is_input_attack(_event: InputEvent):
	if (_event!=null):
		for action in ATTACK_ACTIONS:
			if _event.is_action_pressed(action):
				return true
	return false


func is_input_movement(_event: InputEvent):
	if (_event!=null):
		for action in MOVEMENT_ACTIONS:
			if _event.is_action_pressed(action):
				return true
	return false


func is_input_parry(_event: InputEvent):
	if (_event!=null):
		for action in PARRY_ACTIONS:
			if _event.is_action_pressed(action):
				return true
	return false


func safe_connect(signal_obj: Signal, callable: Callable):
	if not signal_obj.is_connected(callable):
		signal_obj.connect(callable)
