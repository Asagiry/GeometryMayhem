shader_type canvas_item;

uniform vec4 rupture_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Ярко-алая кровь
uniform float intensity : hint_range(0.0, 1.0) = 0.7;
uniform float speed : hint_range(0.0, 20.0) = 10.0; // Очень быстрое движение
uniform float shake_power : hint_range(0.0, 0.1) = 0.03; // Сила дрожания спрайта

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

void fragment() {
    // 1. Эффект дрожания (Vibration/Pain)
    // Смещаем координаты чтения текстуры хаотично
    vec2 shake_offset = vec2(
        noise(vec2(TIME * 20.0, UV.y)),
        noise(vec2(UV.x, TIME * 15.0))
    );
    // Сдвиг должен быть около нуля (-0.5, 0.5)
    shake_offset -= 0.5;

    // Применяем искажение к UV
    vec2 distorted_uv = UV + shake_offset * shake_power;

    vec4 tex_color = texture(TEXTURE, distorted_uv);

    // Если вышли за границы текстуры при тряске или пиксель прозрачный
    if (tex_color.a < 0.01 || distorted_uv.x < 0.0 || distorted_uv.x > 1.0 || distorted_uv.y < 0.0 || distorted_uv.y > 1.0) {
        discard;
    }

    // 2. Эффект "Кипения" крови
    // Генерируем быстрый высокочастотный шум
    float blood_noise = noise(UV * 8.0 + vec2(TIME * speed * 0.1, sin(TIME * speed) * 0.5));

    // Делаем шум контрастным (пятна крови)
    float blood_mask = step(0.4, blood_noise);

    // 3. Пульсация интенсивности (как выброс давления)
    float pulse = sin(TIME * 15.0) * 0.5 + 0.5; // Быстрая пульсация
    float current_intensity = intensity * (0.8 + 0.2 * pulse);

    // Смешивание
    vec3 final_color = mix(tex_color.rgb, rupture_color.rgb, blood_mask * current_intensity);

    // Добавляем немного темноты по краям пятен крови для объема
    if (blood_mask > 0.0) {
        float edge = smoothstep(0.4, 0.5, blood_noise);
        final_color *= 0.8 + 0.2 * edge;
    }

    COLOR = vec4(final_color, tex_color.a);
}