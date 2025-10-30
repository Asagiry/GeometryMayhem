class_name PlayerAnimatedSprite2D

extends AnimatedSprite2D

@export var player: PlayerController
@export var attack_controller: PlayerAttackController
@export var parry_controller: ParryController

func play_attack_animation():
	var duration = attack_controller.get_duration()

	speed_scale = 1.0/duration

	play("attack")

	var tween := player.create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "scale", Vector2(0.25, 1),duration)\
		.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2(1, 1), duration)\
		.set_ease(Tween.EASE_OUT)
	tween.finished.connect(func():
		speed_scale = 1)


func play_parry_animation():
	var duration = parry_controller.get_duration()
	speed_scale = 1.0/duration
	play("parry")
	await animation_finished
	speed_scale = 1.0


func play_idle_animation():
	play("idle")


func play_movement_animation():
	play("movement")
