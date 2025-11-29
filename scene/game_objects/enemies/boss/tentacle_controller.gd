class_name TentacleController

extends Node

signal tentacle_health_changed(current_health, max_health, tentacle_id)
signal tentacle_died

var alive_tentacles: int = 4

@onready var environment_collision: CollisionShape2D = %EnvironmentCollision
@onready var tentacles: Array[Tentacle] = [
	%Tentacle,
	%Tentacle2,
	%Tentacle3,
	%Tentacle4
]

func _ready() -> void:
	_set_tentacles()


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
	tentacle_health_changed.emit(current_health, max_health, tentacle_id)

func _on_tentacle_died(tentacle_id: int):
	_delete_died_tentacles(tentacle_id)
	tentacle_died.emit()
