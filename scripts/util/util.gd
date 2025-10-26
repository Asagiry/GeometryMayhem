class_name Util

extends Resource

#Эффекта на рассмотрении
#STUN, ROOT, FREEZE, REFLECT
#CURSE - прямое повышение входящего урона %.
#ARMOR_DEBUFF - умньшение армора %
#MAGICAL_RESISTANCE_DEBUFF - уменьшение магического сопротивления %

enum EffectType {
	NONE,
	SLOW, CURSE, ARMOR_DEBUFF, MAGICAL_RESISTANCE_DEBUFF, #DEBUFF
	PHYSICAL_DAMAGE_REDUCTION, MAGICAL_DAMAGE_REDUCTION,

	SILENCE, BLIND, #PLAYER SPECIAL DEBUFF

	BURN, POISON, BLEED, # DOT

	FEAR, # SPECIAL EFFECT

	sT, #PLAYER BUFF
	REGENERATION, INVULNERABLE, CRIT_RATE_UP, COOLDOWN_REDUCTION,
}

enum EffectBehavior{
	NONE,
	INSTANT,
	DOT,
	BUFF,
	DEBUFF,
}

enum DamageCategory {
	NONE,
	PHYSICAL,
	MAGICAL,
	TRUE
}

enum ArtefactRarity {
	COMMON,
	RARE,
	LEGENDARY,
	MYTHIC,
	MAYHEM,
}
