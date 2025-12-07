class_name TestUI

extends CanvasLayer

const PATH_TO_MELEE_ENEMIES: String = "res://scene/game_objects/enemies/melee_enemy/flux/"
const PATH_TO_RANGE_ENEMIES: String = "res://scene/game_objects/enemies/range_enemy/flux/"
const PATH_TO_BOMB_ENEMIES: String = "res://scene/game_objects/enemies/bomb_enemy/flux/"

@export var player : PlayerController

var enemy_info_panel = preload("res://scene/test_level/enemy_info.tscn")

var state_machine: StateMachine
var selected_enemy
var effect_timers: Dictionary = {}

@onready var effect_choose: MenuButton = %EffectChoose
@onready var behavior_choose: MenuButton = %BehaviorChoose
@onready var damage_edit: LineEdit = %DamageEdit
@onready var stat_choose: MenuButton = %StatChoose
@onready var duration_edit: LineEdit = %DurationEdit
@onready var tick_edit: LineEdit = %TickEdit
@onready var freeze_button: Button = %FreezeButton
@onready var applied_effects_container: FlowContainer = %AppliedEffectsContainer

@onready var max_health_label: Label = %Max_heatlh_label
@onready var current_health_label: Label = %Current_health_label

@onready var current_impulse: Label = %CurrentImpulse
@onready var requirment_impulse: Label = %RequirmentImpulse
@onready var resonance_level: Label = %ResonanceLevel
@onready var resonance_progress_bar: ProgressBar = %ResonanceProgressBar
@onready var effect_infusion_check_button: CheckButton = %EffectInfusionCheckButton
@onready var player_stats_menu_button: MenuButton = %PlayerStatsMenuButton

@onready var enemy_info_container: VBoxContainer = %EnemyInfoContainer
@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var enemy_stats_menu_button: MenuButton = %EnemyStatsMenuButton
@onready var add_to_all_enemies_check_box: CheckBox = %AddToAllEnemiesCheckBox
@onready var applied_infusions_container: FlowContainer = %AppliedInfusionsContainer
@onready var enemy_spawn_container: FlowContainer = %EnemySpawnContainer



#region init functions
func _ready():
	call_deferred("_connect_signal")
	_enter_variables()
	_setup_enemy_spawn_buttons()
	_load_player_infusions()


func _enter_variables():
	resonance_level.text = "0"
	current_impulse.text = "0"
	requirment_impulse.text = "100"
	max_health_label.text = str(player.stats.max_health)
	current_health_label.text = str(player.stats.max_health)
	player_stats_menu_button.set_stats(player.stats)


func _connect_signal():
	player.health_component.health_decreased.connect(_on_health_changed)
	player.health_component.health_increased.connect(_on_health_changed)
	Global.impulse_amount_changed.connect(_on_impulse_amount_changed)
	Global.enemy_died.connect(_on_enemy_died)
	player.player_hurt_box.effect_is_applied.connect(_on_enemy_applied_effect_to_player)


func _setup_enemy_spawn_buttons():
	var enemy_paths = [
		PATH_TO_MELEE_ENEMIES,
		PATH_TO_RANGE_ENEMIES,
		PATH_TO_BOMB_ENEMIES
	]

	for folder_path in enemy_paths:
		_load_enemies_from_folder(folder_path)


func _load_player_infusions():
	var player_infusions = player.effects
	for effect in player_infusions:
		add_infusion(effect.effect_type)


