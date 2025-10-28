extends CharacterBody2D

@export var effects: Array[Effect]
@export var effects_for_self: Array[Effect]
@export var effect_receiver: EffectReceiver

@onready var movement_component: EnemyMeleeMovementComponent = %MovementComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var progress_bar: ProgressBar = $TestProgressBarOnlyForTest
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready():
	health_component.died.connect(_on_died)
	for effect in effects_for_self:
		effect_receiver.apply_effect(effect)


func _process(_delta):
	var direction = movement_component.get_direction()
	#movement_component.move_to_player(self)
	progress_bar.value = health_component.current_health


func _on_died():
	queue_free()
