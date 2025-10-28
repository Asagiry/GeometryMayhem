class_name EnemyMeleeMovementComponent

extends MovementComponent

@onready var effect_receiver: EffectReceiver = %EffectReceiver


func _ready() -> void:
	effect_receiver.stats_changed.connect(_on_stats_changed)


func move_to_player(mob: CharacterBody2D):
	var direction = get_direction()
	mob.velocity = accelerate_to_direction(direction)
	mob.move_and_slide()


func get_direction():
	var mob = owner as Node2D
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		return (player.global_position - mob.global_position).normalized()
	return Vector2.ZERO


func _on_stats_changed(updated_stats: Dictionary):
	if updated_stats.has("speed_multiplier"):
		speed_multiplier = updated_stats["speed_multiplier"]
