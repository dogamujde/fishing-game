class_name LevelGate
extends Area2D

# the gate stays locked until the player reaches this level
@export var required_level: int = 3
# the scene the gate takes you to, empty until jasons new world is in
@export_file("*.tscn") var target_scene: String = ""

@onready var level_label: Label = $LevelLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	GameState.leveled_up.connect(_on_leveled_up)
	# small font so it fits the 320x180 screen
	level_label.add_theme_font_size_override("font_size", 8)
	# dark text so it shows up on the light wall
	level_label.add_theme_color_override("font_color", Color(0.15, 0.15, 0.25))
	_update_label()

func _on_body_entered(body: Node2D) -> void:
	if not (body is Player):
		return
	if not GameState.has_level(required_level):
		TextBox.show_message(GameState.level_lock_message(required_level))
		return
	if target_scene == "":
		TextBox.show_message("The gate is open, but the new world isn't ready yet.")
		return
	GameState.go_to_map(target_scene)  # remembers the new world so fights send you back there

func _on_leveled_up(new_level: int) -> void:
	_update_label()
	# only say it once, on the exact level the gate opens
	if new_level == required_level:
		TextBox.show_message.call_deferred("You're level " + str(required_level) + " now, the gate at the top of the path is open!")  # deferred so it shows after the level up message

func _update_label() -> void:
	# shows what level you need and hides once you have it
	level_label.text = "Lv " + str(required_level)
	level_label.visible = not GameState.has_level(required_level)
