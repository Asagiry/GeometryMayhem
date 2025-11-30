shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec3 fill_color : source_color = vec3(1.0, 0.0, 0.0);

const vec3 TARGET_COLOR = vec3(86.0 / 255.0); // #565656

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec4 out_color = tex;

    if (tex.a > 0.1 && distance(tex.rgb, TARGET_COLOR) < 0.05) {

        vec2 center = vec2(0.5, 0.5);
        vec2 to_pixel = UV - center;
        float angle = atan(to_pixel.y, to_pixel.x);
        if (angle < 0.0) angle += 2.0 * PI;

        // <<< NEW: progress scaled so that 1.0 behaves like old 0.8
        float p = progress * 0.8;

        float start_angle = PI - PI / 3.0;
        float end_angle = start_angle + p * 2.0 * PI;
        if (end_angle > 2.0 * PI) end_angle -= 2.0 * PI;

        bool is_filled = false;

        if (p >= 0.999) {
            is_filled = true;
        } else if (start_angle <= end_angle) {
            is_filled = angle >= start_angle && angle <= end_angle;
        } else {
            is_filled = angle >= start_angle || angle <= end_angle;
        }

        if (is_filled) {
            out_color.rgb = fill_color;
        }
    }

    COLOR = out_color;
}
