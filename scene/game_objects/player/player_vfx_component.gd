class_name PlayerVFXComponent

extends Node

@export var player_state_machine: StateMachine
@export var trail_color: Color
@export var trail_width: int

var player_states: Dictionary
var player: PlayerController

var right_trail: TrailLine
var left_trail: TrailLine

@onready var dash_attack_vfx = \
preload("res://assets/artefacts/vfx/AstralStepVFX/dash_attack_vfx_astral_step.tscn")
@onready var trail_line_scene = \
preload("res://scene/game_objects/player/vfx/MovementTrailVFX/trail_line.tscn")

func _ready() -> void:
	player_state_machine.machine_started.connect(_on_machine_started)
	player = player_state_machine.get_parent()
	await player.ready
	await get_tree().process_frame


func _on_machine_started():
	player_states = player_state_machine.states
	connect_dash_state()
	connect_parry_state()
	connect_movement_state()


func connect_dash_state():
	var dash_state = player_states["PlayerAttackState"] as PlayerAttackState
	dash_state.dash_started.connect(_on_dash_started)
	dash_state.dash_finished.connect(_on_dash_finished)


func connect_parry_state():
	var parry_state = player_states["PlayerParryState"] as PlayerParryState
	parry_state.parry_started.connect(_on_parry_started)
	parry_state.parry_finished.connect(_on_parry_finished)


func connect_movement_state():
	var movement_state = player_states["PlayerMovementState"] as PlayerMovementState
	movement_state.movement_started.connect(_on_movement_started)
	movement_state.movement_ended.connect(_on_movement_finished)

func connect_stun_state():
	var stun_state = player_states["PlayerStunState"] as PlayerStunState
	stun_state.stun_started.connect(_on_stun_started)
	stun_state.stun_finished.connect(_on_stun_finished)

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
	var trail_length = player.movement_component.max_speed * 0.2

	left_trail = trail_line_scene.instantiate() as TrailLine
	left_trail.init(player, Vector2(-16, -10), trail_color, trail_length, trail_width)
	get_tree().get_first_node_in_group("back_layer").call_deferred("add_child", left_trail)

	right_trail = trail_line_scene.instantiate() as TrailLine
	right_trail.init(player, Vector2(-16, 10), trail_color, trail_length, trail_width)
	get_tree().get_first_node_in_group("back_layer").call_deferred("add_child", right_trail)

func _on_movement_finished():
	left_trail.destroy()
	right_trail.destroy()


func _on_stun_started():
	pass


func _on_stun_finished():
	pass
