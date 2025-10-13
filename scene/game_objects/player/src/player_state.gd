class_name PlayerState 

extends State

var player: PlayerController
var animated_sprite_2d: AnimatedSprite2D
var main_state_machine: StateMachine


func _init(player_controller: PlayerController) -> void:
	player = player_controller
	animated_sprite_2d = player.animated_sprite_2d
	main_state_machine = player.main_state_machine
