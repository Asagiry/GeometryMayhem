extends CharacterBody2D

@onready var movement_component: Node = %EnemyMovementComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var effect_receiver: Node2D = $EffectReceiver
@onready var progress_bar: ProgressBar = $TestProgressBarOnlyForTest

func _ready():
	effect_receiver.speed_changed.connect(_on_speed_changed)
	health_component.died.connect(_on_died)


func _process(_delta):
	var direction = movement_component.get_direction()
	movement_component.move_to_player(self)
	progress_bar.value = health_component.current_health


func _on_speed_changed(multiplier):
	movement_component.speed_multiplier = multiplier


func _on_died():
	queue_free()
