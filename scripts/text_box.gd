extends CanvasLayer
## A Pokemon-style text box at the bottom of the screen for tips and messages

const TEXT_COLOR := Color(0.15, 0.15, 0.25)  

var queue: Array[String] = []  # messages waiting their turn

@onready var panel: PanelContainer = $PanelContainer  # the white box
@onready var label: Label = $PanelContainer/Label  # the text inside the box


func _ready() -> void:  # runs once when the game starts
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.position = Vector2(8, 128) 
	panel.size = Vector2(304, 44)  # almost the full width, tall enough for a few lines
	var style := StyleBoxFlat.new() 
	style.bg_color = Color.WHITE  # white background
	style.border_color = TEXT_COLOR
	style.set_border_width_all(2)  # 2 pixel border on every side
	style.set_corner_radius_all(3)  # slightly rounded corners
	style.set_content_margin_all(6)  
	panel.add_theme_stylebox_override("panel", style)
	label.add_theme_color_override("font_color", TEXT_COLOR)  # dark text on the white box
	label.add_theme_font_size_override("font_size", 8)  # small enough to fit a few lines
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART  # wrap long text onto the next line
	hide()


func show_message(text: String) -> void:  
	queue.append(text)  # put the message at the back of the line
	if not visible:  
		_show_next()  


func _show_next() -> void:  # shows the next message, or closes the box when none are left
	if queue.is_empty():  # nothing left to show
		hide()  
		get_tree().paused = false 
		return 
	label.text = queue.pop_front()  # take the next message off the front of the line
	show()  
	get_tree().paused = true 


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("interact"): 
		get_viewport().set_input_as_handled()
		_show_next()  
