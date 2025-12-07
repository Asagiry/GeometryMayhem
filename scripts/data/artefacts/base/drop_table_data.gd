class_name DropTableData
extends Resource

# Увеличили базу для точности (100 000)
# Теперь вес 1 = 0.001%
# Вес 1000 = 1%
const TOTAL_WEIGHT: float = 100000.0

@export_group("Drop Weights (Total ~ 100 000)")
@export_range(0, 100000) var rare_weight: float = 1000.0 # 1%
@export_range(0, 100000) var legendary_weight: float = 100.0 # 0.1%
@export_range(0, 100000) var mayhem_weight: float = 10.0 # 0.01%
