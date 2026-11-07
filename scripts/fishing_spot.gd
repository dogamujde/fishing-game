class_name FishingSpot
extends Area2D

# joseph's minigame connects to this, it says which spot the player is fishing at
signal fishing_requested(spot: FishingSpot)

# the player standing in this spot, null if nobody is here
var player_inside: Player = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

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
