class_name TrailLine
extends Line2D

var is_enabled: bool = true
var entity: Node2D
var previous_position: Vector2
var pivot_offset: Vector2
var length: int

func init(entity_node: Node2D,
offset: Vector2,
color: Color,
trail_length: int,
trail_width: int) -> void:
	entity = entity_node
	default_color = color
	pivot_offset = offset
	length = trail_length
	width = trail_width
	previous_position = entity_node.global_position


func _physics_process(_delta: float) -> void:
	if not is_enabled:
		if points.size() > 0:
			remove_point(0)
			if points.size() == 0:
				queue_free()
		return

	if not entity:
		return

	var pos = entity.global_position
	var angle = entity.global_rotation

	var forward = Vector2.RIGHT.rotated(angle)

	var right_vector = Vector2(forward.y, -forward.x).normalized()

	# Учитываем отражение по X
	if entity.scale.x < 0:
		right_vector = -right_vector

	var offset_position = pos + pivot_offset.x * right_vector + pivot_offset.y * forward

	add_point(offset_position)
	previous_position = pos

	if points.size() > length:
		remove_point(0)


func destroy() -> void:
	is_enabled = false
