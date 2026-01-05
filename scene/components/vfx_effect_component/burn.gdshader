shader_type canvas_item;

// Настройки цвета огня
uniform vec4 burn_color : source_color = vec4(1.0, 0.4, 0.0, 1.0); // Оранжевый
uniform float intensity : hint_range(0.0, 1.0) = 0.5; // Сила смешивания
uniform float speed = 4.0;

// Простая функция шума внутри шейдера
float random (vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Если пиксель прозрачный - не обрабатываем его
	if (tex_color.a < 0.01) {
		discard;
	}

	// Генерируем шум на основе координат и времени
	// noise_uv сдвигается вверх (TIME * speed), имитируя подъем огня
	vec2 noise_uv = UV + vec2(0.0, TIME * 0.5);
	float noise = random(floor(noise_uv * 20.0)); // "Блочный" шум пиксель-арта

	// Пульсация
	float pulse = sin(TIME * speed) * 0.2 + 0.8;

	// Смешивание
	// Мы берем оригинальный цвет и подмешиваем к нему цвет огня там, где шум яркий
	vec3 final_rgb = mix(tex_color.rgb, burn_color.rgb, intensity * pulse * noise);

	COLOR = vec4(final_rgb, tex_color.a);
}