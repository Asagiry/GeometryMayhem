extends Node

@export var creep_attack_scene: PackedScene
@export var damage_data: DamageData
@export var damage_type: Util.DamageCategory

var damage_multiplier: float = 1.0


func _ready() -> void:
	pass
	#_create_attack_instance()

func _create_attack_instance():
	var creep_attack_instance = creep_attack_scene.instantiate() as CreepAttack
	get_tree().get_first_node_in_group("front_layer").add_child(creep_attack_instance)
	creep_attack_instance.set_enemy(get_parent())
	call_deferred("_set_damage", creep_attack_instance)


func _set_damage(creep_attack_instance: CreepAttack):
	damage_data.amount *= damage_multiplier
	creep_attack_instance.enemy_hit_box_component.damage_data = damage_data
