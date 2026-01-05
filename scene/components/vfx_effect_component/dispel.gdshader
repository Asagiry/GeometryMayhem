shader_type canvas_item;

// Используем ядовито-зеленый
uniform vec4 dispel_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); 
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float density : hint_range(0.0, 1.0) = 0.4; // ОЧЕНЬ жирное кольцо (40% спрайта)

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (tex_color.a < 0.01) {
		discard;
	}

	float dist = distance(UV, vec2(0.5));
	
	// Радиус расширения (чуть больше 1.0, чтобы точно ушло за край)
	float max_radius = 1.2; 
	float current_outer = progress * max_radius;
	float current_inner = current_outer - density;
	
	// 1. ЖЕСТКОЕ КОЛЬЦО
	// Проверяем попадание в кольцо
	float ring = step(current_inner, dist) * step(dist, current_outer);
	
	// 2. ВСПЫШКА (FLASH)
	// Теперь вспышка длится первые 20% времени анимации (0.2 секунды из 1.0)
	// В это время спрайт будет ПОЛНОСТЬЮ зеленым.
	float flash = step(progress, 0.2); 

	// 3. СБОРКА ЦВЕТА
	vec3 final_color = tex_color.rgb;
	
	// Если вспышка активна - полностью заливаем зеленым
	final_color = mix(final_color, dispel_color.rgb, flash); 
	
	// Если идет кольцо - тоже заливаем зеленым
	final_color = mix(final_color, dispel_color.rgb, ring);

	// 4. Белая обводка по внешнему краю для контраста
	float rim = step(current_outer - 0.03, dist) * step(dist, current_outer);
	final_color += vec3(1.0) * rim;

	COLOR = vec4(final_color, tex_color.a);
}