class_name ArenaZone

extends TileMapLayer

signal entered_zone(zone: ArenaZone)
signal exited_zone(zone: ArenaZone)

@export var arena_stat_data: ArenaStatData

@onready var borders_folder: Node2D = %Borders
@onready var areas_folder: Node2D = %Areas

var border_area: Area2D
var full_area: Area2D

func create_area():
	var rect = get_used_rect()
	var cell_size = tile_set.tile_size
	var zone_pos = map_to_local(rect.position)
	var zone_size = rect.size * cell_size
	var border_thickness = 16

	border_area = Area2D.new()
	border_area.name = get_zone_name()
	border_area.collision_mask = arena_stat_data.collision_mask
	var borders = {
		"top":    Rect2(Vector2(zone_pos.x-border_thickness, zone_pos.y - border_thickness),
						Vector2(zone_size.x+border_thickness, border_thickness)),
		"bottom": Rect2(Vector2(zone_pos.x-border_thickness, zone_pos.y + zone_size.y- border_thickness),
						Vector2(zone_size.x+border_thickness, border_thickness)),
		"left":   Rect2(Vector2(zone_pos.x - border_thickness, zone_pos.y),
						Vector2(border_thickness, zone_size.y-border_thickness)),
		"right":  Rect2(Vector2(zone_pos.x + zone_size.x- border_thickness, zone_pos.y),
						Vector2(border_thickness, zone_size.y-border_thickness))
	}
	for side in borders.keys():
		var shape = CollisionShape2D.new()
		shape.debug_color = Color(1,0,0,0.5)
		shape.shape = RectangleShape2D.new()
		shape.shape.size = borders[side].size
		shape.position = borders[side].position + borders[side].size / 2.0
		border_area.add_child(shape)

	full_area = Area2D.new()
	full_area.collision_mask = arena_stat_data.collision_mask
	full_area.name = get_zone_name()

	var full_shape = CollisionShape2D.new()
	full_shape.debug_color = Color(0,0,0,0)
	full_shape.shape = RectangleShape2D.new()
	full_shape.shape.size = zone_size - Vector2i(border_thickness, border_thickness)
	full_shape.position = zone_pos + full_shape.shape.size / 2.0
	full_area.add_child(full_shape)

	borders_folder.add_child.call_deferred(border_area)
	border_area.body_exited.connect(_on_border_area_exited)
	areas_folder.add_child.call_deferred(full_area)

#TODO руинит range mob - поведение(протестировать)
func _on_border_area_exited(body: CharacterBody2D):
	if body is PlayerController:
		if full_area.get_overlapping_bodies().has(body):
			entered_zone.emit(self)
		else:
			exited_zone.emit(self)
	elif body is EnemyController:
		if (body.state_machine.current_state.get_state_name()!=EnemyAggroState.state_name)\
		and body.state_machine.current_state.get_state_name()!=EnemyBackState.state_name:
			body.state_machine.transition(EnemyBackState.state_name)
		#TODO сделать получше мб


func get_random_tile_point() -> Vector2:
	var used_cells = get_used_cells()
	if used_cells.is_empty():
		return Vector2.ZERO
	var random_cell = used_cells[randi() % used_cells.size()]
	return map_to_local(random_cell) + tile_set.tile_size / 2.0

func get_zone_name():
	pass
