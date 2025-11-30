class_name ArtefactData

extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D
@export var rarity: Util.ArtefactRarity
@export_enum("achievement", "random_drop") var unlock_condition: String
@export var level_requirment: int
@export var unlock_achievement_id: String = ""
@export var drop_chance: float = 0.0
@export var behavior_script: Script
@export var base_params := {}
