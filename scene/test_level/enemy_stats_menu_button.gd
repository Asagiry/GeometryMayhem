extends MenuButton

var stats: EnemyStatData
var original_stats: EnemyStatData
var enemy_stats: EnemyStatData
var selected_enemy

var vbox: VBoxContainer
var window: Window
var apply_button: Button
var reset_button: Button
var window_cleared: bool = false

var enemy_original_stats: Dictionary = {}
var pending_changes: Dictionary = {}

var field_groups = {
	"HP": ["max_health", "armor"],
	"Movement": ["max_speed", "acceleration", "rotation_speed"],
	"Attack": ["attack_damage_amount", "attack_cd", "attack_duration", "attack_range"],
	"Currency": ["knowledge_count", "echo_chance", "echo_count", "impulse_count"],
	"Area Range": ["aggro_range", "attack_range_zone"],
	"Range Enemy": ["projectile_speed", "chance_to_additional_projectile"],
	"Bomb Enemy": ["explosion_delay"],
}


func init():
	create_window()
	setup_ui()
	get_popup().hide()
	pressed.connect(_on_pressed)


func create_window():
	if has_node("StatEditorWindow"):
		return

	window = Window.new()
	window.name = "StatEditorWindow"
	window.borderless = true
	window.size = Vector2(500, 600)  # Увеличили высоту для кнопок
	window.visible = false
	window.unresizable = true
	window.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	add_child(window)


func setup_ui():
	var main_container = VBoxContainer.new()
	main_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_theme_constant_override("separation", 10)
	window.add_child(main_container)

	var scroll_container = ScrollContainer.new()
	scroll_container.custom_minimum_size = Vector2(480, 500)  # Фиксированная высота для скролла
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(scroll_container)

	vbox = VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(vbox)

	for group_name in field_groups:
		var group_label = Label.new()
		group_label.text = group_name
		group_label.add_theme_font_size_override("font_size", 14)
		group_label.add_theme_color_override("font_color", Color.YELLOW)
		vbox.add_child(group_label)

		for field_name in field_groups[group_name]:
			var hbox = HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			vbox.add_child(hbox)

			var label = Label.new()
			label.text = _format_field_name(field_name)
			label.custom_minimum_size.x = 250
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(label)

			var line_edit = LineEdit.new()
			line_edit.text = str(stats.get_stat(field_name))
			line_edit.custom_minimum_size.x = 150
			line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			line_edit.connect("text_submitted", _on_value_changed.bind(field_name))
			line_edit.connect("text_changed", _on_value_text_changed.bind(field_name))
			hbox.add_child(line_edit)

	var button_container = HBoxContainer.new()
	button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_container.add_theme_constant_override("separation", 10)
	main_container.add_child(button_container)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_container.add_child(spacer)

	apply_button = Button.new()
	apply_button.text = "Apply Changes"
	apply_button.custom_minimum_size.x = 120
	apply_button.connect("pressed", _on_apply_button_pressed)
	button_container.add_child(apply_button)

	reset_button = Button.new()
	reset_button.text = "Reset to Default"
	reset_button.custom_minimum_size.x = 120
	reset_button.connect("pressed", _on_reset_button_pressed)
	button_container.add_child(reset_button)


func set_stats(p_stats: EnemyStatData, p_enemy = null):
	if !p_stats:
		clear_ui()
		return

	if p_enemy and is_instance_valid(p_enemy):
		selected_enemy = p_enemy
		if p_enemy not in enemy_original_stats:
			enemy_original_stats[p_enemy] = p_stats.duplicate(true)

	enemy_stats = p_stats
	stats = p_stats.duplicate(true)
	pending_changes.clear()

	if has_node("StatEditorWindow"):
		if window_cleared:
			setup_ui()
			window_cleared = false
		update_ui()
	else:
		init()

	for enemy in enemy_original_stats.keys():
		if not is_instance_valid(enemy):
			enemy_original_stats.erase(enemy)


func update_ui():
	if not vbox:
		return

	var child_index = 0
	for group_name in field_groups:
		child_index += 1  # Пропускаем заголовок группы
		for field_name in field_groups[group_name]:
			if child_index < vbox.get_child_count():
				var hbox = vbox.get_child(child_index)
				if hbox is HBoxContainer:
					for child in hbox.get_children():
						if child is LineEdit:
							if field_name in pending_changes:
								child.text = str(pending_changes[field_name])
							else:
								child.text = str(stats.get_stat(field_name))
							break
				child_index += 1


func clear_ui():
	window_cleared = true
	for element in window.get_children():
		element.queue_free()


func _format_field_name(field_name: String) -> String:
	var formatted = field_name.replace("_", " ").capitalize()
	if formatted.contains("cd"):
		formatted = formatted.replace("cd", "CD")
	if formatted.contains("hp"):
		formatted = formatted.replace("hp", "HP")
	return formatted


func _on_pressed():
	if window.visible:
		window.hide()
	else:
		window.position = global_position + Vector2(0, size.y)
		window.show()


func _on_value_text_changed(new_text: String, field_name: String):
	if new_text.is_valid_float() or new_text.is_valid_int():
		var value = float(new_text)
		pending_changes[field_name] = value
		print("Pending change for ", field_name, ": ", value)


func _on_value_changed(new_text: String, field_name: String):
	_on_value_text_changed(new_text, field_name)


func _on_apply_button_pressed():
	for field_name in pending_changes:
		var value = pending_changes[field_name]
		enemy_stats.set_stat(field_name, value)
		stats.set_stat(field_name, value)
		print("Applied change to enemy: ", field_name, " = ", value)

	pending_changes.clear()

	update_ui()

	print("All changes applied directly to enemy stats")


func _on_reset_button_pressed():
	if not selected_enemy or not is_instance_valid(selected_enemy):
		push_warning("Enemy is not selected, select enemy first.")
		return

	if selected_enemy not in enemy_original_stats:
		push_warning(
			"Selected enemy: ",
			selected_enemy,
			""" does not have saved original stats.
			No enemy_original_stats[selected_enemy] available for reset!""")
		return

	var selected_enemy_original_stats: EnemyStatData = enemy_original_stats[selected_enemy]
	for group_name in field_groups:
		for field_name in field_groups[group_name]:
			var original_value = selected_enemy_original_stats.get_stat(field_name)
			enemy_stats.set_stat(field_name, original_value)
			stats.set_stat(field_name, original_value)

		pending_changes.clear()

		update_ui()

		print("Reset enemy stats to original values")