func _load_enemies_from_folder(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn") and not file_name.begins_with("."):
				var enemy_path = folder_path + file_name
				var enemy_scene = load(enemy_path)
				if enemy_scene:
					_create_enemy_spawn_button(enemy_scene, file_name.get_basename())
			file_name = dir.get_next()
		dir.list_dir_end()


func _create_enemy_spawn_button(enemy_scene: PackedScene, enemy_name: String):
	var button = Button.new()
	button.text = enemy_name.replace("enemy_", "")
	button.pressed.connect(_on_enemy_spawn_button_pressed.bind(enemy_scene, enemy_name))
	enemy_spawn_container.add_child(button)


func _on_enemy_applied_effect_to_player(
	effect_type: Util.EffectType,
	effect_duration: float,
	effect_behavior: Util.EffectBehavior
):
	handle_effect_ui(effect_type, effect_duration, effect_behavior)
#endregion

#region EffectsInfoContainer(ApplyEffects)
func _on_apply_button_pressed() -> void:
	var effect = Effect.new()
	effect.effect_type = effect_choose.get_effect_type()
	effect.behavior = behavior_choose.get_behavior()
	effect.damage = damage_edit.get_damage_data()
	effect.stat_modifiers = stat_choose.get_stat_data()
	effect.duration = duration_edit.get_duration()
	effect.tick_interval = tick_edit.get_tick_interval()
	apply_effect(effect)


func apply_effect(effect: Effect):
	if selected_enemy or add_to_all_enemies_check_box.button_pressed:
		apply_effect_to_enemies(effect)
	else:
		apply_effect_to_player(effect)


func apply_effect_to_player(effect: Effect):
	update_stats(effect)
	if effect_infusion_check_button.button_pressed:
		player.effects.append(effect)
		add_infusion(effect.effect_type)
	else:
		player.effect_receiver.apply_effect(effect)
		# Для UI: обновляем панель эффекта
		handle_effect_ui(effect.effect_type, effect.duration, effect.behavior)


func handle_effect_ui(effect_type: Util.EffectType, duration: float, behavior: Util.EffectBehavior):
	print("in function handle_effect_ui")
	match behavior:
		Util.EffectBehavior.SPECIAL:
			print("in matchcase special")
			if not has_effect_panel(effect_type):
				add_effect(effect_type, duration)
		Util.EffectBehavior.INSTANT:
			print("in matchcase instant")
			add_effect(effect_type, duration)
		Util.EffectBehavior.DOT, Util.EffectBehavior.BUFF, Util.EffectBehavior.DEBUFF:
			remove_effect_panel(effect_type)
			add_effect(effect_type, duration)


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
	print("in function remove effect panel")
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


func update_stats(effect: Effect):
	effect_choose.update_effect_type(effect.effect_type)
	behavior_choose.update_effect_behavior(effect.behavior)
	if effect.damage:
		damage_edit.text = str(effect.damage.amount)
	else:
		damage_edit.text = "NONE"
	stat_choose.update_stat_modifiers(effect.stat_modifiers)
	duration_edit.text = str(effect.duration)
	tick_edit.text = str(effect.tick_interval)


func apply_effect_to_enemies(effect):
	var targets = get_tree().get_nodes_in_group("enemy") \
	if add_to_all_enemies_check_box.button_pressed or !selected_enemy \
	else [selected_enemy]
	var is_infusion = effect_infusion_check_button.button_pressed

	for target in targets:
		if is_infusion:
			target.effects.append(effect)
			_on_infusion_added_to_enemy(target, effect)
		else:
			target.effect_receiver.apply_effect(effect)
			# Для UI врагов: обновляем панель эффекта
			handle_enemy_effect_ui(target, effect.effect_type, effect.duration, effect.behavior)


func handle_enemy_effect_ui(
	enemy,
	effect_type: Util.EffectType,
	duration: float,
	behavior: Util.EffectBehavior
	):
	for element in enemy_info_container.get_children():
		if element is EnemyInfo:
			if is_instance_valid(element.enemy_link) and enemy == element.enemy_link:
				element.handle_effect_ui(effect_type, duration, behavior)
				break


func _on_applied_effect_to_enemy(
	effect_type: Util.EffectType,
	effect_duration: float,
	effect_behavior: Util.EffectBehavior,
	enemy
	):
	for element in enemy_info_container.get_children():
		if element is EnemyInfo:
			if is_instance_valid(element.enemy_link):
				if enemy == element.enemy_link:
					element.handle_effect_ui(effect_type, effect_duration, effect_behavior)


func add_effect(effect_type, duration):
	var panel = _create_effect_panel(
		effect_type,
		str(duration),
		Color.DARK_BLUE,
		Color.LIGHT_BLUE
	)
	applied_effects_container.add_child(panel)

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


func add_infusion(effect_type):
	# Для инфузий проверяем дубликаты
	for child in applied_infusions_container.get_children():
		var hbox = child.get_child(0)
		if hbox and hbox.get_child_count() > 1:
			var label = hbox.get_child(1) as Label
			if label and Util.get_effect_name(effect_type) in label.text:
				return  # Инфузия уже существует, не добавляем дубликат

	var panel = _create_effect_panel(effect_type, "", Color.DARK_RED, Color.LIGHT_CORAL)
	applied_infusions_container.add_child(panel)


func _create_effect_panel(
	effect_type: Util.EffectType,
	suffix: String,
	bg_color: Color,
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


func _on_timer_timeout(timer:Timer, ui_element, update_timer: Timer):
	ui_element.queue_free()
	timer.queue_free()
	update_timer.queue_free()
	effect_timers.erase(ui_element)

#endregion


#region Effects presets
func _on_slow_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.SLOW,
				Util.EffectBehavior.DEBUFF,
				Util.EffectPositivity.NEGATIVE,
				5.0
			)
			.with_stat_modifiers(
				StatModifierBuilder.new()
				.speed_multiplier(0.5)
				.build()
			)
			.with_chance(0.3)
			.build()
	)


