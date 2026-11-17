class_name FishingSpot
extends Area2D

# joseph's minigame connects to this, it says which spot the player is fishing at
signal fishing_requested(spot: FishingSpot)

const MINIGAME := preload("res://scenes/FishingMiniGame.tscn")
# the player standing in this spot, null if nobody is here
var player_inside: Player = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	fishing_requested.connect(_start_fishing)
func _on_body_entered(body: Node2D) -> void:
	# only care about the player, walls and fish shouldnt trigger fishing
	if body is Player:
		player_inside = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_inside:
		player_inside = null

func _unhandled_input(event: InputEvent) -> void:
	# can_move check stops spamming E while already fishing
	if player_inside and player_inside.can_move and event.is_action_pressed("interact"):
		print("fishing requested at ", name)
		fishing_requested.emit(self)

func _start_fishing(_spot: FishingSpot) -> void:
	var player := player_inside   # keep a reference in case they leave the area mid-game
	player.can_move = false
	var game := MINIGAME.instantiate()
	add_child(game)
	game.fishing_finished.connect(_on_fishing_finished.bind(game, player))

func _on_fishing_finished(success: bool, fish: FishType, value: int, game: Node, player: Player) -> void:
	print("caught: ", success, " ", fish.fish_name if fish else "")
	game.queue_free()
	player.can_move = true
