extends CanvasLayer

@onready var def_container: VBoxContainer = %DefContainer
@onready var attack_container: VBoxContainer = %AttackContainer
@onready var speed_container: VBoxContainer = %SpeedContainer
@onready var current_points: Label = %CurrentPoints
@onready var your_talents: Label = %YourTalents


func _on_quit_button_pressed() -> void:
	queue_free()



func _on_def_container_child_entered_tree(node: Node) -> void:
	connect_talent(node)



func _on_attack_container_child_entered_tree(node: Node) -> void:
	connect_talent(node)


func _on_speed_container_child_entered_tree(node: Node) -> void:
	connect_talent(node)


func connect_talent(node):
	if (node is TalentSlot):
		node.talent_selected.connect(_on_talent_selected)


func _on_talent_selected():
	print(123)
