shader_type canvas_item;

// Основные параметры
uniform float fade_time : hint_range(0.0, 1.0) = 1.0;
uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform vec4 trail_color : source_color = vec4(0.4, 0.8, 1.2, 0.6);
uniform vec4 core_color : source_color = vec4(0.8, 1.0, 1.5, 1.0);

// Эффекты
uniform sampler2D noise_tex : hint_default_black;
uniform float pulse_speed = 3.0;

// Параметры формы
uniform float core_width = 0.05;
uniform float glow_width = 0.4;
uniform float edge_softness = 0.5;

void fragment() {
    vec2 uv = vec2(UV.y, UV.x);

    // --- ЭФФЕКТ ВТЯГИВАНИЯ ---
    // Чем меньше fade_time, тем ближе uv.y стягивается к центру
    float pull_strength = pow(1.0 - fade_time, 1.2) * 0.45; // регулируй силу "втягивания"
    uv.y = mix(uv.y, 0.5, pull_strength);

    // Расстояние до центра
    float dist_to_center = abs(uv.y - 0.5);

    // Мягкая пульсация
    float pulse = sin(TIME * pulse_speed) * 0.2 + 0.8;

    // Очень плавное затухание (дольше держится, медленно гаснет)
    float smooth_fade = pow(fade_time, 1.5); // замедляем исчезновение
    float reverse_fade = 1.0 - smooth_fade;

    // Схлопывание градиентов
    float glow_shrink = mix(glow_width, 0.0, pow(reverse_fade, 0.5));
    float core_shrink = mix(core_width, 0.001, pow(reverse_fade, 1.4));

    // Маски для ядра и свечения
    float core_mask = 1.0 - smoothstep(0.0, core_shrink, dist_to_center);
    float glow_mask = 1.0 - smoothstep(core_shrink, glow_shrink, dist_to_center);

    // Мягкость краёв полигона
    float edge_fade = smoothstep(0.5, 0.5 - edge_softness, dist_to_center);

    // Шумовое движение
    vec2 noise_uv = uv * vec2(6.0, 16.0) + TIME * 1.5;
    float noise = texture(noise_tex, noise_uv).r * 0.3 + 0.7;

    // Цветовая смесь
    vec4 final_color = vec4(0.0);
    final_color += core_color * core_mask * pulse * intensity * noise;
    final_color += trail_color * glow_mask * pulse * 0.9 * intensity * noise * smooth_fade;

    // Затухание по длине (вдоль X)
    float length_fade = smoothstep(0.0, 0.05, uv.x) * smoothstep(1.0, 0.95, uv.x);

    // Альфа — очень мягкое исчезновение
    float alpha = smoothstep(0.0, 0.8, smooth_fade) * length_fade * edge_fade;
    final_color.a *= alpha;

    COLOR = final_color;
}
