class_name AttackStageConfig
extends Resource

@export var stage_name: String = ""
@export var attack_cooldown: float = 3.0  # Задержка между атаками
@export var attacks: Array[BaseAttackConfig] = []  # Массив конфигов атак для этой стадии
