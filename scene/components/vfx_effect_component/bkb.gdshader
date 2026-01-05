shader_type canvas_item;

uniform vec4 bkb_color : source_color = vec4(1.0, 0.7, 0.0, 1.0); // Насыщенный золотой
uniform vec4 energy_color : source_color = vec4(0.8, 0.5, 0.0, 1.0); // Темное золото для контраста
uniform float scale_factor : hint_range(1.0, 1.5) = 1.15; // Увеличение размера (1.15 = +15%)
uniform float spin_speed : hint_range(0.0, 10.0) = 2.0;

// Функция случайности
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Шум
float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    vec2 u = f * f * (3.0 - 2.0 * f);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// ВЕРШИННЫЙ ШЕЙДЕР: Изменяет геометрию/размер спрайта
void vertex() {
	// Увеличиваем размер вершин относительно центра
	VERTEX *= scale_factor;
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (tex_color.a < 0.01) {
		discard;
	}

	// Создаем эффект "крутящейся энергии"
	// Смешиваем UV с временем
	vec2 movement = vec2(TIME * 0.5, TIME * spin_speed);
	float energy_noise = noise(UV * 5.0 + movement);
	
	// Создаем контраст
	energy_noise = smoothstep(0.3, 0.7, energy_noise);

	// Смешиваем два оттенка золота на основе шума
	vec3 gold_effect = mix(bkb_color.rgb, energy_color.rgb, energy_noise);

	// Накладываем это на спрайт. 
	// В BKB спрайт обычно становится полностью золотым (силуэтом), теряя оригинальные цвета.
	// mix(оригинал, золото, 0.9) -> почти полностью заменяем цвет
	vec3 final_color = mix(tex_color.rgb, gold_effect, 0.9);
	
	// Добавляем свечение по краям (Rim Light), чтобы подчеркнуть магию
	// (Упрощенная имитация через альфу текстуры не получится идеально в 2D, 
	// но можно добавить яркости)
	final_color *= 1.1;

	COLOR = vec4(final_color, tex_color.a);
}