class_name AttackStageConfig
extends Resource

## Имя стадии.
@export var stage_name: String = ""
## Задержка между атаками в последовательном вызове атак.
@export var attack_cooldown: float = 3.0
## Массив конфигов атак для этой стадии
@export var attacks: Array[BaseAttackConfig] = []
