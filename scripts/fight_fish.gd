class_name FightFish
extends CharacterBody2D
## The fish you fight in the arena. It swims around, shows a ! before it charges at you, and takes hits.

signal defeated  # sent when the fish runs out of health

enum State { SWIM, WINDUP, CHARGE, REST }

@export var swim_speed: float = 40.0

var fish: FishType = null
var target: Player = null  # the arena sets this so the fish knows who to charge at
var swim_area := Rect2(28, 44, 264, 116)  # where the fish can swim, the arena sets this
var max_hp: int = 3
var hp: int = 3
var swim_target: Vector2
var swim_timer: float = 0.0
var hurt_timer: float = 0.0
var anim_time: float = 0.0

var state: State = State.SWIM
var state_time: float = 0.0  # how long the fish has been in its current state
var attack_timer: float = 0.0
var charge_dir := Vector2.ZERO
var attack_every: float = 3.0
var windup_time: float = 0.8
var charge_speed: float = 160.0

@onready var sprite: Sprite2D = $Sprite2D


func setup(fish_type: FishType, area: Rect2) -> void:  # the arena calls this with the fish you caught
	fish = fish_type
	swim_area = area
	max_hp = 3 + roundi(fish.difficulty * 5)  # harder fish take more hits
	hp = max_hp
	# harder fish attack more often, give less warning, and charge faster
	attack_every = lerpf(3.2, 1.8, fish.difficulty)
	windup_time = lerpf(0.9, 0.55, fish.difficulty)
	charge_speed = lerpf(150.0, 230.0, fish.difficulty)
	attack_timer = attack_every + 1.0  # a little extra time before the first attack
	sprite.modulate = fish.tint
	queue_redraw()


func _ready() -> void:
	swim_target = position


func _physics_process(delta: float) -> void:
	anim_time += delta
	sprite.position.y = round(sin(anim_time * 8.0))  # small wiggle so it looks alive
	if hp <= 0:
		return
	if hurt_timer > 0.0:  # stop for a moment after getting hit
		hurt_timer -= delta
		return
	state_time += delta
	match state:
		State.SWIM:
			_swim(delta)
		State.WINDUP:
			_windup()
		State.CHARGE:
			_charge()
		State.REST:
			if state_time >= 0.6:  # short pause after a charge, a good time to hit back
				_set_state(State.SWIM)


func _swim(delta: float) -> void:
	swim_timer -= delta
	if swim_timer <= 0.0 or position.distance_to(swim_target) < 4.0:  # pick a new place to swim to
		swim_target.x = randf_range(swim_area.position.x, swim_area.end.x)
		swim_target.y = randf_range(swim_area.position.y, swim_area.end.y)
		swim_timer = randf_range(1.5, 3.0)
	var dir := position.direction_to(swim_target)
	sprite.flip_h = dir.x > 0  # the picture faces left, so flip it when swimming right
	velocity = dir * swim_speed
	move_and_slide()
	attack_timer -= delta
	if attack_timer <= 0.0 and target:
		_set_state(State.WINDUP)


func _windup() -> void:
	sprite.flip_h = target.global_position.x > global_position.x  # face the player
	sprite.position.x = round(sin(state_time * 60.0))  # shake so you can tell it's about to charge
	if state_time >= windup_time:
		charge_dir = global_position.direction_to(target.global_position)  # aim where the player is now
		_set_state(State.CHARGE)


func _charge() -> void:
	velocity = charge_dir * charge_speed
	move_and_slide()
	for i in get_slide_collision_count():
		var hit := get_slide_collision(i).get_collider()
		if hit is Player:
			hit.take_damage()  # this does nothing if the player is dashing
		_set_state(State.REST)  # the charge ends when it runs into the player or a wall
		return
	if state_time >= 0.6:
		_set_state(State.REST)


func _set_state(new_state: State) -> void:
	state = new_state
	state_time = 0.0
	sprite.position.x = 0
	if new_state == State.SWIM:
		attack_timer = attack_every * randf_range(0.8, 1.2)
	queue_redraw()  # shows or hides the ! above the fish


func take_hit(damage: int) -> void:  # the player's attack calls this
	if hp <= 0:
		return
	hp -= damage
	hurt_timer = 0.25
	queue_redraw()
	sprite.modulate = Color(1, 0.4, 0.4)  # flash red so you can see the hit landed
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = fish.tint
	if hp <= 0:
		defeated.emit()
		create_tween().tween_property(self, "modulate:a", 0.0, 0.5)  # fade out


func _draw() -> void:  # health bar above the fish, plus a ! while it gets ready to charge
	draw_rect(Rect2(-13, -15, 26, 4), Color(0.15, 0.15, 0.25))
	draw_rect(Rect2(-12, -14, 24.0 * hp / max_hp, 2), Color(0.9, 0.3, 0.3))
	if state == State.WINDUP:
		draw_rect(Rect2(-2, -29, 5, 11), Color(0.15, 0.15, 0.25))  # dark outline so it shows on any ground
		draw_rect(Rect2(-1, -28, 3, 5), Color(1, 0.85, 0.2))
		draw_rect(Rect2(-1, -21, 3, 2), Color(1, 0.85, 0.2))
