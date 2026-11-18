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

# turned off while fishing so the player cant walk away mid cast
var can_move: bool = true

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
	if not can_move:
		_end_dodge()
		velocity = Vector2.ZERO
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
