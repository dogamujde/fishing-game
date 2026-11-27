class_name BossFish
extends FightFish
## The boss. It's bigger, has more health, doesn't flinch, and gets faster below half health.

var enraged := false  # true once it drops below half health


func setup(fish_type: FishType, area: Rect2) -> void:
	super.setup(fish_type, area)
	max_hp = 20
	hp = max_hp
	attack_every = 1.8
	windup_time = 0.75
	charge_speed = 210.0
	sprite.scale *= 2.0  # twice as big as a normal fish
	var shape := RectangleShape2D.new()
	shape.size = Vector2(44, 18)
	$CollisionShape2D.shape = shape


func take_hit(damage: int) -> void:
	super.take_hit(damage)
	hurt_timer = 0.0  # the boss doesn't flinch, so you can't just keep hitting it
	if not enraged and hp * 2 <= max_hp:  # gets faster once it's at half health
		enraged = true
		attack_every *= 0.7
		windup_time *= 0.85
		charge_speed *= 1.2


func _draw() -> void:  # a bigger health bar and the ! warning
	draw_rect(Rect2(-21, -27, 42, 5), Color(0.15, 0.15, 0.25))
	draw_rect(Rect2(-20, -26, 40.0 * hp / max_hp, 3), Color(0.9, 0.3, 0.3))
	if state == State.WINDUP:
		draw_rect(Rect2(-2, -41, 5, 11), Color(0.15, 0.15, 0.25))
		draw_rect(Rect2(-1, -40, 3, 5), Color(1, 0.85, 0.2))
		draw_rect(Rect2(-1, -33, 3, 2), Color(1, 0.85, 0.2))
