class_name MetaProgressionData
extends Resource

# Базовое требование для первого уровня (0 → 1)
var base_knowledge_requirement: int = 100

# Насколько растёт требование за каждый новый уровень
var level_increment: int = 20

# Увеличение прироста каждые 10 уровней (например, +20 -> +40 -> +60)
var tier_increment: int = 20

# Сколько уровней длится один "тяжелый" диапазон
var tier_size: int = 10

func _get_required_knowledge(level: int) -> int:
	@warning_ignore("integer_division")
	var tier = level / tier_size
	return base_knowledge_requirement \
		+ level * (level_increment + tier * tier_increment)
