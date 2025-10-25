shader_type canvas_item;

uniform float fade_time : hint_range(0.0, 1.0) = 1.0;
uniform vec4 trail_color : source_color = vec4(0.6, 0.2, 1.0, 1.0);
uniform float distortion_strength = 0.03;
uniform sampler2D noise_tex : hint_default_black;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = UV;

    // Плавное затухание по длине
    float fade = smoothstep(1.0, 0.0, uv.x);

    // Добавляем шум для живости
    float noise = texture(noise_tex, uv * 3.0 + TIME * 0.5).r;
    fade *= mix(0.9, 1.1, noise);

    // Искажение фона
    vec2 screen_uv = SCREEN_UV + (noise - 0.5) * distortion_strength;
    vec4 screen_color = texture(screen_tex, screen_uv);

    // Смешиваем с цветом следа
    vec4 color = mix(screen_color, trail_color, fade * fade_time);
    color.a *= fade * fade_time;

    COLOR = color;
}
