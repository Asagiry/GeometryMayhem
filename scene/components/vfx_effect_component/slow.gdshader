shader_type canvas_item;

uniform vec4 slow_color : source_color = vec4(0.2, 0.5, 0.8, 1.0); // Серо-голубой цвет
uniform float intensity : hint_range(0.0, 1.0) = 0.6; // Сила закрашивания

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Если пиксель прозрачный, пропускаем
	if (tex_color.a < 0.01) {
		discard;
	}

	// 1. Обесцвечивание (Desaturation)
	// Формула яркости: 0.299 R + 0.587 G + 0.114 B
	float grey = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 greyscale = vec3(grey);

	// 2. Смешиваем обесцвеченный спрайт с цветом замедления
	vec3 mixed_color = mix(tex_color.rgb, slow_color.rgb * greyscale, intensity);

	COLOR = vec4(mixed_color, tex_color.a);
}