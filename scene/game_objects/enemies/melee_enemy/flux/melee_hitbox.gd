extends Area2D

func _ready():
	monitoring = true
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	print("MeleeHitbox: area_entered -> ", area.name, " class=", area.get_class())
