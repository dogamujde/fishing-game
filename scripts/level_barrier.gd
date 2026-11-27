class_name LevelBarrier

extends Node2D
## A fence that blocks a path until the player reaches a level. It only shows up when the game runs.

const TILES := preload("res://assets/tiles/placeholder_tiles.png")
const FENCE_TILE := Rect2(48, 32, 16, 16)  # where the fence is in the tileset picture

@export var required_level: int = 4
@export var size_in_tiles := Vector2i(1, 3)  # how many tiles wide and tall the fence is


func _ready() -> void:
	if GameState.has_level(required_level):  # already high enough, so the path is open
		queue_free()
		return
	var size := Vector2(size_in_tiles) * 16.0
	var wall := StaticBody2D.new()  # the part that actually blocks the player
	wall.add_child(_box(size))
	add_child(wall)
	var sensor := Area2D.new()  # a slightly bigger box that notices the player walking up
	sensor.add_child(_box(size + Vector2(12, 12)))
	sensor.body_entered.connect(_on_body_entered)
	add_child(sensor)
	var label := Label.new()
	label.text = "Lv " + str(required_level)
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(0.15, 0.15, 0.25))
	label.position = Vector2(-size.x / 2.0 - 22, -20)  # just left of the fence, on the side you walk up from
	add_child(label)
	GameState.leveled_up.connect(_on_leveled_up)


func _box(size: Vector2) -> CollisionShape2D:  # makes a rectangle collision shape this size
	var shape := RectangleShape2D.new()
	shape.size = size
	var holder := CollisionShape2D.new()
	holder.shape = shape
	return holder


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		TextBox.show_message(GameState.level_lock_message(required_level))


func _on_leveled_up(new_level: int) -> void:
	if new_level == required_level:
		# deferred so it shows after the level up message
		TextBox.show_message.call_deferred("You're level " + str(required_level) + " now, a new part of the map is open!")
		queue_free()


func _draw() -> void:  # draws fence tiles over the whole barrier
	var size := Vector2(size_in_tiles) * 16.0
	for x in size_in_tiles.x:
		for y in size_in_tiles.y:
			draw_texture_rect_region(TILES, Rect2(-size / 2.0 + Vector2(x, y) * 16.0, Vector2(16, 16)), FENCE_TILE)