func _on_curse_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.CURSE,
				Util.EffectBehavior.DEBUFF,
				Util.EffectPositivity.NEGATIVE,
				5.0
			)
			.with_stat_modifiers(
				StatModifierBuilder.new()
					.forward_receiving_damage_multiplier(1.25)
					.build()
			)
			.build()
	)


func _on_burn_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.BURN,
				Util.EffectBehavior.DOT,
				Util.EffectPositivity.NEGATIVE,
				5.0
			)
			.with_damage(10)
			.with_tick_interval(1.0)
			.build()
	)


func _on_silence_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.SILENCE,
				Util.EffectBehavior.SPECIAL,
				Util.EffectPositivity.NEGATIVE,
				5.0
			)
			.build()
	)


func _on_freeze_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.FREEZE,
				Util.EffectBehavior.SPECIAL,
				Util.EffectPositivity.NEGATIVE,
				6.0
			)
			.build()
	)


func _on_rupture_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.RUPTURE,
				Util.EffectBehavior.SPECIAL,
				Util.EffectPositivity.NEGATIVE,
				5.0
			)
			.with_damage(0.5)
			.build()
	)


func _on_phased_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.PHASED,
				Util.EffectBehavior.SPECIAL,
				Util.EffectPositivity.POSITIVE,
				5.0
			)
			.with_stat_modifiers(
				StatModifierBuilder.new()
					.speed_multiplier(2.0)
					.invulnerable(true)
					.build()
			)
			.build()
	)


func _on_sonic_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.SONIC,
				Util.EffectBehavior.BUFF,
				Util.EffectPositivity.POSITIVE,
				5.0
			)
			.with_stat_modifiers(
				StatModifierBuilder.new()
					.speed_multiplier(2.0)
					.attack_cd_multiplier(0.6)
					.attack_duration_multiplier(0.5)
					.build()
			)
			.build()
	)


func _on_fortify_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.FORTIFY,
				Util.EffectBehavior.BUFF,
				Util.EffectPositivity.POSITIVE,
				7.0
			)
			.with_stat_modifiers(
				StatModifierBuilder.new()
					.armor_multiplier(2.0)
					.percent_of_max_health_multiplier(2.0)
					.build()
			)
			.build()
	)


func _on_blind_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.BLIND,
				Util.EffectBehavior.SPECIAL,
				Util.EffectPositivity.NEGATIVE,
				6.0
			)
			.build()
	)


func _on_dispel_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.DISPEL,
				Util.EffectBehavior.INSTANT,
				Util.EffectPositivity.POSITIVE
			)
			.build()
	)


func _on_bkb_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.BKB,
				Util.EffectBehavior.SPECIAL,
				Util.EffectPositivity.POSITIVE,
				7.0
			)
			.build()
	)


func _on_collider_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.COLLIDER,
				Util.EffectBehavior.SPECIAL,
				Util.EffectPositivity.POSITIVE,
				7.0
			)
			.build()
	)


func _on_corrosion_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.CORROSION,
				Util.EffectBehavior.DEBUFF,
				Util.EffectPositivity.NEGATIVE,
				5.0
			)
			.with_stat_modifiers(
				StatModifierBuilder.new()
					.armor_multiplier(0.5)
					.build()
			)
			.build()
	)


func _on_regeneration_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.REGENERATION,
				Util.EffectBehavior.DOT,
				Util.EffectPositivity.POSITIVE,
				5.0
			)
			.with_damage(20)
			.with_tick_interval(0.25)
			.build()
	)


func _on_fear_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.FEAR,
				Util.EffectBehavior.SPECIAL,
				Util.EffectPositivity.NEGATIVE,
				4.0
			)
			.build()
	)


