class_name DamageData

extends Resource

@export var amount: float
@export var damage_category: Util.DamageCategory

# Конструктор с параметрами по умолчанию
func _init(p_amount: float = 0.0,
 p_damage_category: Util.DamageCategory = Util.DamageCategory.DEFAULT) -> void:
	amount = p_amount
	damage_category = p_damage_category
