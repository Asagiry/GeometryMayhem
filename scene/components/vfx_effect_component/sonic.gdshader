shader_type canvas_item;

uniform vec4 sonic_color : source_color = vec4(0.0, 0.8, 1.0, 1.0); // Электрический голубой/циан
uniform float speed : hint_range(0.0, 20.0) = 10.0; // Скорость движения линий
uniform float intensity : hint_range(0.0, 1.0) = 0.5; // Яркость линий

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (tex_color.a < 0.01) {
		discard;
	}

	// Создаем полосы, бегущие горизонтально (вдоль оси X)
	// Используем синус от Y координаты, чтобы линии были разной толщины
	float lines = sin(UV.y * 50.0 + TIME * speed * 2.0);

	// Оставляем только узкие полоски (делаем маску резкой)
	lines = smoothstep(0.8, 1.0, lines);

	// Добавляем "разрывы" в линиях, чтобы они не были сплошными (как ветер)
	float noise = sin(UV.x * 20.0 - TIME * speed);
	lines *= step(0.5, noise);

	// Смешиваем оригинал с цветом Соника
	// Добавляем (Additive mixing) для эффекта свечения
	vec3 final_color = tex_color.rgb + (sonic_color.rgb * lines * intensity);

	// Немного осветляем весь спрайт, чтобы показать "заряженность"
	final_color += sonic_color.rgb * 0.1;

	COLOR = vec4(final_color, tex_color.a);
}