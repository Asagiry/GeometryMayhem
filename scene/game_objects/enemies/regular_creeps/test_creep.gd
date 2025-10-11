extends CharacterBody2D

@onready var movement_component: Node = %MovementComponent
@onready var health_component: HealthComponent = %HealthComponent


func _ready():
	health_component.died.connect(_on_died)
	
func _process(delta):
	var direction = movement_component.get_direction()
	movement_component.move_to_player(self)
	
func _on_died():
	queue_free()
