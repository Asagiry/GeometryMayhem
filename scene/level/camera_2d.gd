extends Camera2D

@onready var player = %Player as Node2D


func _physics_process(_delta):
	if player == null:
		return
	global_position = player.global_position

func set_target(target: PlayerController):
	player = target
