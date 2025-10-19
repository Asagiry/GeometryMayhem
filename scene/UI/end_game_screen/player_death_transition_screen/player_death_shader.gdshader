shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform int columns = 12;
uniform int rows = 8;
uniform vec4 fill_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 empty_color : source_color = vec4(1.0, 1.0, 1.0, 0.0);

void fragment() {
    vec2 uv = UV;

    float cell_w = 1.0 / float(columns);
    float cell_h = 1.0 / float(rows);

    int x = int(floor(uv.x / cell_w));
    int y = int(floor(uv.y / cell_h));

    int layer = min(min(x, y), min(columns - 1 - x, rows - 1 - y));
    int w = columns - 2 * layer;
    int h = rows - 2 * layer;

    int perimeter = (w + h) * 2 - 4;
    int index_in_layer = 0;

    // положение вдоль слоя по периметру
    if (y == layer && x >= layer && x < layer + w) {
        // верхняя линия (→)
        index_in_layer = x - layer;
    } else if (x == layer + w - 1 && y >= layer && y < layer + h) {
        // правая линия (↓)
        index_in_layer = (w - 1) + (y - layer);
    } else if (y == layer + h - 1 && x >= layer && x < layer + w) {
        // нижняя линия (←)
        index_in_layer = (w - 1) + (h - 1) + ((layer + w - 1) - x);
    } else if (x == layer && y >= layer && y < layer + h) {
        // левая линия (↑)
        index_in_layer = (w - 1) + (h - 1) + (w - 1) + ((layer + h - 1) - y);
    }

    // общее смещение всех предыдущих периметров
    int total_prev = 0;
    for (int i = 0; i < layer; i++) {
        int pw = columns - 2 * i;
        int ph = rows - 2 * i;
        total_prev += (pw + ph) * 2 - 4;
    }

    int index = total_prev + index_in_layer;
    int total_cells = 0;
    for (int i = 0; i <= min(columns, rows) / 2; i++) {
        int pw = columns - 2 * i;
        int ph = rows - 2 * i;
        if (pw <= 0 || ph <= 0) break;
        total_cells += (pw + ph) * 2 - 4;
    }

    float active_cells_f = float(total_cells) * progress;
    int active_cells = int(floor(active_cells_f));
    float partial = fract(active_cells_f);

    if (index < active_cells) {
        COLOR = fill_color;
    } else if (index == active_cells) {
        vec2 local_uv = vec2(fract(uv.x / cell_w), fract(uv.y / cell_h));

        // направление заливки по направлению змейки
        float fill = 0.0;

        if (y == layer && x >= layer && x < layer + w) {
            // → слева направо
            fill = local_uv.x;
        } else if (x == layer + w - 1 && y >= layer && y < layer + h) {
            // ↓ сверху вниз
            fill = local_uv.y;
        } else if (y == layer + h - 1 && x >= layer && x < layer + w) {
            // ← справа налево
            fill = 1.0 - local_uv.x;
        } else if (x == layer && y >= layer && y < layer + h) {
            // ↑ снизу вверх
            fill = 1.0 - local_uv.y;
        }

        COLOR = mix(empty_color, fill_color, step(fill, partial));
    } else {
        COLOR = empty_color;
    }
}
