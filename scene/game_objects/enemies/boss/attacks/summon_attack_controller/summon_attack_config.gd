class_name SummonAttackConfig

extends BaseAttackConfig

@export_category("Summon Parameters")
## Зона, с которой будут спавниться враги.
@export var zone: Util.Zone = Util.Zone.FLUX
## Количество врагов, которые заспавнятся.
@export var number_of_enemies: int = 3
## Внутренний кулдаун для параллельного исполнения атаки.
@export var cooldown_time: float = 30.0

func get_parameters_dict() -> Dictionary:
	var parameters = super.get_parameters_dict()
	parameters["zone"] = zone
	parameters["number_of_enemies"] = number_of_enemies
	parameters["cooldown_time"] = cooldown_time
	return parameters
