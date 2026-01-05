shader_type canvas_item;

uniform vec4 fortify_color : source_color = vec4(1.0, 0.8, 0.2, 1.0); // Золотой/Оранжевый
uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Белый блик
uniform float speed : hint_range(0.0, 5.0) = 1.0; // Скорость пробегания блика
uniform float intensity : hint_range(0.0, 1.0) = 0.5; // Сила золотого окраса

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (tex_color.a < 0.01) {
		discard;
	}

	// 1. Золотой окрас (Укрепление)
	// Смешиваем оригинальный цвет с золотым, чтобы показать "броню"
	vec3 final_color = mix(tex_color.rgb, fortify_color.rgb, intensity);

	// 2. Диагональный блик (Sheen)
	// Создаем диагональную полосу (UV.x + UV.y)
	float pos = UV.x + UV.y;

	// Анимируем полосу. mod(..., 4.0) создает паузу между бликами.
	float movement = mod(TIME * speed, 4.0) - 1.0; // -1.0 чтобы начиналось за пределами спрайта

	// Рисуем полосу шириной примерно 0.4
	// Используем smoothstep для мягких краев
	float shine = smoothstep(movement, movement + 0.2, pos) - smoothstep(movement + 0.4, movement + 0.6, pos);

	// Ограничиваем блик (чтобы не уходил в минус)
	shine = max(0.0, shine);

	// 3. Добавляем блик к цвету (Additive mixing)
	// tex_color.a нужен, чтобы блик не рисовался на прозрачном фоне (если вдруг discard не сработал)
	final_color += shine_color.rgb * shine * 0.8;

	COLOR = vec4(final_color, tex_color.a);
}