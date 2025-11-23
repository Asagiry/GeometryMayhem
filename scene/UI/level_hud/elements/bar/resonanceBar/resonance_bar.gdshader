shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0) = 1.0;
uniform float progress_tail: hint_range(0.0, 1.0) = 1.0;
uniform vec3 tail_color : source_color = vec3(1.0);

void fragment() {
	if (COLOR.a != 0.0){
		// Инвертируем UV.x: 1.0 - UV.x (справа = 0.0, слева = 1.0)
		float inverted_x = 1.0 - UV.x;

		COLOR.a = inverted_x > progress_tail ? 0.3 : COLOR.a;
		COLOR.rgb = inverted_x > progress && inverted_x < progress_tail ? tail_color : COLOR.rgb;
	}
}