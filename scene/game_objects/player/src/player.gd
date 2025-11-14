class_name PlayerController

extends CharacterBody2D

#region var
@export var stats: PlayerStatData
@export var effects: Array[Effect]
@export var effect_receiver: EffectReceiver

var is_silenced: bool = false
var is_stunned: bool = false

var current_zone : ArenaZone

@onready var state_machine: StateMachine = %PlayerStateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var grace_period: Timer = %GracePeriod
@onready var movement_component: PlayerMovementComponent = %MovementComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var armor_component: ArmorComponent = %ArmorComponent
@onready var attack_controller: PlayerAttackController = %PlayerAttackController
@onready var parry_controller: ParryController = %ParryController
@onready var collision: CollisionShape2D = %CollisionShape2D
@onready var player_hurt_box: HurtBox = %PlayerHurtBox
@onready var resonance_component: ResonanceComponent = %ResonanceComponent


#endregion

func change_current_zone(zone: ArenaZone):
	if (current_zone!=zone):
		current_zone = zone

func _ready():
	Global.player_spawned.emit(self)
	_enter_variables()
	_connect_signals()
	Engine.time_scale = 1.0


func _enter_variables():
	var states: Array[State] = [
		PlayerStunState.new(self),
		PlayerMovementState.new(self),
		PlayerAttackState.new(self),
		PlayerParryState.new(self),
		]
	state_machine.start_machine(states)

func _connect_signals():
	health_component.died.connect(_on_died)
	effect_receiver.silenced.connect(_on_silenced)
	effect_receiver.collision_disabled.connect(_on_collision_disabled)

func get_effect_receiver():
	return effect_receiver


func _on_died():
	Global.player_died.emit()
	queue_free()


func _on_silenced(status: bool):
	is_silenced = status


func _on_collision_disabled(status: bool) -> void:
	set_collision_layer_value(2, !status)
	set_collision_mask_value(3, !status)
	player_hurt_box.set_collision_layer_value(9, !status)


func get_stats():
	return stats