func _on_bleed_preset_pressed() -> void:
	if not effect_infusion_check_button.button_pressed:
		return

	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.BLEED,
				Util.EffectBehavior.SPECIAL,
				Util.EffectPositivity.NEGATIVE,
				4.0
			)
			.with_percent(0.5)
			.build()
	)


func _on_wounded_preset_pressed() -> void:
	apply_effect(
		EffectBuilder.new()
			.set_basic(
				Util.EffectType.WOUNDED,
				Util.EffectBehavior.SPECIAL,
				Util.EffectPositivity.NEGATIVE,
				5.0
			)
			.with_percent(0.05)
			.build()
	)
#endregion


#region Player settings
func delete_all_infusions(entity):
	if not entity:
		push_warning("Select enemy first OR player doesnt exists in this script :(")
		return

	if not entity.effects:
		push_warning("Error entity does not have <<var effects: Array[Effect]>>")
		return

	entity.effects.clear()


func clear_player_infusions():
	for element in applied_infusions_container.get_children():
		element.queue_free()
	delete_all_infusions(player)


func clear_player_effects():
	for panel in effect_timers:
		if is_instance_valid(panel):
			var timers = effect_timers[panel]
			timers[0].stop()
			timers[1].stop()
			timers[0].queue_free()
			timers[1].queue_free()
			panel.queue_free()

	effect_timers.clear()

	player.effect_receiver.clear_all_effects()


func _on_clear_player_infusions_button_pressed() -> void:
	clear_player_infusions()


func _on_clear_all_effects_pressed() -> void:
	clear_player_effects()


func _on_add_resonance_level_button_pressed() -> void:
	var impulse_to_add = player.resonance_component.get_current_level_requirement()
	var half_of_next_level_requirment_impulse = \
	player.resonance_component.get_next_level_requirement() * 0.5
	impulse_to_add = (impulse_to_add - player.resonance_component.get_current_impulse()) \
	+ half_of_next_level_requirment_impulse
	player.resonance_component.grant_impulse(int(impulse_to_add))


func _on_remove_resonance_level_button_pressed() -> void:
	var impulse_to_reduce = player.resonance_component.get_current_impulse()
	var half_of_prev_level_requiment_impulse = \
	player.resonance_component.get_prev_level_requirement() * 0.5
	impulse_to_reduce = impulse_to_reduce + half_of_prev_level_requiment_impulse
	player.resonance_component.reduce_impulse(int(impulse_to_reduce), true)


func _on_remove_all_resonance_button_pressed() -> void:
	player.resonance_component.reset_resonance()

#endregion


#region Enemy Settings
func _on_unstun_enemies_button_pressed() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.effect_receiver.set_stun_state(0)


func _on_stun_enemies_button_pressed() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.set_stun(9999)


func _on_clear_enemy_infusions_button_pressed() -> void:
	var targets = get_tree().get_nodes_in_group("enemy") \
	if add_to_all_enemies_check_box.button_pressed or !selected_enemy \
	else [selected_enemy]
	var is_infusion = effect_infusion_check_button.button_pressed

	for target in targets:
		for element in enemy_info_container.get_children():
			if element is not EnemyInfo:
				continue
			if element.enemy_link == target:
				element.clear_infusions()
				delete_all_infusions(target)


func _on_delete_enemy_button_pressed() -> void:
	if !selected_enemy:
		push_warning("Enemy is not selected. Select enemy first.")
		return

	var enemy_to_delete = selected_enemy

	_update_enemy_selection(null)
	enemy_name_label.text = "ENEMY IS NOT SELECTED"

	for element in enemy_info_container.get_children():
		if element is EnemyInfo and element.enemy_link == enemy_to_delete:
			element.queue_free()
			break

	enemy_to_delete.queue_free()


func _on_stun_selected_enemy_button_pressed() -> void:
	if !selected_enemy:
		push_warning("Enemy is not selected. Select enemy first.")
		return

	selected_enemy.set_stun(9999)


func _on_unstun_selected_enemy_button_pressed() -> void:
	if !selected_enemy:
		push_warning("Enemy is not selected. Select enemy first.")
		return

	selected_enemy.set_stun(0)

#endregion


#region Spawn Enemy
func _on_enemy_spawn_button_pressed(enemy_scene: PackedScene, enemy_name: String):
	var enemy_instance = enemy_scene.instantiate()

	enemy_instance.stats = enemy_instance.stats.duplicate(true)

	get_tree().get_first_node_in_group("back_layer").add_child(enemy_instance)

	var spawn_position = _get_spawn_position_behind_player()
	enemy_instance.global_position = spawn_position

	enemy_instance.set_stun(9999)
	enemy_instance.hurt_box.effect_is_applied.connect(_on_applied_effect_to_enemy.bind(enemy_instance))
	create_enemy_info_panel(enemy_instance, enemy_name)

