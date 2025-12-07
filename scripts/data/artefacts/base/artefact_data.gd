class_name ArtefactData
extends Resource

# Используем настоящий enum для удобства в коде (if condition == UnlockCondition.ACHIEVEMENT)
enum UnlockCondition {
	ACHIEVEMENT,
	RANDOM_DROP,
}

@export_group("Visuals")
@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var rarity: Util.ArtefactRarity


@export_group("Requirements")
@export var unlock_condition: UnlockCondition = UnlockCondition.RANDOM_DROP
@export var level_requirement: int = 1
@export var unlock_achievement_id: String


@export_group("Logic")
@export var behavior_script: Script
@export var base_params: Dictionary = {}


# Хелпер для проверки, есть ли у нас вообще логика
func has_behavior() -> bool:
	return behavior_script != null
