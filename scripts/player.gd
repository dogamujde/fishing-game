class_name Player
extends CharacterBody2D

# how fast the player walks, tweak this later for game feel
@export var speed: float = 120.0

# turned off while fishing so the player cant walk away mid cast
var can_move: bool = true

# walk animation: sheet rows are down, up, side (left is side flipped)
# columns are idle, step a, step b, played as idle, a, idle, b
const WALK_SEQUENCE := [0, 1, 0, 2]
@export var walk_fps: float = 8.0
@onready var sprite: Sprite2D = $Sprite2D
var facing_row: int = 0
var anim_time: float = 0.0

func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		_update_animation(Vector2.ZERO, _delta)
		return
	# get_vector gives a direction from the 4 actions, already normalized so diagonals aren't faster
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	# move_and_slide moves the body and stops/slides it along walls
	move_and_slide()
	_update_animation(input_dir, _delta)

func _update_animation(dir: Vector2, delta: float) -> void:
	if dir == Vector2.ZERO:
		anim_time = 0.0
		sprite.frame = facing_row * 3
		sprite.offset.y = 0
		return
	# pick the facing from whichever axis is stronger
	if absf(dir.x) > absf(dir.y):
		facing_row = 2
		sprite.flip_h = dir.x < 0
	else:
		facing_row = 0 if dir.y > 0 else 1
		sprite.flip_h = false
	anim_time += delta * walk_fps
	var col: int = WALK_SEQUENCE[int(anim_time) % WALK_SEQUENCE.size()]
	sprite.frame = facing_row * 3 + col
	# small bob up on step frames
	sprite.offset.y = -1 if col != 0 else 0