func _get_spawn_position_behind_player() -> Vector2:
	var behind_direction = player.movement_component.last_direction
	var spawn_offset = behind_direction * 32
	return player.global_position + spawn_offset

#endregion


#region PlayerFreezeAndHpContainer
func _on_health_changed(current_health: float, max_health: float):
	max_health_label.text = str(max_health)
	current_health_label.text = str(current_health)


func _on_heal_player_pressed() -> void:
	player.health_component.current_health = float(max_health_label.text)
	current_health_label.text = max_health_label.text


func _on_freeze_button_pressed() -> void:
	if freeze_button.text == "Freeze":
		freeze_button.text = "Unfreeze"
		player.effect_receiver.set_stun_state(9999)
	else:
		freeze_button.text = "Freeze"
		player.state_machine.states["PlayerStunState"].set_duration(0)
#endregion


#region ResonanceContainer
func _on_impulse_amount_changed(p_current_impulse, current_lvl, requirment):
	resonance_level.text = str(current_lvl)
	current_impulse.text = str(p_current_impulse)
	requirment_impulse.text = str(requirment)
	resonance_progress_bar.max_value = requirment
	resonance_progress_bar.value = p_current_impulse

#endregion


#region EnemyInfoPanel
func create_enemy_info_panel(enemy, enemy_name: String):
	var enemy_info_panel_instance = enemy_info_panel.instantiate() as EnemyInfo
	enemy_info_container.add_child(enemy_info_panel_instance)
	enemy_info_panel_instance.enemy_info_clicked.connect(_on_enemy_info_clicked)
	enemy_info_panel_instance.set_enemy_info(enemy, enemy_name)
	enemy.health_component.health_increased.connect(_on_enemy_health_changed.bind(enemy))
	enemy.health_component.health_decreased.connect(_on_enemy_health_changed.bind(enemy))
	#if enemy is EnemyBombController:
		#enemy.attack_controller.attack_finished.connect(_on_enemy_bomb_enemy_died)


func _on_enemy_info_clicked(clicked_enemy_info: EnemyInfo):
	if clicked_enemy_info.is_selected:
		clicked_enemy_info.deselect()
		_update_enemy_selection(null)
	else:
		for enemy_info in enemy_info_container.get_children():
			if enemy_info is EnemyInfo:
				enemy_info.deselect()
		clicked_enemy_info.select()
		_update_enemy_selection(clicked_enemy_info.enemy_link)

	if selected_enemy:
		enemy_name_label.text = "SELECTED ENEMY : " \
		+ selected_enemy.scene_file_path.get_file().get_basename()
	else:
		enemy_name_label.text = "ENEMY IS NOT SELECTED"


func _update_enemy_selection(enemy):
	selected_enemy = enemy
	if enemy:
		enemy_stats_menu_button.set_stats(enemy.get_stats(), enemy)
	else:
		enemy_stats_menu_button.set_stats(null)


func _on_enemy_died(_stats):
	await get_tree().process_frame
	_cleanup_enemy_info_panels()


func _on_enemy_bomb_enemy_died():
	await get_tree().process_frame
	_cleanup_enemy_info_panels()


func _cleanup_enemy_info_panels():
	for element in enemy_info_container.get_children():
		if element is EnemyInfo:
			if not is_instance_valid(element.enemy_link):
				element.queue_free()


func _on_enemy_health_changed(current_health, max_health, enemy):
	for element in enemy_info_container.get_children():
		if element is EnemyInfo:
			if is_instance_valid(element.enemy_link):
				if enemy == element.enemy_link:
					element.set_hp(current_health, max_health)


func _on_infusion_added_to_enemy(enemy, effect):
	for element in enemy_info_container.get_children():
		if element is EnemyInfo:
			if is_instance_valid(element.enemy_link):
				if enemy == element.enemy_link:
					element.add_infusion(effect.effect_type)


func _on_effect_added_to_enemy(enemy, effect):
	for element in enemy_info_container.get_children():
		if element is EnemyInfo:
			if is_instance_valid(element.enemy_link):
				if enemy == element.enemy_link:
					element.add_effect(effect)

#endregion
