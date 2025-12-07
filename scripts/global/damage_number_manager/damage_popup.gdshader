shader_type canvas_item;
render_mode unshaded;

// Цвета градиента. По умолчанию белый верх, светло-серый низ.
uniform vec4 color_top : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.9, 0.9, 0.9, 1.0);

void fragment() {
	// Получаем альфа-канал текстуры шрифта (форму букв)
	vec4 text_texture = texture(TEXTURE, UV);
	
	// Создаем вертикальный градиент на основе координаты UV.y (от 0 сверху до 1 снизу)
	vec4 gradient_color = mix(color_top, color_bottom, UV.y);
	
	// Финальный цвет:
	// 1. Берем градиент.
	// 2. Применяем альфу от текстуры шрифта (чтобы красились только буквы).
	// 3. Умножаем на COLOR (это modulate узла, нужно для анимации исчезновения).
	COLOR = gradient_color * vec4(1.0, 1.0, 1.0, text_texture.a) * COLOR;
}