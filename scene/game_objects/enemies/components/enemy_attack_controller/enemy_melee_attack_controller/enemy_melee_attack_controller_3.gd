class_name EnemyMeleeAttackController3
extends EnemyAttackController


var melee_shape: CollisionShape2D

@onready var melee_hitbox: Area2D = %MeleeHitbox


func _ready() -> void:
	super()
	if melee_hitbox:
		melee_hitbox.monitoring = true
	melee_shape = _ensure_melee_shape()


func activate_attack():
	attack_started.emit()
	_do_melee_attack()
	await get_tree().create_timer(get_duration()).timeout
	attack_finished.emit()
	start_cooldown()


func _do_melee_attack() -> void:
	if not melee_hitbox:
		return
	var areas = melee_hitbox.get_overlapping_areas()
	var dmg: DamageData = get_attack_damage()
	dmg.amount *= damage_multiplier
	for area in areas:
		if area is HurtBox and area.has_method("deal_damage"):
			area.deal_damage(dmg)


func _ensure_melee_shape() -> CollisionShape2D:
	if not melee_hitbox:
		return null
	var existing = melee_hitbox.get_node_or_null("CollisionShape2D")
	if existing:
		return existing as CollisionShape2D
	var collision = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	var radius = get_attack_range()
	circle.radius = radius
	collision.shape = circle
	melee_hitbox.add_child(collision)
	return collision


func _on_cooldown_timer_timeout() -> void:
	attack_cd_timeout.emit()
