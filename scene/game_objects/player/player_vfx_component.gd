class_name PlayerVFXComponent

extends Node

@export var player_state_machine: StateMachine

@onready var dash_attack_vfx = \
preload("res://assets/artefacts/vfx/AstralStepVFX/dash_attack_vfx_astral_step.tscn")

func _ready() -> void:
	player_state_machine.machine_started.connect(_on_machine_started)


func _on_machine_started():
	var player_states = player_state_machine.states
	var dash_state = player_states["PlayerDashState"] as PlayerDashState
	dash_state.dash_started.connect(_on_dash_started)
	dash_state.dash_finished.connect(_on_dash_finished)
	var parry_state = player_states["PlayerParryState"] as PlayerParryState
	parry_state.parry_started.connect(_on_parry_started)
	parry_state.parry_finished.connect(_on_parry_finished)


func _on_dash_started(start_position: Vector2):
	pass


func _on_dash_finished(start_pos: Vector2, end_pos: Vector2):
	var dash_effect_instance = dash_attack_vfx.instantiate()
	get_tree().get_first_node_in_group("back_layer").add_child(dash_effect_instance)
	dash_effect_instance.setup(start_pos, end_pos)


func _on_parry_started():
	pass


func _on_parry_finished():
	pass


func _on_movement_started(position: Vector2):
	print(position)
