class_name BaseBossAttackController

extends Node

signal attack_started
signal attack_finished
signal attack_cd_timeout

@export var attack_scene: PackedScene


func activate_attack():
	pass


func _create_attack_instance():
	pass


func _setup_attack_instance(_attack_instance) -> void:
	pass


func _wait_for_attack_completion(_attack_instance):
	pass


func _get_direction_to_player():
	return (_get_player_position() - owner.global_position).normalized()


func _get_player_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		return player.global_position
	return Vector2.ZERO


func _stop_movement():
	var boss = get_tree().get_first_node_in_group("boss")
	if boss and boss.movement_component:
		boss.movement_component.set_speed_multiplier(0.0)
		boss.movement_component.stop()


func _start_movement():
	var boss = get_tree().get_first_node_in_group("boss")
	if boss and boss.movement_component:
		boss.movement_component.set_speed_multiplier(1.0)
