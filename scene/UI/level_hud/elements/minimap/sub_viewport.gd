extends SubViewport

var player: PlayerController
@onready var camera_2d: Camera2D = %Camera2D

func _ready():
	world_2d = get_tree().root.world_2d
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	camera_2d.position = player.position
