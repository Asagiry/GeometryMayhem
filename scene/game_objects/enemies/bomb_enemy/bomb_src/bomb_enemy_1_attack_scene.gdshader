shader_type canvas_item;

uniform sampler2D curve;
uniform float strength : hint_range(-1.0, 1.0) = 0.5;
uniform float time : hint_range(0.0, 2.0) = 0.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 vecToCenter = vec2(0.5, 0.5) - UV;
	float distToCenter = length(vecToCenter);
	
	// Фазы: черная дыра (0.0-0.5) → волны (0.4-1.5) → затухание (1.5-2.0)
	float black_hole = smoothstep(0.0, 0.3, time) * (1.0 - smoothstep(0.3, 0.5, time));
	float waves = smoothstep(0.4, 0.8, time) * (1.0 - smoothstep(1.2, 1.5, time));
	
	// Базовое искажение
	float curveVal = texture(curve, vec2(distToCenter)).r;
	
	// Усиление черной дыры
	float suck_power = black_hole * strength * 2.0 * (1.0 - distToCenter);
	
	// Волны
	float wave_power = waves * sin(distToCenter * 60.0 - time * 10.0) * 0.015;
	
	// Комбинированное смещение
	vec2 diff = normalize(vecToCenter) * (curveVal * strength + suck_power + wave_power);
	
	// Черный центр
	float black_center = smoothstep(0.0, 0.08, 0.12 - distToCenter);
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV - diff);
	col.rgb = mix(col.rgb, vec3(0.0), black_center * black_hole);
	
	// Затухание
	col.a *= 1.0 - smoothstep(1.5, 2.0, time);
	
	COLOR = col;
}