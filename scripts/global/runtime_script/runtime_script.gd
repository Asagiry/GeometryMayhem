class_name RuntimeScript

extends Node

var artefacts: Array[ArtefactData] = []
var killed_creeps: int = 0
var number_of_dashes: int = 0
var number_of_sucessfull_parry: int = 0

func _ready() -> void:
	Global.player_successful_dash.connect(_on_dash_is_completed)
	Global.player_successful_parry.connect(_on_parry_is_completed)
	Global.enemy_died.connect(_on_creep_is_killed)

func _on_dash_is_completed():
	number_of_dashes += 1


func _on_parry_is_completed():
	number_of_sucessfull_parry += 1


func _on_creep_is_killed(_stats):
	killed_creeps += 1


func _on_artefact_is_given(artefact: ArtefactData):
	artefacts.append(artefact)
