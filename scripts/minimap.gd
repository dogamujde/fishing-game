extends Control
## Map terrain is cached as one texture. Markers use their live world positions.

const MAX_SIZE := Vector2(80, 50)
const FRAME_WIDTH := Vector2(2, 2)
const MARGIN := 6.0
const PANEL := Color("#192b32")
const BORDER := Color("#808080")
const WATER := Color("#3d8198")
const LAND := Color("#83a86b")
const PATH := Color("#d2b68a")
const WALL := Color("#4e5858")
const FISH := Color("#a5f0ea")
const LOCKED := Color("#ffbe66")
const OPEN := Color("#b9ec9c")

var area: MapArea
var player: Player
var bounds: Rect2
var terrain: ImageTexture
var map_rect: Rect2
var frame_size: Vector2
var spots: Array[FishingSpot] = []
var gates: Array[Node2D] = []
var last_player_position := Vector2.INF


func setup(map_area: MapArea, map_player: Player) -> void:
	area = map_area
	player = map_player
	bounds = area.get_bounds()
	var cells := area.ground.get_used_rect()
	var image := Image.create_empty(cells.size.x, cells.size.y, false, Image.FORMAT_RGBA8)
	for layer: TileMapLayer in [area.ground, area.water, area.obstacles]:
		for cell in layer.get_used_cells():
			if cells.has_point(cell):
				var tile := layer.get_cell_tile_data(cell)
				if tile != null:
					image.set_pixelv(cell - cells.position, _tile_color(tile, layer.get_cell_atlas_coords(cell)))
	terrain = ImageTexture.create_from_image(image)
	var max_map_size := MAX_SIZE - FRAME_WIDTH * 2.0
	var scale_factor := minf(max_map_size.x / bounds.size.x, max_map_size.y / bounds.size.y)
	var map_size := (bounds.size * scale_factor).round()
	map_rect = Rect2(FRAME_WIDTH, map_size)
	frame_size = map_size + FRAME_WIDTH * 2.0
	for node in area.get_children():
		if node is FishingSpot:
			spots.append(node)
		elif node is LevelGate:
			gates.append(node)
	for node in area.ground.get_children():
		if node is LevelBarrier:
			gates.append(node)
	GameState.leveled_up.connect(_on_level_changed)
	set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	offset_left = -frame_size.x - MARGIN
	offset_right = -MARGIN
	offset_top = MARGIN
	offset_bottom = frame_size.y + MARGIN
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()


func _tile_color(tile: TileData, atlas_coords: Vector2i) -> Color:
	if tile.get_custom_data("is_water"):
		return WATER
	if tile.get_collision_polygons_count(0) > 0:
		return WALL
	if atlas_coords in [Vector2i(3, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(4, 0)]:
		return PATH
	return LAND


func _process(_delta: float) -> void:
	if player.global_position != last_player_position:
		last_player_position = player.global_position
		queue_redraw()


func _on_level_changed(_level: int) -> void:
	queue_redraw()


func _draw() -> void:
	if terrain == null:
		return
	draw_rect(Rect2(Vector2.ZERO, frame_size), Color.BLACK)
	draw_rect(Rect2(Vector2.ONE, frame_size - Vector2(2, 2)), BORDER)
	draw_texture_rect(terrain, map_rect, false)
	for spot in spots:
		var point := _project(spot.bubble.global_position)
		var available := GameState.has_level(spot.required_level)
		if spot.fish_override and spot.fish_override.is_boss:
			_draw_diamond(point, 4.0, PANEL)
			_draw_diamond(point, 3.0, Color("#e9a8dd") if available else LOCKED)
		else:
			draw_circle(point, 2.5, PANEL)
			draw_circle(point, 1.5, FISH if available else LOCKED)
	for gate in gates:
		if is_instance_valid(gate):
			var point := _project(gate.global_position)
			var color := OPEN if GameState.has_level(gate.required_level) else LOCKED
			draw_rect(Rect2(point - Vector2(3, 3), Vector2(6, 6)), PANEL)
			draw_rect(Rect2(point - Vector2(2, 2), Vector2(4, 4)), color)
	var player_point := _project(player.global_position)
	draw_circle(player_point, 3.5, PANEL)
	draw_circle(player_point, 2.5, Color.WHITE)


func _project(world_position: Vector2) -> Vector2:
	return (map_rect.position + ((world_position - bounds.position) / bounds.size) * map_rect.size).round()


func _draw_diamond(point: Vector2, radius: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		point + Vector2.UP * radius, point + Vector2.RIGHT * radius,
		point + Vector2.DOWN * radius, point + Vector2.LEFT * radius,
	]), color)
