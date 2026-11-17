class_name FishingSpot
extends Area2D

# joseph's minigame connects to this, it says which spot the player is fishing at
signal fishing_requested(spot: FishingSpot)

# the player standing in this spot, null if nobody is here
var player_inside: Player = null

# marker bubble states: far = "!", near = fish, fishing = "...", done = hidden
enum MarkerState { FAR, NEAR, FISHING, DONE }
var state: MarkerState = MarkerState.FAR

# sheet frames: 0 "!", 1-2 fish, 3-5 dots
const FISH_FRAMES := [1, 2]
const DOT_FRAMES := [3, 4, 5, 5]
@export var bob_height: float = 2.0  # pixels the bubble floats up and down
@export var bob_speed: float = 3.0
@export var frame_fps: float = 4.0
@onready var marker: Sprite2D = $Marker
var marker_base_y: float
var anim_time: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	marker_base_y = marker.position.y

func _process(delta: float) -> void:
	if state == MarkerState.DONE:
		return
	anim_time += delta
	marker.position.y = marker_base_y + round(sin(anim_time * bob_speed) * bob_height)
	var step := int(anim_time * frame_fps)
	match state:
		MarkerState.FAR:
			marker.frame = 0
		MarkerState.NEAR:
			marker.frame = FISH_FRAMES[step % FISH_FRAMES.size()]
		MarkerState.FISHING:
			marker.frame = DOT_FRAMES[step % DOT_FRAMES.size()]

@export var respawn_time: float = 5.0  # seconds before a used spot can be fished again

# call this when the minigame is over, the marker hides and comes back after respawn_time
func finish_fishing() -> void:
	state = MarkerState.DONE
	marker.visible = false
	# false = timer stops while the game is paused (text box open)
	await get_tree().create_timer(respawn_time, false).timeout
	anim_time = 0.0
	marker.visible = true
	# if the player is still standing here go straight to the fish bubble
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
		state = MarkerState.FISHING
		anim_time = 0.0
		print("fishing requested at ", name)
		fishing_requested.emit(self)
