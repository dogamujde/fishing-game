extends Node2D
## Runs the game world: puts the player into the current area.

@onready var player: Player = $Player  # the player variable
@onready var area: Node2D = $StarterArea


func _ready() -> void:  # runs once when the game starts
	player.global_position = area.get_spawn_position()  # starts the player
	var bounds: Rect2 = area.get_bounds()
	var camera: Camera2D = player.get_node("Camera2D")  # the camera that follows the player
	camera.limit_left = int(bounds.position.x)  # camera can't scroll past the left edge
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.end.x)
	camera.limit_bottom = int(bounds.end.y)
	for child in area.get_children():  # go through everything in the area
		if child is FishingSpot:  
			child.fishing_done.connect(_on_fishing_done)  # run our function when the minigame there ends
	GameState.xp_changed.connect(_on_xp_changed)  
	GameState.leveled_up.connect(_on_leveled_up)
	TextBox.show_message("Welcome! Press E to read the next tip.")  # intro tips, shown one at a time
	TextBox.show_message("Walk around with WASD or the arrow keys.")  # how to move
	TextBox.show_message("When you're next to the water, press E to fish.")  # how to fish
	TextBox.show_message("Every fish you catch gives you XP. Get enough XP and you'll level up!")  # how XP works


func _on_fishing_done(success: bool, fish: FishType, xp: int) -> void:  # runs when the minigame closes
	if not success:
		TextBox.show_message("The fish got away...")
		return
	# the catch message goes first so a level up message shows right after it
	TextBox.show_message("You caught a " + fish.fish_name + "! +" + str(xp) + " XP")
	GameState.add_xp(xp)


func _on_xp_changed(current_xp: int, needed_xp: int) -> void:  # runs whenever XP changes
	print("XP: ", current_xp, " / ", needed_xp)  # shows exp


func _on_leveled_up(new_level: int) -> void:  # runs when the player levels up
	print("Level up! You are now level ", new_level)
	TextBox.show_message("You reached level " + str(new_level) + "!")  # tell the player in the text box
