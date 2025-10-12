extends Camera2D

@onready var player = %Player as Node2D


func _process(_delta):
	if player == null:
		return
	global_position = player.global_position
