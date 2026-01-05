shader_type canvas_item;

uniform vec4 wounded_color : source_color = vec4(0.4, 0.05, 0.05, 1.0); // Темно-бордовый
uniform float intensity : hint_range(0.0, 1.0) = 0.9; // Чуть увеличил общую силу
// УМЕНЬШИЛ дефолтный скейл, чтобы трещины были крупнее по размеру
uniform float crack_scale : hint_range(1.0, 20.0) = 4.0; 

// НОВЫЙ ПАРАМЕТР: Толщина линий трещин. Чем больше, тем жирнее рана.
uniform float crack_thickness : hint_range(0.05, 0.5) = 0.25;
// НОВЫЙ ПАРАМЕТР: Насколько сильно затемнять "дно" раны (меньше = темнее)
uniform float darken_factor : hint_range(0.0, 1.0) = 0.4;

// Функция случайности
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (tex_color.a < 0.01) {
		discard;
	}

	// Генерируем "клетки" для трещин
	vec2 scaled_uv = UV * crack_scale;
	vec2 cell_id = floor(scaled_uv);
	
	// Получаем случайное значение для каждой клетки
	float noise = random(cell_id);
	
	float cracks = 0.0;
	
	// Проверка "границ" через дробную часть UV
	vec2 cell_uv = fract(scaled_uv);
	
	// Рисуем диагональные линии.
	// ИЗМЕНЕНИЕ: Используем crack_thickness вместо жесткого числа 0.1
	if (abs(cell_uv.x - cell_uv.y + noise) < crack_thickness) {
		cracks = 1.0;
	}
	
	// Добавляем немного дрожания (эффект боли/шока)
	float shake = random(vec2(TIME * 10.0, 0.0)) * 0.05;
	if (cracks > 0.0) cracks += shake;

	// Смешиваем основной цвет с цветом ранения
	vec3 mixed_color = mix(tex_color.rgb, wounded_color.rgb, cracks * intensity);
	
	// Делаем трещины темнее оригинала, чтобы они выглядели глубокими.
	// ИЗМЕНЕНИЕ: Используем darken_factor для контроля глубины.
	if (cracks > 0.5) {
		mixed_color *= darken_factor;
	}

	COLOR = vec4(mixed_color, tex_color.a);
}