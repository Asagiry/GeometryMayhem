shader_type canvas_item;

uniform vec4 regen_color : source_color = vec4(0.2, 1.0, 0.4, 1.0); // Ярко-зеленый
uniform float speed : hint_range(0.5, 10.0) = 3.0; // Скорость движения полос
uniform float intensity : hint_range(0.0, 1.0) = 0.5; // Сила эффекта
uniform float frequency : hint_range(1.0, 20.0) = 10.0; // Количество полос

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (tex_color.a < 0.01) {
		discard;
	}

	// Создаем волну, движущуюся вверх (поэтому + TIME)
	// UV.y идет от 0 (верх) до 1 (низ), инвертируем или складываем
	float wave = sin(UV.y * frequency + TIME * speed);

	// Приводим волну к диапазону 0.0 - 1.0 и делаем ее более резкой для эффекта "сканирования"
	wave = (wave + 1.0) * 0.5;

	// Применяем степень, чтобы сделать полосы тоньше, а промежутки больше
	float bands = pow(wave, 3.0);

	// Смешиваем
	vec3 mixed_color = mix(tex_color.rgb, regen_color.rgb, bands * intensity);

	COLOR = vec4(mixed_color, tex_color.a);
}