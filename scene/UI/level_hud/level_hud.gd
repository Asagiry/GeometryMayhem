class_name LevelHUD

extends CanvasLayer

@export var player: PlayerController

@onready var health_bar: BarUI = %HealthBar
@onready var cooldown_bar: CooldownBar = $MarginContainer/VBoxContainer/HBoxContainer/CooldownBar
@onready var resonance_bar: BarUI = %ResonanceBar

func _ready() -> void:
	_health_setup()
	_resonance_setup()
	_cooldown_setup()

	Global.player_died.connect(_on_player_died)

func _health_setup():
	player.health_component.health_increased.connect(_on_health_changed)
	player.health_component.health_decreased.connect(_on_health_changed)
	health_bar.max_value = player.stats.max_health
	health_bar.value = player.stats.max_health

func _on_health_changed(current_health, max_health):
	health_bar.max_value = max_health
	health_bar.value = current_health


func _resonance_setup():
	Global.impulse_amount_changed.connect(_on_resonance_changed)
	resonance_bar.value = player.resonance_component.current_impulse
	resonance_bar.max_value = player.resonance_component.get_max_impulse()

func _on_resonance_changed(current_impulse,current_level,required):
	resonance_bar.max_value = required
	resonance_bar.value = current_impulse


func _cooldown_setup():
	cooldown_bar.setup(player)
	player.attack_controller.attack_started.connect(_on_attack_started)
	player.parry_controller.parry_started.connect(_on_parry_started)


func _on_attack_started():
	cooldown_bar.trigger_attack_cooldown()


func _on_parry_started():
	cooldown_bar.trigger_parry_cooldown()


func _on_player_died():
	queue_free()
