@tool
extends Node2D
## Draws 32px terrain art over the original 16-unit map cells.

const ATLAS := preload("res://assets/tiles/shoreline_tiles.png")
const ART_SIZE := Vector2(32, 32)

@onready var tiles: TileMapLayer = get_parent()


func _ready() -> void:
	tiles.changed.connect(queue_redraw)


func _draw() -> void:
	if not is_instance_valid(tiles) or tiles.tile_set == null:
		return
	var cell_size := Vector2(tiles.tile_set.tile_size)
	for cell in tiles.get_used_cells():
		var coords := tiles.get_cell_atlas_coords(cell)
		var destination := Rect2(tiles.map_to_local(cell) - cell_size / 2.0, cell_size)
		draw_texture_rect_region(ATLAS, destination, Rect2(Vector2(coords) * ART_SIZE, ART_SIZE))
