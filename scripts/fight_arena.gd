extends Node2D
## Runs a fish fight. You win when the fish runs out of health, and it gets away if it hits you 3 times.

const MAX_HITS: int = 3  # hits the player can take before the fish gets away

var fight_over: bool = false

@onready var player: Player = $Player
@onready var fish: Node2D = $DummyFish  # Doga's placeholder until the real fight fish is in


func _ready() -> void:
	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_left = -240  # keep the camera inside the arena
	camera.limit_top = -135
	camera.limit_right = 240
	camera.limit_bottom = 135
	player.got_hit.connect(_on_player_got_hit)
	fish.tree_exited.connect(_on_fish_beaten)  # the dummy fish removes itself when it runs out of health
	TextBox.show_tip_once("fight", "Fight! Walk up to the fish and press J to attack. Press Space to dash. You can't get hit while dashing.")


func _on_player_got_hit(total_hits: int) -> void:
	if total_hits >= MAX_HITS:
		_end_fight(false)


func _on_fish_beaten() -> void:
	if fish.hp <= 0:  # this also runs when the whole arena closes, so check the fish really lost
		_end_fight(true)


func _end_fight(won: bool) -> void:
	if fight_over:  # only end once, even if more hits come in or the scene is closing
		return
	fight_over = true
	GameState.finish_fight(won)
