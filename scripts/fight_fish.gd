class_name FightFish
extends CharacterBody2D
## The fish you fight in the arena. For now it swims around and takes hits. Its attacks come next.

signal defeated  # sent when the fish runs out of health

@export var swim_speed: float = 40.0

var fish: FishType = null
var swim_area := Rect2(28, 44, 264, 116)  # where the fish can swim, the arena sets this
var max_hp: int = 3
var hp: int = 3
var swim_target: Vector2
var swim_timer: float = 0.0
var hurt_timer: float = 0.0
var anim_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D


func setup(fish_type: FishType, area: Rect2) -> void:  # the arena calls this with the fish you caught
	fish = fish_type
	swim_area = area
	max_hp = 3 + roundi(fish.difficulty * 5)  # harder fish take more hits
	hp = max_hp
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
	swim_timer -= delta
	if swim_timer <= 0.0 or position.distance_to(swim_target) < 4.0:  # pick a new place to swim to
		swim_target.x = randf_range(swim_area.position.x, swim_area.end.x)
		swim_target.y = randf_range(swim_area.position.y, swim_area.end.y)
		swim_timer = randf_range(1.5, 3.0)
	var dir := position.direction_to(swim_target)
	sprite.flip_h = dir.x > 0  # the picture faces left, so flip it when swimming right
	velocity = dir * swim_speed
	move_and_slide()


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


func _draw() -> void:  # small health bar above the fish
	draw_rect(Rect2(-13, -15, 26, 4), Color(0.15, 0.15, 0.25))
	draw_rect(Rect2(-12, -14, 24.0 * hp / max_hp, 2), Color(0.9, 0.3, 0.3))
