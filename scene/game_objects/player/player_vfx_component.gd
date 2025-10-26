class_name PlayerVFXComponent

extends Node

@export var player_state_machine: StateMachine
var player_states: Dictionary
@onready var dash_attack_vfx = \
preload("res://assets/artefacts/vfx/AstralStepVFX/dash_attack_vfx_astral_step.tscn")

func _ready() -> void:
	player_state_machine.machine_started.connect(_on_machine_started)


func _on_machine_started():
	player_states = player_state_machine.states
	connect_dash_state()
	connect_parry_state()
	connect_movement_state()


func connect_dash_state():
	var dash_state = player_states["PlayerDashState"] as PlayerDashState
	dash_state.dash_started.connect(_on_dash_started)
	dash_state.dash_finished.connect(_on_dash_finished)


func connect_parry_state():
	var parry_state = player_states["PlayerParryState"] as PlayerParryState
	parry_state.parry_started.connect(_on_parry_started)
	parry_state.parry_finished.connect(_on_parry_finished)


func connect_movement_state():
	var movement_state = player_states["PlayerMovementState"] as PlayerMovementState
	movement_state.movement_started.connect(_on_movement_started)
	movement_state.movement_ended.connect(_on_movement_ended)


func _on_dash_started(_start_position: Vector2):
	pass


func _on_dash_finished(start_pos: Vector2, end_pos: Vector2):
	var dash_effect_instance = dash_attack_vfx.instantiate()
	get_tree().get_first_node_in_group("back_layer").add_child(dash_effect_instance)
	dash_effect_instance.setup(start_pos, end_pos)


func _on_parry_started():
	pass


func _on_parry_finished():
	pass


func _on_movement_started():
	pass


func _on_movement_ended():
	pass
