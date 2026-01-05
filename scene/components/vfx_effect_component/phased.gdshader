shader_type canvas_item;

uniform vec4 phase_color : source_color = vec4(0.7, 0.3, 1.0, 1.0); // Фиолетовый/Призрачный
uniform float intensity : hint_range(0.0, 1.0) = 0.5; // Сила окрашивания
uniform float speed : hint_range(0.0, 10.0) = 3.0; // Скорость анимации

void fragment() {
	// 1. Эффект "Фазового сдвига" (Jitter)
	// Смещаем UV координаты по горизонтали с помощью синуса.
	// Это создает эффект, будто спрайт рябит или двоится.
	float jitter = sin(UV.y * 30.0 + TIME * speed) * 0.01;
	vec2 distorted_uv = vec2(UV.x + jitter, UV.y);

	vec4 tex_color = texture(TEXTURE, distorted_uv);

	if (tex_color.a < 0.01) {
		discard;
	}

	// 2. Прозрачность (Призрачность)
	// Делаем спрайт полупрозрачным.
	// Добавляем пульсацию прозрачности, чтобы он "мигал".
	float ghost_alpha = 0.7 + 0.1 * sin(TIME * 5.0);

	// 3. Цвет
	// Смешиваем с фиолетовым
	vec3 final_color = mix(tex_color.rgb, phase_color.rgb, intensity);

	// Добавляем свечение на "гребнях" волны искажения
	float scanline = sin(UV.y * 30.0 + TIME * speed);
	if (scanline > 0.9) {
		final_color += phase_color.rgb * 0.5;
	}

	COLOR = vec4(final_color, tex_color.a * ghost_alpha);
}