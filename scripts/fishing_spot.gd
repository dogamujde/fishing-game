class_name FishingSpot
extends Area2D

# joseph's minigame connects to this, it says which spot the player is fishing at
signal fishing_requested(spot: FishingSpot)
signal fishing_done(success: bool, fish: FishType, xp: int)  # sent after the minigame closes

const MINIGAME := preload("res://scenes/FishingMiniGame.tscn")
# the player standing in this spot, null if nobody is here
var player_inside: Player = null

# The bubble shows a fish from afar, the prompt nearby, and dots while fishing.
enum MarkerState { FAR, NEAR, FISHING, DONE }
var state: MarkerState = MarkerState.FAR:
	set(new_state):
		state = new_state
		fish_prompt.visible = state == MarkerState.NEAR
		marker.visible = state == MarkerState.FAR or state == MarkerState.FISHING
		marker.frame = DOT_FRAMES[0] if state == MarkerState.FISHING else FISH_FRAMES[0]

# Sheet frames 1–2 are fish and 3–5 are dots.
const FISH_FRAMES := [1, 2]
const DOT_FRAMES := [3, 4, 5, 5]
@export var bob_height: float = 2.0  # pixels the bubble floats up and down
@export var bob_speed: float = 3.0
@export var frame_fps: float = 4.0
@export var fish_override: FishType
@export var required_level: int = 1
## Offset from the spot to the bank or pier where the player stands.
@export var approach_offset: Vector2 = Vector2.ZERO
var anim_time: float = 0.0

@onready var bubble: Node2D = $Bubble
@onready var marker: Sprite2D = $Bubble/Marker
@onready var fish_prompt: Label = $Bubble/FishingPrompt

func _ready() -> void:
	$CollisionShape2D.position = approach_offset
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	fishing_requested.connect(_start_fishing)
	_place_bubble_on_water.call_deferred()


func _place_bubble_on_water() -> void:
	var area := get_parent() as MapArea
	if area:
		bubble.global_position = area.get_nearest_water_position(global_position)

func _process(delta: float) -> void:
	if not marker.visible:
		return
	anim_time += delta
	marker.position.y = round(sin(anim_time * bob_speed) * bob_height)
	var step := int(anim_time * frame_fps)
	match state:
		MarkerState.FAR:
			marker.frame = FISH_FRAMES[step % FISH_FRAMES.size()]
		MarkerState.FISHING:
			marker.frame = DOT_FRAMES[step % DOT_FRAMES.size()]

@export var respawn_time: float = 5.0  # seconds before a used spot can be fished again

# call this when the minigame is over, the marker hides and comes back after respawn_time
func finish_fishing() -> void:
	state = MarkerState.DONE
	# false = timer stops while the game is paused (text box open)
	await get_tree().create_timer(respawn_time, false).timeout
	anim_time = 0.0
	# Restore the prompt if the player is still in range.
	state = MarkerState.NEAR if player_inside else MarkerState.FAR

func _on_body_entered(body: Node2D) -> void:
	# only care about the player, walls and fish shouldnt trigger fishing
	if body is Player:
		player_inside = body
		if state == MarkerState.FAR:
			state = MarkerState.NEAR

func _on_body_exited(body: Node2D) -> void:
	if body == player_inside:
		player_inside = null
		if state == MarkerState.NEAR:
			state = MarkerState.FAR

func _unhandled_input(event: InputEvent) -> void:
	# can_move check stops spamming E while already fishing
	# only a spot showing the fish bubble can be fished, not one in use or used up
	if state == MarkerState.NEAR and player_inside and player_inside.can_move and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if not GameState.has_level(required_level):
			TextBox.show_message(GameState.level_lock_message(required_level))
			return
		state = MarkerState.FISHING
		anim_time = 0.0
		print("fishing requested at ", name)
		fishing_requested.emit(self)

func _start_fishing(_spot: FishingSpot) -> void:
	var player := player_inside   # keep a reference in case they leave the area mid-game
	player.can_move = false
	var direction := player.global_position.direction_to(global_position)
	var area := get_parent() as MapArea
	if area:
		direction = area.get_fishing_direction(player.global_position, global_position)
	await player.cast_fishing_rod(direction)
	player.wait_for_fishing_result()
	var game := MINIGAME.instantiate()
	if fish_override:
		game.fish = fish_override
	game.fishing_finished.connect(_on_fishing_finished.bind(game, player))
	add_child(game)

func _on_fishing_finished(success: bool, fish: FishType, value: int, game: Node, player: Player) -> void:
	print("caught: ", success, " ", fish.fish_name if fish else "")
	game.queue_free()
	if success:
		await player.reel_in_fish()
	player.stop_fishing_animation()
	player.can_move = true
	finish_fishing()  # hides the bubble until the spot respawns
	fishing_done.emit(success, fish, value)
