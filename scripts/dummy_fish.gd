extends StaticBody2D

# placeholder until davids fish is ready, it just takes hits
@export var max_hp: int = 3
var hp: int = 0

func _ready() -> void:
	hp = max_hp
	$TouchArea.body_entered.connect(_on_touch_area_body_entered)

# touching the fish counts as getting hit, good enough to test dodging
func _on_touch_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage()

func take_hit(damage: int) -> void:
	hp -= damage
	print("dummy fish hit, hp left: ", hp)
	if hp <= 0:
		print("dummy fish beaten")
		queue_free()
		return
	# quick red flash so you can see the hit landed
	modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
