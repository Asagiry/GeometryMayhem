class_name StatModifierBuilder

var _modifiers: StatModifierData

func _init():
	_modifiers = StatModifierData.new()

#region Attack Comp Mults
func attack_multiplier(value: float) -> StatModifierBuilder:
	_modifiers.set_attack_multiplier(value)
	return self

func attack_cd_multiplier(value: float) -> StatModifierBuilder:
	_modifiers.set_attack_cd_multiplier(value)
	return self

func attack_duration_multiplier(value: float) -> StatModifierBuilder:
	_modifiers.set_attack_duration_multiplier(value)
	return self

func attack_range_multiplier(value: float) -> StatModifierBuilder:
	_modifiers.set_attack_range_multiplier(value)
	return self
#endregion


#region Movement Comp Mults
func speed_multiplier(value: float) -> StatModifierBuilder:
	_modifiers.set_speed_multiplier(value)
	return self
#endregion


#region Armor Comp Mults
func armor_multiplier(value: float) -> StatModifierBuilder:
	_modifiers.set_armor_multiplier(value)
	return self
#endregion


#region Health Comp Mults
func forward_receiving_damage_multiplier(value: float) -> StatModifierBuilder:
	_modifiers.set_forward_receiving_damage_multiplier(value)
	return self

func invulnerable(value: bool) -> StatModifierBuilder:
	_modifiers.set_invulnerable(value)
	return self

func percent_of_max_health_multiplier(value: float) -> StatModifierBuilder:
	_modifiers.set_percent_of_max_health_multiplier(value)
	return self
#endregion


func build() -> StatModifierData:
	return _modifiers
