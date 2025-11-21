class_name BossTentacleController

extends Node

@export var health_component: BossHealthComponent

var tentacle_data: Dictionary = {}

@onready var t_1_collision: CollisionShape2D = %T1Collision
@onready var t_2_collision: CollisionShape2D = %T2Collision
@onready var t_3_collision: CollisionShape2D = %T3Collision
@onready var t_4_collision: CollisionShape2D = %T4Collision
@onready var t_1_hurt_box: BossHurtBox = %T1HurtBox
@onready var t_2_hurt_box: BossHurtBox = %T2HurtBox
@onready var t_3_hurt_box: BossHurtBox = %T3HurtBox
@onready var t_4_hurt_box: BossHurtBox = %T4HurtBox
@onready var t_1_sprite: AnimatedSprite2D = %T1Sprite
@onready var t_2_sprite: AnimatedSprite2D = %T2Sprite
@onready var t_3_sprite: AnimatedSprite2D = %T3Sprite
@onready var t_4_sprite: AnimatedSprite2D = %T4Sprite

@onready var body_hurt_box: BossHurtBox = %BodyHurtBox
@onready var body_sprite: AnimatedSprite2D = %BodySprite
@onready var body_collision: CollisionShape2D = %BodyCollision


func _ready() -> void:
	body_hurt_box.monitorable = false
	body_hurt_box.monitoring = false

	tentacle_data["T1HurtBox"] = {
		"hurt_box" = t_1_hurt_box,
		"collision" = t_1_collision,
		"sprite" = t_1_sprite
	}
	tentacle_data["T2HurtBox"] = {
			"hurt_box" = t_2_hurt_box,
			"collision" = t_2_collision,
			"sprite" = t_2_sprite
		}
	tentacle_data["T3HurtBox"] = {
		"hurt_box" = t_3_hurt_box,
		"collision" = t_3_collision,
		"sprite" = t_3_sprite
	}
	tentacle_data["T4HurtBox"] = {
		"hurt_box" = t_4_hurt_box,
		"collision" = t_4_collision,
		"sprite" = t_4_sprite
	}
	tentacle_data["BodyHurtBox"] = {
		"hurt_box" = body_hurt_box,
		"collision" = body_collision,
		"sprite" = body_sprite
	}
	health_component.tentacle_died.connect(_on_tentacle_died)


func _on_tentacle_died(t_name: String):
	var tentacle = tentacle_data[t_name]
	tentacle["hurt_box"].queue_free()
	tentacle["collision"].queue_free()
	tentacle["sprite"].queue_free()
	tentacle_data.erase(t_name)

	if tentacle_data.size()==1:
		body_hurt_box.set_deferred("monitoring", true)
		body_hurt_box.set_deferred("monitorable", true)

	if tentacle_data.size()==0:
		owner.queue_free()
