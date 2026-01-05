shader_type canvas_item;

uniform vec4 curse_color : source_color = vec4(0.4, 0.0, 0.6, 1.0); // Темно-фиолетовый
uniform float intensity : hint_range(0.0, 1.0) = 0.7; // Сила эффекта
uniform float frequency : hint_range(0.1, 10.0) = 2.0; // Скорость пульсации

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Пропускаем прозрачные пиксели
	if (tex_color.a < 0.01) {
		discard;
	}

	// Создаем пульсацию, используя синус от времени
	// Это заставляет сущность "светиться" зловещим светом то ярче, то темнее
	float pulse = sin(TIME * frequency) * 0.5 + 0.5; // диапазон от 0.0 до 1.0

	// Делаем пульсацию не полной, а мягкой (от 0.5 до 1.0)
	float pulse_factor = mix(0.5, 1.0, pulse);

	// Смешиваем оригинальный цвет с цветом проклятия
	// intensity * pulse_factor определяет, насколько сильно спрайт окрашен
	vec3 mixed_color = mix(tex_color.rgb, curse_color.rgb, intensity * pulse_factor);

	// Немного затемняем итоговый цвет, чтобы передать атмосферу "ослабления"
	// (Curse обычно делает цель темнее/мрачнее)
	mixed_color *= 0.9;

	COLOR = vec4(mixed_color, tex_color.a);
}