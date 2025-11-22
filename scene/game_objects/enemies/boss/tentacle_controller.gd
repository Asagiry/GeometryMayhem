class_name TentacleController

extends Node

var alive_tentacles: int = 4

@onready var boss_hurt_box: HurtBox = %HurtBox
@onready var environment_collision: CollisionShape2D = %EnvironmentCollision
@onready var tentacles: Array[Tentacle] = [
	%Tentacle,
	%Tentacle2,
	%Tentacle3,
	%Tentacle4
]

func _ready() -> void:
	_set_tentacles()
	boss_hurt_box.set_deferred("monitoring", false)
	boss_hurt_box.set_deferred("monitorable", false)


func _set_tentacles():
	for tentacle in tentacles:
		tentacle.tentacle_died.connect(_on_tentacle_died)
		tentacle.tentacle_health_changed.connect(_on_tentacle_health_changed)
	tentacles.sort_custom(func(a, b): return a.id < b.id)


func _delete_died_tentacles(tentacle_id):
	for tentacle in tentacles:
		if tentacle.id == tentacle_id:
			tentacles.erase(tentacle)
			tentacle.queue_free()
			alive_tentacles -= 1
			break


func _on_tentacle_health_changed(current_health, max_health, tentacle_id: int):
	print(
		"TENTACLE ID = ", tentacle_id,
		" HP = ", current_health,
		" MAX_HP = ", max_health
	)

func _on_tentacle_died(tentacle_id: int):
	_delete_died_tentacles(tentacle_id)
	#STATE MACHINE?
	if tentacles.size() == 0:
		boss_hurt_box.set_deferred("monitoring", true)
		boss_hurt_box.set_deferred("monitorable", true)
