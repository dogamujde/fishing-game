extends CanvasLayer
## A Pokemon-style text box at the bottom of the screen for tips and messages

const TEXT_COLOR := Color(0.15, 0.15, 0.25)  # dark blue-gray, easy to read on white

@onready var panel: PanelContainer = $PanelContainer  # the white box
@onready var label: Label = $PanelContainer/Label  # the text inside the box


func _ready() -> void:  # runs once when the game starts
	process_mode = Node.PROCESS_MODE_ALWAYS  
	panel.position = Vector2(8, 128)  # near the bottom of the 320x180 screen
	panel.size = Vector2(304, 44)  # almost the full width, tall enough for a few lines
	var style := StyleBoxFlat.new()  # a plain box style we can color
	style.bg_color = Color.WHITE  # white background
	style.border_color = TEXT_COLOR  
	style.set_border_width_all(2)  # 2 pixel border on every side
	style.set_corner_radius_all(3)  # slightly rounded corners
	style.set_content_margin_all(6)  # space between the border and the text
	panel.add_theme_stylebox_override("panel", style)  
	label.add_theme_color_override("font_color", TEXT_COLOR)  # dark text on the white box
	label.add_theme_font_size_override("font_size", 8)  # small enough to fit a few lines
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART  # wrap long text onto the next line
	hide()  


func show_message(text: String) -> void:  # shows a message and pauses the game
	label.text = text  # put the message in the box
	show()  # make the box visible
	get_tree().paused = true  # freeze the game while the player reads


func _unhandled_input(event: InputEvent) -> void: 
	if visible and event.is_action_pressed("interact"):  # E closes the box while it's open
		hide()  # close the box
		get_tree().paused = false 
		get_viewport().set_input_as_handled()  
