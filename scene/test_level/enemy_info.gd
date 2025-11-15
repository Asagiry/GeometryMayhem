class_name EnemyInfo
extends PanelContainer

signal enemy_info_clicked(enemy_info: EnemyInfo)

var enemy_link
var is_selected: bool = false
var effect_timers: Dictionary = {}

@onready var cur_hp_label: Label = %CurHPLabel
@onready var max_hp_label: Label = %MaxHPLabel
@onready var enemy_infusion_container: FlowContainer = %EnemyInfusionContainer
@onready var enemy_effects_container: FlowContainer = %EnemyEffectsContainer
@onready var name_label: Label = %NameLabel


func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	gui_input.connect(_on_gui_input)
	deselect()


func handle_effect_ui(effect_type: Util.EffectType, duration: float, behavior: Util.EffectBehavior):
	match behavior:
		Util.EffectBehavior.SPECIAL:
			if not has_effect_panel(effect_type):
				add_effect_imanaginable(effect_type, duration)
		Util.EffectBehavior.INSTANT:
			add_effect_imanaginable(effect_type, duration)
		Util.EffectBehavior.DOT, Util.EffectBehavior.BUFF, Util.EffectBehavior.DEBUFF:
			remove_effect_panel(effect_type)
			add_effect_imanaginable(effect_type, duration)


func has_effect_panel(effect_type: Util.EffectType) -> bool:
	for panel in effect_timers:
		if is_instance_valid(panel):
			var hbox = panel.get_child(0)
			if hbox and hbox.get_child_count() > 1:
				var label = hbox.get_child(1) as Label
				if label and Util.get_effect_name(effect_type) in label.text:
					return true
	return false


func remove_effect_panel(effect_type: Util.EffectType):
	for panel in effect_timers:
		if is_instance_valid(panel):
			var hbox = panel.get_child(0)
			if hbox and hbox.get_child_count() > 1:
				var label = hbox.get_child(1) as Label
				if label and Util.get_effect_name(effect_type) in label.text:
					# Удаляем таймеры и панель
					var timers = effect_timers.get(panel)
					if timers:
						timers[0].stop()
						timers[1].stop()
						timers[0].queue_free()
						timers[1].queue_free()
					panel.queue_free()
					effect_timers.erase(panel)
					return


func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("EnemyInfo clicked for: ", name_label.text)
		enemy_info_clicked.emit(self)


func select():
	is_selected = true
	_update_appearance()


func deselect():
	is_selected = false
	_update_appearance()


func _update_appearance():
	if is_selected:
		var stylebox = StyleBoxFlat.new()
		stylebox.bg_color = Color.MOCCASIN
		stylebox.border_color = Color.CYAN
		stylebox.border_width_left = 3
		stylebox.border_width_top = 3
		stylebox.border_width_right = 3
		stylebox.border_width_bottom = 3
		stylebox.corner_radius_top_left = 8
		stylebox.corner_radius_top_right = 8
		stylebox.corner_radius_bottom_right = 8
		stylebox.corner_radius_bottom_left = 8

		add_theme_stylebox_override("panel", stylebox)
	else:
		remove_theme_stylebox_override("panel")


func set_enemy_info(enemy, enemy_name):
	enemy_link = enemy
	name_label.text = enemy_name
	cur_hp_label.text = str(enemy.stats.max_health)
	max_hp_label.text = str(enemy.stats.max_health)
	for infusion in enemy.effects:
		add_infusion(infusion.effect_type)


func set_hp(current_health, max_health):
	cur_hp_label.text = str(current_health)
	max_hp_label.text = str(max_health)


func add_infusion(effect_type):
	var panel = _create_effect_panel(effect_type, "INFUSION", Color.DARK_RED, Color.LIGHT_CORAL)
	enemy_infusion_container.add_child(panel)


func add_effect(effect):
	_add_effect_internal(
		effect.effect_type,
		str(effect.duration),
		Color.DARK_BLUE,
		Color.LIGHT_BLUE,
		effect.duration
		)


func add_effect_imanaginable(effect_type, effect_duration):
	_add_effect_internal(
		effect_type,
		str(effect_duration),
		Color.DARK_BLUE,
		Color.LIGHT_BLUE,
		effect_duration
		)


func _add_effect_internal(
	effect_type,
	suffix: String,
	bg_color: Color,
	text_color: Color,
	duration: float
	):
	var panel = _create_effect_panel(effect_type, suffix, bg_color, text_color)
	enemy_effects_container.add_child(panel)

	var update_timer = Timer.new()
	update_timer.wait_time = 0.1
	add_child(update_timer)
	update_timer.timeout.connect(_update_timer_progress.bind(panel, duration))
	update_timer.start()

	var timer = Timer.new()
	add_child(timer)
	timer.start(duration)
	timer.timeout.connect(_on_timer_timeout.bind(timer, panel, update_timer))

	effect_timers[panel] = [timer, update_timer]


func _create_effect_panel(
	effect_type: Util.EffectType,
	suffix: String, bg_color: Color,
	text_color: Color
	) -> PanelContainer:
	var panel = PanelContainer.new()

	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = bg_color
	stylebox.border_color = text_color
	stylebox.border_width_left = 2
	stylebox.border_width_top = 2
	stylebox.border_width_right = 2
	stylebox.border_width_bottom = 2
	stylebox.corner_radius_top_left = 6
	stylebox.corner_radius_top_right = 6
	stylebox.corner_radius_bottom_right = 6
	stylebox.corner_radius_bottom_left = 6
	stylebox.shadow_size = 4
	stylebox.shadow_color = Color.BLACK
	panel.add_theme_stylebox_override("panel", stylebox)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	panel.add_child(hbox)

	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(8, 8)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.color = text_color
	hbox.add_child(icon)

	var label = Label.new()
	label.text = Util.get_effect_name(effect_type) + " " + suffix
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", text_color)

	var label_settings = LabelSettings.new()
	label_settings.outline_size = 2
	label_settings.outline_color = Color.BLACK
	label.label_settings = label_settings

	hbox.add_child(label)

	panel.tooltip_text = Util.get_effect_name(effect_type)

	return panel


func _update_timer_progress(panel: PanelContainer, initial_duration: float):
	var hbox = panel.get_child(0)
	if hbox and hbox.get_child_count() > 1:
		var label = hbox.get_child(1) as Label
		if label:
			var text = label.text
			var regex = RegEx.new()
			regex.compile("(\\d+\\.?\\d*)")
			var result = regex.search(text)
			if result:
				var current_value = float(result.get_string())
				var new_value = max(0, current_value - 0.1)
				var progress = new_value / initial_duration
				var hbox_child = panel.get_child(0)
				if hbox_child and hbox_child.get_child_count() > 1:
					var time_label = hbox_child.get_child(1) as Label
					if progress < 0.3:
						time_label.add_theme_color_override("font_color", Color.RED)
					elif progress < 0.6:
						time_label.add_theme_color_override("font_color", Color.YELLOW)

				label.text = text.replace(str(current_value), "%.1f" % new_value)


func _on_timer_timeout(timer: Timer, panel: PanelContainer, update_timer: Timer):
	panel.queue_free()
	timer.queue_free()
	update_timer.queue_free()
	effect_timers.erase(panel)


func clear_effects():
	for panel in effect_timers:
		if is_instance_valid(panel):
			var timers = effect_timers[panel]
			timers[0].stop()
			timers[1].stop()
			timers[0].queue_free()
			timers[1].queue_free()
			panel.queue_free()
	effect_timers.clear()


func clear_infusions():
	for child in enemy_infusion_container.get_children():
		child.queue_free()
