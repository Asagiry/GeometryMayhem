shader_type canvas_item;

// Сила эффекта. Чем больше, тем больше изображение перекрывается помехами.
uniform float intensity : hint_range(0.0, 1.0) = 0.7;
// Скорость движения полос
uniform float speed : hint_range(0.0, 20.0) = 5.0;

// Функция случайности (шум)
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (tex_color.a < 0.01) {
		discard;
	}

	// 1. Полное обесцвечивание (Greyscale)
	// Превращаем исходный цвет в оттенки серого. Это база для эффекта "отключения".
	float grey = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 base_color = vec3(grey);

	// 2. Генерация жесткого статического шума
	// Временной сдвиг очень быстрый для эффекта "снега"
	float noise_val = random(UV + vec2(TIME * 50.0, TIME * 100.0));
	// step(0.5, noise_val) делает шум контрастным: только 0.0 (черный) или 1.0 (белый)
	vec3 static_noise = vec3(step(0.5, noise_val));

	// 3. Генерация полос сканирования (Рябь)
	// Используем синус от Y-координаты и времени для создания движущихся горизонтальных полос.
	// Число 30.0 влияет на количество полос.
	float scanline = sin(UV.y * 30.0 + TIME * speed);
	// Преобразуем диапазон синуса [-1, 1] в более резкую маску [0, 1]
	scanline = smoothstep(0.3, 0.7, scanline * 0.5 + 0.5);

	// 4. Комбинирование
	// Создаем маску интерференции: полосы * интенсивность.
	float interference_mask = scanline * intensity;

	// Смешиваем:
	// Там, где нет полос, мы видим просто черно-белый спрайт (base_color).
	// Там, где проходит полоса, изображение заменяется жестким статическим шумом (static_noise).
	vec3 final_rgb = mix(base_color, static_noise, interference_mask);

	// Дополнительно можно сделать изображение чуть темнее в целом, чтобы усилить негативный эффект
	final_rgb *= 0.9;

	COLOR = vec4(final_rgb, tex_color.a);
}