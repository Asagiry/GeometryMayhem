shader_type canvas_item;

// Цвета
uniform vec4 ice_color : source_color = vec4(0.0, 0.4, 0.9, 0.8); // Глубокий синий
uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 0.6); // Блеск (чуть ярче)

// Настройки
uniform float speed : hint_range(0.0, 5.0) = 1.0; 
uniform float scale : hint_range(1.0, 50.0) = 20.0; 
uniform float start_time;

// Функция случайности
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Функция шума
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

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (tex_color.a < 0.01) {
		discard;
	}

	float local_time = TIME - start_time;
	
	// Прогресс от 0.0 до 1.0
	float progress = clamp(local_time * speed * 0.2, 0.0, 1.0);

	// Получаем значение шума для пикселя
	float noise_val = noise(UV * scale);
	
	// ЛОГИКА ЗАПОЛНЕНИЯ
	float ice_amount = step(noise_val, progress);

	// Смешивание
	vec3 final_color = tex_color.rgb;

	// Накладываем синий цвет
	vec3 icy_overlay = mix(final_color, ice_color.rgb, 0.75); 
	final_color = mix(final_color, icy_overlay, ice_amount);
	
	// Блеск (ИСПРАВЛЕННЫЙ)
	if (ice_amount > 0.0) {
		// 1. Увеличили масштаб до 50.0 (было 10.0), чтобы разбить "белый кусок" на пыль
		// 2. Увеличили скорость времени немного, чтобы они мерцали
		float shine_noise = noise(UV * 50.0 + vec2(TIME * 0.1));
		
		// 3. Подняли порог до 0.9 (было 0.8), чтобы искорки были редкими точками
		float shine = step(0.9, shine_noise); 
		
		// Добавляем блеск
		final_color += shine_color.rgb * shine * 0.5;
	}

	COLOR = vec4(final_color, tex_color.a);
}