class_name LootManager

extends Node

# Глобальная константа должна совпадать с ресурсом
const TOTAL_WEIGHT: float = 100000.0

var drop_tables: Dictionary = {
	Util.EnemyType.NORMAL: preload("res://resource/artefact_drop_tables/normal_enemy.tres"),
	Util.EnemyType.AMPLIFIED: preload("res://resource/artefact_drop_tables/amplified_enemy.tres"),
	Util.EnemyType.DISTORTED: preload("res://resource/artefact_drop_tables/distorted_enemy.tres"),
	Util.EnemyType.ANOMALY: preload("res://resource/artefact_drop_tables/anomaly_enemy.tres"),
	Util.EnemyType.BOSS: preload("res://resource/artefact_drop_tables/boss.tres"),
}


func _ready() -> void:
	Global.enemy_died.connect(_on_enemy_died)


func _on_enemy_died(enemy_stats: EnemyStatData) -> void:
	var player = get_tree().get_first_node_in_group("player")
	var player_luck: float = 0.0
	if player and player.stats:
		player_luck = player.stats.magic_find
	var rarity = _calculate_rarity(enemy_stats.enemy_type, player_luck)
	if rarity != null:
		var artefact = Global.artefact_database.get_random_accessible_artefact(rarity)
		if artefact:
			Global.inventory.add_artefact(artefact.id)
			print("Drop! Rarity: ", Util.ArtefactRarity.keys()[rarity])
			return
	if rarity == null:
		print("Выпало ровным счетом ничего....")


func _calculate_rarity(type: Util.EnemyType, luck_value: float):
	if not drop_tables.has(type):
		return null
	var config: DropTableData = drop_tables[type]
	if luck_value > 100.0:
		luck_value = 100.0
	var multiplier: float = 1.0 + (luck_value / 50.0)
	var w_mayhem = config.mayhem_weight * multiplier
	var w_legendary = config.legendary_weight * multiplier
	var w_rare = config.rare_weight * multiplier
	var roll = randf_range(0.0, TOTAL_WEIGHT)
	var cursor: float = 0.0
	cursor += w_mayhem
	if roll < cursor:
		return Util.ArtefactRarity.MAYHEM
	cursor += w_legendary
	if roll < cursor:
		return Util.ArtefactRarity.LEGENDARY
	cursor += w_rare
	if roll < cursor:
		return Util.ArtefactRarity.RARE
	return null
