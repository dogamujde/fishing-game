extends CharacterBody2D

# how fast the player walks, tweak this later for game feel
@export var speed: float = 120.0

func _physics_process(_delta: float) -> void:
	# get_vector gives a direction from the 4 actions, already normalized so diagonals aren't faster
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	# move_and_slide moves the body and stops/slides it along walls
	move_and_slide()
