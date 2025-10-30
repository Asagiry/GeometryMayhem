class_name Effect

extends Resource

var effect_type: Util.EffectType = Util.EffectType.NONE
var behavior: Util.EffectBehavior = Util.EffectBehavior.NONE

var damage: DamageData
var stat_modifiers: StatModifierData
var duration: float = 0.0
var tick_interval: float = 1.0
var positivity: Util.EffectPositivity = Util.EffectPositivity.NONE
var percent: float
var source
var behavior_script: Script
