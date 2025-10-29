class_name EnemyLootComponent

extends Node

var knowledge_count: float
var echo_chance: float
var echo_count: int
var impulse_count: float

func _ready():
	knowledge_count = owner.stats.knowledge_count
	echo_chance = owner.stats.echo_chance
	echo_count = owner.stats.echo_count
	impulse_count = owner.stats.impulse_count
