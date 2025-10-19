extends Node

@export var creep_attack_scene: PackedScene
@export var creep_attack_damage: float = 10.0
@export var damage_type: Util.DamageCategory

var creep_attack_instance: CreepAttack

func _ready() -> void:
	creep_attack_instance = creep_attack_scene.instantiate() as CreepAttack
	get_tree().get_first_node_in_group("front_layer").add_child(creep_attack_instance)
	call_deferred("_set_damage")


func _process(_delta) -> void:
	creep_attack_instance.enemy_hit_box_component.position = owner.position



func _set_damage():
	var damage_data: DamageData = DamageData.new()
	damage_data.amount = creep_attack_damage
	damage_data.damage_categoty = damage_type
	creep_attack_instance.enemy_hit_box_component.damage_data = damage_data
