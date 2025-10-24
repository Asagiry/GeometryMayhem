class_name EnemyMeleeMovementComponent

extends MovementComponent

@onready var effect_receiver: EffectReceiver = %EffectReceiver


func _ready() -> void:
	effect_receiver.effect_ended.connect(_on_effect_ended)


func move_to_player(mob: CharacterBody2D):
	var direction = get_direction()
	speed_multiplier = effect_receiver.speed_multiplier
	mob.velocity = accelerate_to_direction(direction)
	mob.move_and_slide()


func get_direction():
	var mob = owner as Node2D
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		return (player.global_position - mob.global_position).normalized()
	return Vector2.ZERO


func _on_effect_ended(effect_type: Util.EffectType):
	if effect_type == Util.EffectType.SLOW:
		speed_multiplier = DEFAULT_SPEED_MULTIPLIER
