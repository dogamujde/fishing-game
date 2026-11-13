extends Node2D
## A map area: knows where the player starts and how big the map is.

@onready var ground: TileMapLayer = $Ground  # the layer that covers the whole map
@onready var spawn_point: Marker2D = $SpawnPoint  # where the player starts in this area


func get_spawn_position() -> Vector2:  # tells the game where the player should start
	return spawn_point.global_position  # the spawn point's spot in the world


func get_bounds() -> Rect2:  # tells the game how big the map is, in pixels
	var cells: Rect2i = ground.get_used_rect()  # the painted part of the map, counted in tiles
	var tile: Vector2 = Vector2(ground.tile_set.tile_size)  # one tile's size in pixels (16 by 16)
	var top_left: Vector2 = ground.to_global(Vector2(cells.position) * tile)  
	return Rect2(top_left, Vector2(cells.size) * tile) 
