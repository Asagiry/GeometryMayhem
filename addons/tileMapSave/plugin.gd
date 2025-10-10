@tool
extends EditorPlugin

var export_button: Button = null

func _enter_tree():
	if export_button == null:
		export_button = Button.new()
		export_button.text = "Export Full TileMap PNG"
		export_button.pressed.connect(_on_export_pressed)
		add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, export_button)

func _exit_tree():
	if export_button:
		remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, export_button)
		export_button.queue_free()
		export_button = null

func _on_export_pressed():
	var selection = get_editor_interface().get_selection()
	var selected_nodes = selection.get_selected_nodes()
	for node in selected_nodes:
		if node is Node2D:
			_export_tilemap_via_viewport(node)

func _get_all_tilemap_layers(root: Node) -> Array:
	var layers: Array = []
	for child in root.get_children():
		if child is TileMapLayer:
			layers.append(child)
		elif child.get_child_count() > 0:
			layers += _get_all_tilemap_layers(child)
	return layers

func _get_tilemap_bounds(layers: Array) -> Rect2:
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	for layer in layers:
		var size = layer.tile_set.tile_size
		for cell in layer.get_used_cells():
			var x = cell.x * size.x
			var y = cell.y * size.y
			min_x = min(min_x, x)
			min_y = min(min_y, y)
			max_x = max(max_x, x + size.x)
			max_y = max(max_y, y + size.y)
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func _export_tilemap_via_viewport(root: Node2D):
	var layers = _get_all_tilemap_layers(root)
	if layers.size() == 0:
		return
	var bounds = _get_tilemap_bounds(layers)
	var img_size = bounds.size
	var sub_vp = SubViewport.new()
	sub_vp.size = img_size
	sub_vp.transparent_bg = true
	sub_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var container = Node2D.new()
	container.position = -bounds.position
	sub_vp.add_child(container)
	for layer in layers:
		var copy = layer.duplicate()
		container.add_child(copy)
	var cam = Camera2D.new()
	cam.position = Vector2.ZERO
	container.add_child(cam)
	call_deferred("_activate_camera", cam)
	root.get_tree().get_root().add_child(sub_vp)
	await get_tree().process_frame
	await get_tree().process_frame
	var img = sub_vp.get_texture().get_image()
	img.flip_y()
	var path = "res://exported_map.png"
	img.save_png(path)
	sub_vp.queue_free()

func _activate_camera(cam: Camera2D):
	cam.make_current()
