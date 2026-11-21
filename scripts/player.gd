class_name Player
extends CharacterBody2D

# how fast the player walks, tweak this later for game feel
@export var speed: float = 120.0

# dodge and attack are off by default so they only work in the fight arena
@export var dodge_enabled: bool = false
@export var dodge_speed: float = 360.0
@export var dodge_time: float = 0.15
@export var dodge_cooldown: float = 0.5
@export var attack_enabled: bool = false
@export var attack_damage: int = 1
@export var attack_cooldown: float = 0.3


# joseph can use hits_taken for the no hit bonus
signal got_hit(total_hits: int)
var hits_taken: int = 0

# turned off while fishing so the player cant walk away mid cast
var can_move: bool = true

<<<<<<< HEAD
# walk animation: sheet rows are down, up, side (left is side flipped)
# columns are idle, step a, step b, played as idle, a, idle, b
const WALK_SEQUENCE := [0, 1, 0, 2]
@export var walk_fps: float = 8.0
@onready var sprite: Sprite2D = $Sprite2D
var facing_row: int = 0
var anim_time: float = 0.0

func _physics_process(_delta: float) -> void:
=======
# fish attacks should check this and do nothing when its true
var is_invincible: bool = false

var is_dodging: bool = false
var dodge_dir: Vector2 = Vector2.RIGHT
var dodge_timer: float = 0.0
var cooldown_timer: float = 0.0
var attack_timer: float = 0.0
# last direction we walked in, dodge and attack go this way
var facing: Vector2 = Vector2.RIGHT

@onready var attack_hitbox: Area2D = $AttackHitbox

func _physics_process(delta: float) -> void:
	cooldown_timer = maxf(cooldown_timer - delta, 0.0)
	attack_timer = maxf(attack_timer - delta, 0.0)
>>>>>>> origin/doga/fight-arena
	if not can_move:
		_end_dodge()
		velocity = Vector2.ZERO
		_update_animation(Vector2.ZERO, _delta)
		return
	if is_dodging:
		dodge_timer -= delta
		velocity = dodge_dir * dodge_speed
		move_and_slide()
		if dodge_timer <= 0.0:
			_end_dodge()
		return
	# get_vector gives a direction from the 4 actions, already normalized so diagonals aren't faster
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		facing = input_dir
	# keep the hitbox in front of the player
	attack_hitbox.position = facing * 20.0
	if dodge_enabled and Input.is_action_just_pressed("dodge") and cooldown_timer <= 0.0:
		_start_dodge()
		return
	if attack_enabled and Input.is_action_just_pressed("action") and attack_timer <= 0.0:
		_attack()
	velocity = input_dir * speed
	# move_and_slide moves the body and stops/slides it along walls
	move_and_slide()
<<<<<<< HEAD
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
=======

func _start_dodge() -> void:
	is_dodging = true
	is_invincible = true
	dodge_dir = facing
	dodge_timer = dodge_time
	# cooldown starts now so it covers the dodge itself plus the wait after
	cooldown_timer = dodge_time + dodge_cooldown
	# half see-through so you can tell when you cant get hit
	modulate.a = 0.5

func _end_dodge() -> void:
	is_dodging = false
	is_invincible = false
	modulate.a = 1.0

func _attack() -> void:
	attack_timer = attack_cooldown
	print("attack")
	# anything with a take_hit function gets hit, so davids fish just needs that function
	for body in attack_hitbox.get_overlapping_bodies():
		if body != self and body.has_method("take_hit"):
			body.take_hit(attack_damage)
			

# davids fish calls this when it hits the player
func take_damage() -> void:
	# dodging means the fish missed
	if is_invincible:
		print("dodged!")
		return
	hits_taken += 1
	print("player got hit, total hits: ", hits_taken)
	got_hit.emit(hits_taken)
>>>>>>> origin/doga/fight-arena
