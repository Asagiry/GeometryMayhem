class_name PlayerStatModifierData

extends StatModifierData

@export var parry_duration_multiplier: float = DEFAULT_MULTIPLIER

func _init(
	p_parry_duration_multiplier: float = DEFAULT_MULTIPLIER,
	p_speed_multiplier: float = DEFAULT_MULTIPLIER,
	p_attack_multiplier: float = DEFAULT_MULTIPLIER,
	p_armor_multiplier: float = DEFAULT_MULTIPLIER,
	p_forward_receiving_damage_multiplier: float = DEFAULT_MULTIPLIER,
	p_attack_cd_multiplier: float = DEFAULT_MULTIPLIER,
	p_attack_duration_multiplier: float = DEFAULT_MULTIPLIER,
	p_invulnerable: bool = false,
	p_percent_of_max_health: float = DEFAULT_MULTIPLIER,
	p_freeze_multiplier: float = DEFAULT_MULTIPLIER
) -> void:
	super(
		p_speed_multiplier,
		p_attack_multiplier,
		p_armor_multiplier,
		p_forward_receiving_damage_multiplier,
		p_attack_cd_multiplier,
		p_attack_duration_multiplier,
		p_invulnerable,
		p_percent_of_max_health,
		p_freeze_multiplier
	)

	parry_duration_multiplier = p_parry_duration_multiplier

func reset() -> void:
	parry_duration_multiplier = DEFAULT_MULTIPLIER
	super.reset()


func set_parry_duration_multiplier(value: float) -> void:
	parry_duration_multiplier = clampf(value, MIN_MULTIPLIER, MAX_MULTIPLIER)
