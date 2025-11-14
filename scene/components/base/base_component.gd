class_name BaseComponent

extends Node

var owner_stats
var owner_node: Node2D
var stat_subscriptions: Dictionary = {}

func _ready():
	_setup_owner_reference()
	_setup_stat_subscriptions()


func _setup_owner_reference():
	owner_node = get_owner()
	if not owner_node:
		push_error("Component has no owner: ", name)
		return

	if owner_node.has_method("get_stats"):
		owner_stats = owner_node.get_stats()
		if !owner_stats:
			push_error("Owner Node: ", owner_node, " has not stats(stats is NULL)")
	else:
		push_warning("Owner doesn't have get_stats method: ", owner_node.name)
		return

	if owner_stats and owner_stats.has_signal("stat_changed"):
		owner_stats.stat_changed.connect(_on_owner_stat_changed)


func _owner_has_property(property: String) -> bool:
	return owner_node.get(property) != null


func _setup_stat_subscriptions():
	pass


func _on_owner_stat_changed(stat_name: String, old_value, new_value):
	if stat_name in stat_subscriptions:
		stat_subscriptions[stat_name].call(new_value, old_value)


func subscribe_to_stat(stat_name: String, callback: Callable):
	stat_subscriptions[stat_name] = callback


func get_stat(stat_name: String, default = null):
	if owner_stats and _stat_exists(stat_name):
		return owner_stats.get(stat_name)
	return default


func _stat_exists(stat_name: String) -> bool:
	if not owner_stats:
		return false
	var value = owner_stats.get(stat_name)
	return value != null
