shader_type canvas_item;

uniform vec4 bleed_color : source_color = vec4(0.8, 0.0, 0.0, 1.0); // Глубокий красный
uniform float intensity : hint_range(0.0, 1.0) = 0.7;
uniform float speed : hint_range(0.0, 10.0) = 1.0;

// Функция шума
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (tex_color.a < 0.01) {
		discard;
	}

	// 1. Эффект стекания вниз
	// Смещаем UV по Y вниз со временем
	vec2 drip_uv = UV + vec2(0.0, -TIME * speed * 0.2);

	// Генерируем "пятна" крови
	float noise = random(floor(drip_uv * 10.0)); // Крупные "пиксельные" капли

	// 2. Эффект пульсации (Сердцебиение)
	// Кровотечение часто ассоциируется с ударами сердца
	float heartbeat = sin(TIME * 5.0) * 0.5 + 0.5; // Быстрый ритм

	// Комбинируем: шум делает пятна, heartbeat заставляет их пульсировать
	float mask = noise * heartbeat;

	// Смешиваем
	vec3 mixed_color = mix(tex_color.rgb, bleed_color.rgb, mask * intensity);

	COLOR = vec4(mixed_color, tex_color.a);
}