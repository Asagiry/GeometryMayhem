class_name LevelHUD

extends CanvasLayer

@export var player: PlayerController
@export var arena_map: ArenaMap

@onready var health_bar: HealthBarUI = %HealthBar
@onready var resonance_bar: ResonanceBarUI = %ResonanceBar
@onready var cooldown_bar: CooldownBar = %CooldownBar
@onready var arena_time: ArenaTimeUI = %ArenaTime
@onready var echo_label: Label = %EchoLabel
@onready var level_label: Label = %LevelLabel
@onready var current_zone_label: Label = %CurrentZoneLabel
@onready var fps_label: Label = %FpsLabel


func _process(delta: float) -> void:
	# delta — время предыдущего кадра в секундах
	var frame_time_ms = delta * 1000.0
	fps_label.text = "FPS: %d | Frame: %.2f ms" % [Engine.get_frames_per_second(),
	frame_time_ms]

func _ready() -> void:
	_health_setup()
	_resonance_setup()
	_cooldown_setup()
	_minimap_setup()
	_meta_setup()
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
	_on_resonance_changed(player.resonance_component.current_impulse,
	player.resonance_component.current_level,
	player.resonance_component.get_current_level_requirement(),
	)


func _on_resonance_changed(current_impulse,current_level,required):
	resonance_bar.max_value = required
	resonance_bar.value = current_impulse
	resonance_bar.current_level_label.text = str(current_level)


func _cooldown_setup():
	cooldown_bar.setup(player)
	player.attack_controller.attack_started.connect(_on_attack_started)
	player.parry_controller.parry_started.connect(_on_parry_started)


func _on_attack_started():
	cooldown_bar.trigger_attack_cooldown()


func _on_parry_started():
	cooldown_bar.trigger_parry_cooldown()


func _minimap_setup():
	arena_map.player_entered.connect(_on_player_entered)


func _on_player_entered(current_zone: ArenaZone):
	current_zone_label.text = "Current zone: " + current_zone.get_zone_name()


func _meta_setup():
	Global.meta_progression.meta_updated.connect(_on_update_meta)
	_on_update_meta(Global.meta_progression.player_data)

func _on_update_meta(player_meta: PlayerData):
	echo_label.text  = str(player_meta.currency)
	level_label.text = str(player_meta.level)

func _on_player_died():
	queue_free()
