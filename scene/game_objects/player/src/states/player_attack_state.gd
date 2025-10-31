class_name PlayerAttackState

extends PlayerState

signal dash_started(start_pos: Vector2)
signal dash_finished(start_pos: Vector2, end_pos: Vector2)

static var state_name = "PlayerAttackState"

var start_pos: Vector2
var end_pos: Vector2
var input_from_mouse: bool

var on_cooldown: bool = false

func set_input(event: InputEvent):
	input_from_mouse = event.is_action_pressed("left_mouse_click_attack")


func _init(player_controller: PlayerController) -> void:
	super(player_controller)
	attack_controller.attack_started.connect(_on_attack_started)
	attack_controller.attack_finished.connect(_on_attack_finished)
	attack_controller.attack_cd_timeout.connect(_on_attack_cd_timeout)


func enter() -> void:
	on_cooldown = true

	attack_controller.activate_dash(input_from_mouse)

	dash_started.emit(start_pos)



func _on_attack_started():
	_play_animation()
	start_pos = player.attack_controller.get_start_pos()


func _on_attack_finished():
	if player.is_stunned:
		state_machine.transition(PlayerStunState.state_name)
	else:
		state_machine.transition(PlayerMovementState.state_name)


func _on_attack_cd_timeout():
	on_cooldown = false


func exit() -> void:
	end_pos = player.attack_controller.get_end_pos()
	dash_finished.emit(start_pos,end_pos)

func _play_animation():
	animated_sprite_2d.play_attack_animation()


func get_state_name() -> String:
	return state_name
