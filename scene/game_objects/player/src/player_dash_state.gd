class_name PlayerDashState

extends PlayerState

signal dash_started(start_pos: Vector2)
signal dash_finished(start_pos: Vector2, end_pos: Vector2)

static var state_name = "PlayerDashState"

var dash_timer: float = 0.0
var start_pos: Vector2
var end_pos: Vector2

func enter() -> void:
	_play_animation()
	player.player_attack_controller.start_cooldown()
	dash_timer = player.player_attack_controller.dash_duration \
	* player.player_attack_controller.dash_duration_multiplier
	player.player_attack_controller.activate_dash(player.dash_from_mouse)
	start_pos = player.player_attack_controller.get_start_pos()
	dash_started.emit(start_pos)


func process(delta: float):
	dash_timer -= delta
	if dash_timer <= 0.0:
		if player.is_stunned:
			player_state_machine.transition(PlayerStunState.state_name)
		elif player.movement_component.get_movement_vector().normalized() == Vector2.ZERO:
			player_state_machine.transition(PlayerIdleState.state_name)
		else:
			player_state_machine.transition(PlayerMovementState.state_name)


func exit() -> void:
	end_pos = player.player_attack_controller.get_end_pos()
	#end_pos = player.global_position
	dash_finished.emit(start_pos,end_pos)


func _play_animation():
	player.animated_sprite_2d.play("attack")
	player.animated_sprite_2d.speed_scale = 1/player.player_attack_controller\
	.dash_duration
	var tween2 = player.create_tween()
	tween2.tween_property(
		animated_sprite_2d,
		"scale",
		Vector2(0.25, 1),
		player.player_attack_controller.dash_duration,
	) \
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)

	tween2.finished.connect(
		func():
			var back_tween = player.create_tween()
			back_tween.tween_property(
				animated_sprite_2d,
				"scale",
				Vector2(1, 1),
				player.player_attack_controller.dash_duration / 2,
			) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			player.animated_sprite_2d.speed_scale = 1
	)


func get_state_name() -> String:
	return state_name
