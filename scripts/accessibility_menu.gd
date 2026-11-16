extends CanvasLayer
## Accessibility menu. Esc opens it, and it lists the controls.

const TEXT_COLOR := Color(0.15, 0.15, 0.25)
const HOVER_COLOR := Color(0.85, 0.92, 1.0)  # light blue behind a key the mouse is over
const ACTIONS := {  # action name from the Input Map, then the name players see
	"move_up": "Move up",
	"move_down": "Move down",
	"move_left": "Move left",
	"move_right": "Move right",
	"interact": "Fish / continue",
}

@onready var panel: PanelContainer = $PanelContainer
@onready var rows: VBoxContainer = $PanelContainer/VBoxContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keeps working while the game is paused
	panel.add_theme_stylebox_override("panel", _box_style(Color.WHITE, 2, 8))
	rows.add_theme_constant_override("separation", 3)
	rows.add_child(_make_label("Accessibility", 10))
	for action in ACTIONS:  # one row for each action
		var row := HBoxContainer.new()
		var name_label := _make_label(ACTIONS[action], 8)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # pushes the key to the right side
		row.add_child(name_label)
		row.add_child(_make_key_button(action))
		rows.add_child(row)
	rows.add_child(_make_label("Press Esc to close", 8))
	panel.size = Vector2(176, 0)  # fixed width, and the height grows to fit the rows
	panel.position = (Vector2(320, 180) - panel.size) / 2  # center it on the screen
	hide()


func _box_style(bg_color: Color, border: int, margin: int) -> StyleBoxFlat:  # a box with a dark border
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = TEXT_COLOR
	style.set_border_width_all(border)
	style.set_corner_radius_all(3)
	style.set_content_margin_all(margin)
	return style


func _make_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", TEXT_COLOR)
	label.add_theme_font_size_override("font_size", font_size)
	return label


func _make_key_button(action: String) -> Button:  # a white key showing the action's current key
	var button := Button.new()
	button.text = _key_name(action)
	button.custom_minimum_size = Vector2(48, 0)
	button.add_theme_font_size_override("font_size", 8)
	button.add_theme_stylebox_override("normal", _box_style(Color.WHITE, 1, 2))
	button.add_theme_stylebox_override("hover", _box_style(HOVER_COLOR, 1, 2))
	button.add_theme_stylebox_override("pressed", _box_style(HOVER_COLOR, 1, 2))
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(color_name, TEXT_COLOR)  # dark text in every state, for contrast
	return button


func _key_name(action: String) -> String:  # the first key set for an action, like "W"
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event.as_text_physical_keycode()
	return "None"


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):  # only Esc matters here
		return
	if visible:
		hide()
		get_tree().paused = false
		get_viewport().set_input_as_handled()
	elif not get_tree().paused:  # don't open on top of the text box
		show()
		get_tree().paused = true
		get_viewport().set_input_as_handled()
