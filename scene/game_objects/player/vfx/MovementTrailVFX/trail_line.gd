class_name TrailLine
extends Line2D

var is_enabled: bool = true
var entity: Node2D
var previous_position: Vector2
var pivot_offset: Vector2
var length: int

func init(entity_node: Node2D, offset: Vector2, color: Color, trail_length: int, trail_width: int) -> void:
	entity = entity_node
	default_color = color
	pivot_offset = offset
	length = trail_length
	width = trail_width
	previous_position = entity_node.global_position


func _physics_process(_delta: float) -> void:
	if not is_enabled:
		_fade_out()
		return

	if not entity:
		return

	var current_position = entity.global_position
	var angle = entity.global_rotation
	var forward = Vector2.RIGHT.rotated(angle)
	var right = Vector2(forward.y, -forward.x).normalized()

	# Учитываем отражение по X
	if entity.scale.x < 0:
		right = -right

	var trail_position = current_position + pivot_offset.x * right + pivot_offset.y * forward
	add_point(trail_position)
	previous_position = current_position

	if points.size() > length:
		remove_point(0)


func _fade_out() -> void:
	if points.size() > 1:
		remove_point(0)
		if points.size() == 1:
			queue_free()


func destroy() -> void:
	is_enabled = false