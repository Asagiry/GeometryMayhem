extends EnemyController

@onready var hurt_box: HurtBox = %HurtBox


func _ready():
	await get_tree().create_timer(5).timeout
	super()
	animated_sprite_2d = %AnimatedSprite2D
