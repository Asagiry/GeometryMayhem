class_name ArtefactData

extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D
@export var rarity: Util.ArtefactRarity

@export_enum("always", "achievement", "random_drop") var unlock_condition: String = "always"
@export var unlock_achievement_id: String = ""
#TODO понять, как это будем взаимодействовать с artefact_pool
@export var drop_chance: float = 0.0
@export var behavior_script: Script
#поле для того, чтобы указывать допольнительные параметры. Ex:
	#params = {
	#"clone_lifetime": 1.5,
	#"clone_damage_mult": 0.5,
	#"clone_count": 1
#}
@export var params := {}
