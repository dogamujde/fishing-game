extends Node2D
## Runs a fish fight. You win when the fish runs out of health, and it gets away if it hits you 3 times.

const MAX_HITS: int = 3  # hits the player can take before the fish gets away
const DEFAULT_FISH := preload("res://Resources/Fish/Carp.tres")  # used when you run this scene by itself

var fight_over: bool = false

@onready var player: Player = $Player
@onready var fish: FightFish = $FightFish
@onready var ground: TileMapLayer = $Ground
@onready var hearts: HBoxContainer = $HUD/Hearts


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
	var fish_type := GameState.fight_fish if GameState.fight_fish else DEFAULT_FISH
	fish.setup(fish_type, swim_area)
	fish.target = player  # so the fish knows who to charge at
	fish.defeated.connect(_on_fish_defeated)
	player.got_hit.connect(_on_player_got_hit)
	$HUD/Hearts.follow_target = player
	$HUD/Hearts.update_hearts(MAX_HITS, MAX_HITS)
	if fish_type.is_boss:
		_play_boss_intro(camera)
	TextBox.show_tip_once("fight", "Fight! Walk up to the fish and press J to attack. When a ! shows over the fish, it's about to charge, so press Space to dash out of the way.")


func _play_boss_intro(camera: Camera2D) -> void:
	ground.modulate = Color("#b6addb")
	$Obstacles.modulate = Color("#c3acdb")
	$HUD.hide()
	player.can_move = false
	fish.set_physics_process(false)
	camera.zoom = Vector2.ONE * 1.35
	camera.global_position = fish.global_position
	var intro := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	intro.tween_property(camera, "position", Vector2.ZERO, 0.65).set_delay(0.3)
	intro.tween_property(camera, "zoom", Vector2.ONE, 0.65).set_delay(0.3)
	await intro.finished
	$HUD.show()
	player.can_move = true
	fish.set_physics_process(true)


func _on_player_got_hit(total_hits: int) -> void:
	if fight_over:
		return
		
	var hits_left := maxi(MAX_HITS - total_hits, 0)
	$HUD/Hearts.update_hearts(hits_left, MAX_HITS)

	if hits_left == 0:
		_end_fight(false)


func _on_fish_defeated() -> void:
	_end_fight(true)


func _end_fight(won: bool) -> void:
	if fight_over:  # only end once, even if more hits come in
		return
	fight_over = true
	await get_tree().create_timer(0.6).timeout  # short pause so you can see the last hit
	GameState.finish_fight(won)
