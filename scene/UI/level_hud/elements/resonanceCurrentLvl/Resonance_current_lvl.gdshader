shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec3 start_color : source_color = vec3(1.0);
uniform vec3 end_color: source_color = vec3(1.0);

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    vec4 output_color = vec4(0.0, 0.0, 0.0, 0.0); // по умолчанию — прозрачный

    // Только если пиксель не прозрачный — обрабатываем
    if (base_color.a > 0.0) {
        vec2 center = vec2(0.5, 0.5);
        vec2 to_pixel = UV - center;
        float angle = atan(to_pixel.y, to_pixel.x);
        if (angle < 0.0) {
            angle += 2.0 * PI;
        }

        float start_angle = PI - PI / 3.0;
        float end_angle = start_angle + progress * PI/2.0 * PI;
        if (end_angle > 2.0 * PI) {
            end_angle -= 2.0 * PI;
        }

        bool is_filled = false;
        if (progress == 1.0) {
            is_filled = true;
        } else if (start_angle <= end_angle) {
            is_filled = angle >= start_angle && angle <= end_angle;
        } else {
            is_filled = angle >= start_angle || angle <= end_angle;
        }

        if (is_filled) {
            vec3 fill_color = mix(start_color, end_color, progress);
            output_color = vec4(fill_color, base_color.a);
        }
    }

    COLOR = output_color;
}