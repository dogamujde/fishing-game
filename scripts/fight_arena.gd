extends Node2D
## Runs a fish fight. You win when the fish runs out of health, and it gets away if it hits you 3 times.

const MAX_HITS: int = 3  # hits the player can take before the fish gets away
const DEFAULT_FISH := preload("res://Resources/Fish/Carp.tres")  # used when you run this scene by itself

var fight_over: bool = false

@onready var player: Player = $Player
@onready var fish: FightFish = $FightFish
@onready var ground: TileMapLayer = $Ground


func _ready() -> void:
	var cells := ground.get_used_rect()  # the painted part of the arena, counted in tiles
	var tile := Vector2(ground.tile_set.tile_size)
	var bounds := Rect2(Vector2(cells.position) * tile, Vector2(cells.size) * tile)
	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_left = int(bounds.position.x)  # keep the camera inside the arena
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.end.x)
	camera.limit_bottom = int(bounds.end.y)
	# the fish swims on the sand: in from the rocks, below the 2 water rows, and above the bushes
	var swim_area := Rect2(bounds.position + Vector2(28, 44), bounds.size - Vector2(56, 76))
	fish.setup(GameState.fight_fish if GameState.fight_fish else DEFAULT_FISH, swim_area)
	fish.defeated.connect(_on_fish_defeated)
	player.got_hit.connect(_on_player_got_hit)
	TextBox.show_tip_once("fight", "Fight! Walk up to the fish and press J to attack. Press Space to dash. You can't get hit while dashing.")


func _on_player_got_hit(total_hits: int) -> void:
	if total_hits >= MAX_HITS:
		_end_fight(false)


func _on_fish_defeated() -> void:
	_end_fight(true)


func _end_fight(won: bool) -> void:
	if fight_over:  # only end once, even if more hits come in
		return
	fight_over = true
	await get_tree().create_timer(0.6).timeout  # short pause so you can see the last hit
	GameState.finish_fight(won)
