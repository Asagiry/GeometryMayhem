extends MarginContainer

@onready var minimap_border: TextureRect = %MinimapBorder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minimap_border.pivot_offset = Vector2(100,100)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	minimap_border.rotation += delta*0.1
