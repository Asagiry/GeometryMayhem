shader_type canvas_item;

uniform float attack_progress : hint_range(0.0, 1.0) = 0.0;
uniform float parry_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec3 attack_color = vec3(1.0, 0.188, 0.188);
uniform vec3 parry_color = vec3(0.0, 0.905, 1.0);

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);
    
    // Заполнение снизу вверх
    float fill_level_attack = attack_progress;
    float fill_level_parry = parry_progress;
    float current_height = 1.0 - UV.y; // 0=низ, 1=верх
    
    float is_attack = distance(original_color.rgb, attack_color);
    float is_parry = distance(original_color.rgb, parry_color);
    float tolerance = 0.1;
    
    // Атака - заполнение красным
    if (is_attack < tolerance) {
        if (current_height > fill_level_attack) {
            discard; // Или сделать прозрачным
        }
    }
    // Парирование - заполнение синим  
    else if (is_parry < tolerance) {
        if (current_height > fill_level_parry) {
            discard;
        }
    }
    
    COLOR = original_color;
}