class_name EnemyBombController

extends EnemyController


func _connect_signals():
	super._connect_signals()
	attack_controller.attack_finished.connect(_on_attack_finished)


func _on_attack_finished():
	queue_free()
