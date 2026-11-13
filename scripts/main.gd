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
