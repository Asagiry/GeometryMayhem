class_name CircularContainer

extends Container

var process_angle = 0

func _process(delta:float):
	process_angle+=delta*3

	_sort_children()

func _notification(what):
	match what:
		NOTIFICATION_SORT_CHILDREN:
			_sort_children()

func _sort_children():
	var children := []
	for child in get_children():
		if child.visible and child is Control:
			children.append(child)

	var count := children.size()
	if count == 0:
		return

	var rect_size = get_rect().size
	var center = rect_size / 2
	var radius = min(rect_size.x/2,rect_size.y/2)-50

	for i in range(count):
		var child: Control = children[i]
		var angle_deg = 360.0 / count * i + process_angle
		var angle_rad = deg_to_rad(angle_deg)
		var pos = center + Vector2(cos(angle_rad), sin(angle_rad)) * radius
		var child_size = child.get_combined_minimum_size()
		child.position = pos - child_size / 2  # центрируем элемент
