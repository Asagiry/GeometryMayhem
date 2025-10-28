extends LineEdit

func get_damage_data() -> DamageData :
	var damage_data = DamageData.new()
	damage_data.damage_category = Util.DamageCategory.DEFAULT
	damage_data.amount = float(text)
	return damage_data
