class_name EnemyLootComponent

extends Node

var knowledge_count: float
var echo_chance: float
var echo_count: int
var impulse_count: float

func _init(p_knowledge_count: float = 0.0,
p_echo_chance: float = 0.0,
p_echo_count: int = 0,
p_impulse_count: float = 0.0):
	knowledge_count = p_knowledge_count
	echo_chance = p_echo_chance
	echo_count = p_echo_count
	impulse_count = p_impulse_count
