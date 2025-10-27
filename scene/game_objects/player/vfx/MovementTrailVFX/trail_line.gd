class_name TrailLine

extends Line2D

var is_enabled: bool = true
var entity : Node2D
var previous_position: Vector2
var pivot_offset: Vector2
var length: int

func init(entityNode:Node2D,
offset: Vector2,
color: Color,
trail_length: int,
trail_width: int):
	entity = entityNode
	default_color = color
	pivot_offset = offset
	length = trail_length
	width = trail_width
	previous_position = entityNode.global_position

func _physics_process(delta: float) -> void:
	if (is_enabled):
		var current_position = entity.global_position
		var direction = (current_position - previous_position).normalized()

		var right_vector = Vector2(direction.y, -direction.x)
		var offset_position = current_position - (pivot_offset.y * direction)\
		 + (pivot_offset.x * right_vector)

		add_point(offset_position)
		previous_position = current_position
		if (points.size() > length):
			remove_point(0)
	else:
		remove_point(0)
		if (points.size()==0):
			queue_free()

func destroy():
	is_enabled = false
