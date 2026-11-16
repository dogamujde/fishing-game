extends Node2D
## Runs the game world: puts the player into the current area.

@onready var player: Player = $Player  # the player variable
@onready var area: Node2D = $StarterArea  # the area the game starts in


func _ready() -> void:  # runs once when the game starts
	player.global_position = area.get_spawn_position()  # starts the player
	var bounds: Rect2 = area.get_bounds()  # the area's edges in pixels
	var camera: Camera2D = player.get_node("Camera2D")  # the camera that follows the player
	camera.limit_left = int(bounds.position.x)  # camera can't scroll past the left edge
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.end.x)
	camera.limit_bottom = int(bounds.end.y)
	for child in area.get_children():  # go through everything in the area
		if child is FishingSpot:  # only care about fishing spots
			child.fishing_requested.connect(_on_fishing_requested)  # run our function when E is pressed there
	GameState.xp_changed.connect(_on_xp_changed)  # print XP whenever it changes
	GameState.leveled_up.connect(_on_leveled_up)  # print when the player levels up


func _on_fishing_requested(_spot: FishingSpot) -> void:  # runs when the player presses E at a spot
	GameState.add_xp(40)  # temporary placeholder test XP until Joseph's minigame is hooked up


func _on_xp_changed(current_xp: int, needed_xp: int) -> void:  # runs whenever XP changes
	print("XP: ", current_xp, " / ", needed_xp)  # shows exp


func _on_leveled_up(new_level: int) -> void:  # runs when the player levels up
	print("Level up! You are now level ", new_level)  
