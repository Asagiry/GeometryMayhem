extends CanvasLayer

var player : PlayerController

var state_machine: StateMachine

@onready var effect_choose: MenuButton = %EffectChoose
@onready var behavior_choose: MenuButton = %BehaviorChoose
@onready var damage_edit: LineEdit = %DamageEdit
@onready var stat_choose: MenuButton = %StatChoose
@onready var duration_edit: LineEdit = %DurationEdit
@onready var tick_edit: LineEdit = %TickEdit
@onready var freeze_button: Button = %FreezeButton
@onready var applied_effects_container: VBoxContainer = %AppliedEffectsContainer

@onready var max_health_label: Label = %Max_heatlh_label
@onready var current_health_label: Label = %Current_health_label


func _ready():
	call_deferred("_connect_health_signal")

func _connect_health_signal():
	player = get_tree().get_first_node_in_group("player")
	player.health_component.health_changed.connect(_on_health_changed)
	player.health_component.stats_changed.connect(_on_health_changed)

func _on_health_changed(current_health: float, max_health: float):
	max_health_label.text = str(max_health)
	current_health_label.text = str(current_health)

#apply_on_player
func _on_apply_button_pressed() -> void:
	var effect = Effect.new()
	effect.effect_type = effect_choose.get_effect_type()
	effect.behavior = behavior_choose.get_behavior()
	effect.damage = damage_edit.get_damage_data()
	effect.stat_modifiers = stat_choose.get_stat_data()
	effect.duration = duration_edit.get_duration()
	effect.tick_interval = tick_edit.get_tick_interval()
	apply_effect(effect)


func apply_effect(effect):
	player.effect_receiver.apply_effect(effect)
	create_timer(effect)


func create_timer(effect: Effect):
	var label = Label.new()
	label.text = Util.get_effect_name(effect.effect_type)+" : "+ str(effect.duration)
	applied_effects_container.add_child(label)

	var update_timer = Timer.new()
	update_timer.wait_time = 0.1
	add_child(update_timer)
	update_timer.timeout.connect(_update_timer_progress.bind(label))
	update_timer.start()

	var timer = Timer.new()
	add_child(timer)
	timer.start(effect.duration)
	timer.timeout.connect(_on_timer_timeout.bind(timer,label,update_timer))


func _on_timer_timeout(timer:Timer ,label: Label, update_timer: Timer):
	label.queue_free()
	timer.queue_free()
	update_timer.queue_free()


func _update_timer_progress(label: Label):
	var text = label.text
	var regex = RegEx.new()
	regex.compile("(\\d+\\.?\\d*)")  # Ищем числа типа 6.0, 5.9 и т.д.
	var result = regex.search(text)
	if result:
		var current_value = float(result.get_string())
		var new_value = current_value - 0.1
		label.text = text.replace(str(current_value), str(new_value))


func _on_freeze_button_pressed() -> void:
	if freeze_button.text == "Freeze":
		freeze_button.text = "Unfreeze"
		var state = state_machine.states["PlayerIdleState"] as PlayerIdleState
		player.is_stunned = false
		state_machine.transition(state.state_name)
	else:
		freeze_button.text = "Freeze"
		state_machine = player.player_state_machine
		var state = state_machine.states["PlayerStunState"] as PlayerStunState
		state.set_duration(9999)
		player.is_stunned = true
		state_machine.transition(state.state_name)


func _on_slow_preset_pressed() -> void:
	var effect = Effect.new()
	effect.effect_type = Util.EffectType.SLOW
	effect.behavior = Util.EffectBehavior.DEBUFF
	effect.stat_modifiers = StatModifierData.new(0.2)
	effect.duration = 5.0
	effect.positivity = Util.EffectPositivity.NEGATIVE
	apply_effect(effect)



func _on_curse_preset_pressed() -> void:
	var effect = Effect.new()
	effect.effect_type = Util.EffectType.CURSE
	effect.behavior = Util.EffectBehavior.DEBUFF
	effect.stat_modifiers = StatModifierData.new(1.0,1.0,1.0,1.25)
	effect.duration = 5.0
	effect.positivity = Util.EffectPositivity.NEGATIVE
	apply_effect(effect)


func _on_burn_preset_pressed() -> void:
	var effect = Effect.new()
	effect.effect_type = Util.EffectType.BURN
	effect.behavior = Util.EffectBehavior.DOT
	effect.damage = DamageData.new(10)
	effect.duration = 5.0
	effect.tick_interval = 1.0
	effect.positivity = Util.EffectPositivity.NEGATIVE
	apply_effect(effect)


func _on_silence_preset_pressed() -> void:
	var effect = Effect.new()
	effect.effect_type = Util.EffectType.SILENCE
	effect.behavior = Util.EffectBehavior.SPECIAL
	effect.duration = 5.0
	effect.positivity = Util.EffectPositivity.NEGATIVE
	apply_effect(effect)


func _on_freeze_preset_pressed() -> void:
	var effect = Effect.new()
	effect.effect_type = Util.EffectType.FREEZE
	effect.behavior = Util.EffectBehavior.SPECIAL
	effect.duration = 6.0
	effect.positivity = Util.EffectPositivity.NEGATIVE
	apply_effect(effect)


func _on_rupture_preset_pressed() -> void:
	var effect = Effect.new()
	effect.effect_type = Util.EffectType.RUPTURE
	effect.behavior = Util.EffectBehavior.SPECIAL
	effect.damage = DamageData.new(0.5)
	effect.duration = 5.0
	effect.positivity = Util.EffectPositivity.NEGATIVE
	apply_effect(effect)


func _on_phased_preset_pressed() -> void:
	var effect = Effect.new()
	effect.effect_type = Util.EffectType.PHASED
	effect.behavior = Util.EffectBehavior.SPECIAL
	effect.stat_modifiers = StatModifierData.new(2)
	effect.duration = 5.0
	effect.positivity = Util.EffectPositivity.POSITIVE
	apply_effect(effect)


func _on_sonic_preset_pressed() -> void:
	var effect = Effect.new()
	effect.effect_type = Util.EffectType.SONIC
	effect.behavior = Util.EffectBehavior.BUFF
	effect.stat_modifiers = StatModifierData.new(2.0,1,1,1,0.6,0.5)
	effect.duration = 5.0
	effect.positivity = Util.EffectPositivity.POSITIVE
	apply_effect(effect)


func _on_fortify_preset_pressed() -> void:
	var effect = Effect.new()
	effect.effect_type = Util.EffectType.FORTIFY
	effect.behavior = Util.EffectBehavior.BUFF
	effect.stat_modifiers = StatModifierData.new(1,1,2.0,1,1,1,false,2.0)
	effect.duration = 7.0
	effect.positivity = Util.EffectPositivity.POSITIVE
	apply_effect(effect)


func _on_blind_preset_pressed() -> void:
	var effect = Effect.new()
	effect.effect_type = Util.EffectType.BLIND
	effect.behavior = Util.EffectBehavior.SPECIAL
	effect.duration = 6.0
	effect.positivity = Util.EffectPositivity.NEGATIVE
	apply_effect(effect)


func _on_heal_player_pressed() -> void:
	player.health_component.current_health = float(max_health_label.text)
	current_health_label.text = max_health_label.text


func _on_clear_all_effects_pressed() -> void:
	player.effect_receiver.clear_effects(Util.EffectPositivity.NEGATIVE)
