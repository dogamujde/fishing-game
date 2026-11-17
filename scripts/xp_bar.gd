extends CanvasLayer
## Small XP bar in the top left corner. It fills up toward the XP the current level needs.

const TEXT_COLOR := Color(0.15, 0.15, 0.25)
const BAR_SIZE := Vector2(64, 6)

var back: ColorRect  # dark outline and empty part of the bar
var fill: ColorRect  # the filled part
var label: Label  # shows the level and xp numbers


func _ready() -> void:
	back = ColorRect.new()
	back.color = TEXT_COLOR
	back.position = Vector2(8, 8)
	back.size = BAR_SIZE + Vector2(2, 2)  # 1 pixel border all around
	add_child(back)
	var empty := ColorRect.new()
	empty.color = Color(0.85, 0.85, 0.8)
	empty.position = Vector2(1, 1)
	empty.size = BAR_SIZE
	back.add_child(empty)
	fill = ColorRect.new()
	fill.color = Color(0.35, 0.75, 0.4)  # green
	fill.position = Vector2(1, 1)
	fill.size = Vector2(0, BAR_SIZE.y)
	back.add_child(fill)
	label = Label.new()
	label.position = Vector2(8 + BAR_SIZE.x + 6, 4)
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", TEXT_COLOR)
	label.add_theme_constant_override("outline_size", 2)
	add_child(label)
	GameState.xp_changed.connect(_on_xp_changed)
	_on_xp_changed(GameState.xp, GameState.get_xp_needed())  # show the starting values


func _on_xp_changed(current_xp: int, needed_xp: int) -> void:
	var ratio := clampf(float(current_xp) / needed_xp, 0.0, 1.0)
	fill.size.x = round(BAR_SIZE.x * ratio)
	label.text = "Lv " + str(GameState.level) + "  " + str(current_xp) + "/" + str(needed_xp)
