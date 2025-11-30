class_name Util

extends Resource

enum AttackType {
	SEQUENTIAL,
	PARALLEL,
}

enum Zone {
	STABILITY,
	FLUX,
	OVERLOAD,
	CHAOTIC,
}

enum EffectType {
	NONE,
	SLOW, CURSE, CORROSION, #CLASSIC DEBUFF
	BURN, BLEED, # DOT
	FEAR, SILENCE, BLIND, COLLIDER, FREEZE, RUPTURE, # SPECIAL EFFECT
	PHASED, BKB, EXPLOSION, WOUNDED,
	DISPEL,  #INSTANT SPECIAL
	REGENERATION, SONIC, FORTIFY, #BUFF
}

enum EffectBehavior {
	NONE,
	INSTANT,
	DOT,
	BUFF,
	DEBUFF,
	SPECIAL,
}

enum EffectPositivity {
	NONE,
	POSITIVE,
	NEGATIVE,
}

enum DamageCategory {
	NONE,
	DEFAULT,
	TRUE
}

enum ArtefactRarity {
	COMMON,
	RARE,
	LEGENDARY,
	MYTHIC,
	MAYHEM,
}

enum EnemyType {
	NORMAL,
	AMPLIFIED,
	DISTORTED,
	ANOMALY,
	BOSS,
}

const EFFECT_NAMES = {
	EffectType.NONE: "None",
	EffectType.SLOW: "Slow",
	EffectType.CURSE: "Curse",
	EffectType.CORROSION: "Corrosion",
	EffectType.BURN: "Burn",
	EffectType.BLEED: "Bleed",
	EffectType.FEAR: "Fear",
	EffectType.SILENCE: "Silence",
	EffectType.BLIND: "Blind",
	EffectType.COLLIDER: "Collider",
	EffectType.FREEZE: "Freeze",
	EffectType.RUPTURE: "Rupture",
	EffectType.PHASED: "Phased",
	EffectType.BKB: "Bkb",
	EffectType.EXPLOSION: "Explosion",
	EffectType.DISPEL: "Dispel",
	EffectType.REGENERATION: "Regeneration",
	EffectType.SONIC: "Sonic",
	EffectType.FORTIFY: "Fortify",
	EffectType.WOUNDED: "Wounded",
}

const EFFECT_BEHAVIOR_NAMES = {
	EffectBehavior.NONE: "None",
	EffectBehavior.INSTANT: "Instant",
	EffectBehavior.DOT: "Dot",
	EffectBehavior.BUFF: "Buff",
	EffectBehavior.DEBUFF: "Debuff",
	EffectBehavior.SPECIAL: "Special"
}

const DAMAGE_CATEGORY_NAMES = {
	DamageCategory.NONE: "None",
	DamageCategory.DEFAULT: "Default",
	DamageCategory.TRUE: "True"
}

const ARTEFACT_RARITY_NAMES = {
	ArtefactRarity.COMMON: "Common",
	ArtefactRarity.RARE: "Rare",
	ArtefactRarity.LEGENDARY: "Legendary",
	ArtefactRarity.MYTHIC: "Mythic",
	ArtefactRarity.MAYHEM: "Mayhem"
}

# Геттеры
static func get_effect_name(effect_type: EffectType) -> String:
	return EFFECT_NAMES.get(effect_type, "Unknown")


static func get_effect_behavior_name(behavior: EffectBehavior) -> String:
	return EFFECT_BEHAVIOR_NAMES.get(behavior, "Unknown")


static func get_damage_category_name(category: DamageCategory) -> String:
	return DAMAGE_CATEGORY_NAMES.get(category, "Unknown")


static func get_artefact_rarity_name(rarity: ArtefactRarity) -> String:
	return ARTEFACT_RARITY_NAMES.get(rarity, "Unknown")
