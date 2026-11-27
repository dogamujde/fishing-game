class_name MapArea

extends Node2D
## A map area: knows where the player starts and how big the map is.

@onready var ground: TileMapLayer = $Ground  # the layer that covers the whole map
@onready var water: TileMapLayer = $Water
@onready var obstacles: TileMapLayer = $Obstacles
@onready var spawn_point: Marker2D = $SpawnPoint  # where the player starts in this area


func get_spawn_position() -> Vector2:  # tells the game where the player should start
	return spawn_point.global_position  # the spawn point's spot in the world


func get_bounds() -> Rect2:  # tells the game how big the map is, in pixels
	var cells: Rect2i = ground.get_used_rect()  # the painted part of the map, counted in tiles
	var tile: Vector2 = Vector2(ground.tile_set.tile_size)  # one tile's size in pixels (16 by 16)
	var top_left: Vector2 = ground.to_global(Vector2(cells.position) * tile)  
	return Rect2(top_left, Vector2(cells.size) * tile) 


func get_fishing_direction(origin: Vector2, spot_position: Vector2) -> Vector2:
	var toward_spot := origin.direction_to(spot_position)
	var closest_direction := Vector2.ZERO
	var closest_distance := INF
	var tile_size := Vector2(ground.tile_set.tile_size)
	var tile_center := ground.to_global(ground.map_to_local(ground.local_to_map(ground.to_local(origin))))
	# Prefer a straight cast into water. Resolve equally close banks toward the selected spot.
	for direction in [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]:
		var tile_length: float = absf(tile_size.dot(direction))
		var first_edge: float = (tile_center - origin).dot(direction) + tile_length / 2.0
		for step in range(4):
			var distance: float = first_edge + tile_length * step
			var sample: Vector2 = origin + direction * (distance + tile_length / 2.0)
			if not _is_water_at(water, sample) and not _is_water_at(ground, sample):
				continue
			if distance < closest_distance or (is_equal_approx(distance, closest_distance)
					and toward_spot.dot(direction) > toward_spot.dot(closest_direction)):
				closest_direction = direction
				closest_distance = distance
			break
	if closest_direction != Vector2.ZERO:
		return closest_direction

	# An angled bank can put water outside all four straight paths.
	var toward_water := origin.direction_to(get_nearest_water_position(origin))
	return toward_water if toward_water != Vector2.ZERO else toward_spot


func get_nearest_water_position(origin: Vector2) -> Vector2:
	var closest_position := origin
	var closest_distance_squared := INF
	for layer: TileMapLayer in [water, ground]:
		for cell in layer.get_used_cells():
			var tile := layer.get_cell_tile_data(cell)
			if tile == null or not tile.get_custom_data("is_water"):
				continue
			var position_in_world := layer.to_global(layer.map_to_local(cell))
			if _is_covered_by_obstacle(position_in_world):
				continue
			var distance_squared := origin.distance_squared_to(position_in_world)
			if distance_squared < closest_distance_squared:
				closest_position = position_in_world
				closest_distance_squared = distance_squared
	return closest_position


func _is_water_at(layer: TileMapLayer, position_in_world: Vector2) -> bool:
	var tile := layer.get_cell_tile_data(layer.local_to_map(layer.to_local(position_in_world)))
	return tile != null and tile.get_custom_data("is_water") and not _is_covered_by_obstacle(position_in_world)


func _is_covered_by_obstacle(position_in_world: Vector2) -> bool:
	var tile := obstacles.get_cell_tile_data(obstacles.local_to_map(obstacles.to_local(position_in_world)))
	return tile != null and tile.get_collision_polygons_count(0) > 0
