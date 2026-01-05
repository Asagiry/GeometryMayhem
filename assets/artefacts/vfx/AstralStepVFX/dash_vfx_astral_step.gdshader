shader_type canvas_item;

// Настройки цвета
uniform vec4 core_color : source_color = vec4(0.5, 0.8, 1.0, 1.0);
uniform vec4 edge_color : source_color = vec4(0.2, 0.0, 0.5, 1.0);
uniform float brightness : hint_range(1.0, 10.0) = 5.0; // Твой множитель яркость

// Настройки эффекта
uniform float beam_width : hint_range(0.0, 1.0) = 0.4;
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0;

// Технические параметры
uniform sampler2D noise_texture : repeat_enable, filter_linear;
uniform float aspect_ratio = 1.0;
uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = UV;
	
	// 1. Корректируем UV и Шум
	vec2 noise_uv = vec2(uv.x, uv.y * aspect_ratio);
	noise_uv.y -= TIME * 0.5;
	float noise_val = texture(noise_texture, noise_uv * 0.5).r;
	
	// 2. Форма луча
	float dist_from_center = abs(uv.x - 0.5);
	float beam_mask = smoothstep(0.5, beam_width, dist_from_center);
	
	// 3. Растворение (Erosion)
	float erosion = smoothstep(progress, progress + 0.2, noise_val * beam_mask);
	erosion *= smoothstep(0.5, 0.0, dist_from_center * progress * 2.0);
	
	// 4. Расчет ЦВЕТА (RGB)
	// Смешиваем цвета
	vec3 mixed_rgb = mix(edge_color.rgb, core_color.rgb, erosion);
	
	// Применяем все усилители яркости сразу
	// glow_intensity - для базового свечения
	// brightness - для "взрыва" в HDR (чтобы пробить белый фон)
	vec3 final_rgb = mixed_rgb * glow_intensity * brightness;
	
	// 5. Расчет ПРОЗРАЧНОСТИ (Alpha)
	float final_alpha = erosion * (1.0 - progress);

	// 6. ИТОГ: Собираем vec3 и float в один vec4
	COLOR = vec4(final_rgb, final_alpha);
}