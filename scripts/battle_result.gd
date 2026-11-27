extends Node2D
## Battle result card drawn over the arena at the game's logical resolution.

signal confirmed

const BASE_SIZE := Vector2(320, 180)
const TITLE_FONT := preload("res://assets/SuperMario256.ttf")
const INK := Color("#f2f1dc")
const SECONDARY := Color("#b5c5c4")
const RETURN_BUTTON := Rect2(104, 127, 112, 16)

var _won: bool
var _fish_name: String
var _fish_art: Texture2D
var _catch_xp: int
var _fight_xp: int
var _confirmed := false


func setup(won: bool, fish: FishType, catch_xp: int, fight_xp: int) -> void:
	_won = won
	_fish_name = fish.fish_name
	_fish_art = fish.sprite_texture
	if _fish_art == null and fish.motion_frames:
		_fish_art = fish.motion_frames.get_frame_texture(&"idle", 0)
	_catch_xp = catch_xp
	_fight_xp = fight_xp


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	get_viewport().size_changed.connect(_layout)
	_layout()


func _layout() -> void:
	position = ((get_viewport_rect().size - BASE_SIZE) / 2.0).round()
	queue_redraw()


func _input(event: InputEvent) -> void:
	if _confirmed:
		return
	var clicked: bool = event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT and RETURN_BUTTON.has_point(make_input_local(event).position)
	if event.is_action_pressed(&"interact") or clicked:
		get_viewport().set_input_as_handled()
		_confirmed = true
		confirmed.emit()


func _draw() -> void:
	var accent := Color("#eac57c") if _won else Color("#c9b4de")
	var body_font := ThemeDB.fallback_font
	draw_rect(Rect2(-position, get_viewport_rect().size), Color(0.04, 0.1, 0.14, 0.66))
	draw_rect(Rect2(72, 29, 180, 126), Color("#101c24"))
	draw_rect(Rect2(70, 26, 180, 126), accent)
	draw_rect(Rect2(71, 27, 178, 124), Color("#23383f"))
	draw_rect(Rect2(73, 29, 174, 120), Color("#192a31"))
	draw_line(Vector2(84, 93), Vector2(236, 93), Color("#4a6063"))
	_draw_centered("VICTORY" if _won else "DEFEAT", 49, TITLE_FONT, 19, accent)
	if _fish_art:
		var art_size := _fish_art.get_size()
		var scale_factor := minf(1.0, minf(38.0 / art_size.x, 18.0 / art_size.y))
		var display_size := (art_size * scale_factor).round()
		draw_texture_rect(_fish_art, Rect2((Vector2(160, 63) - display_size / 2.0).round(), display_size), false)
	_draw_centered(_fish_name, 83, body_font, 11, INK)
	draw_string(body_font, Vector2(86, 106), "Catch XP", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, SECONDARY)
	draw_string(body_font, Vector2(86, 118), "Fight XP", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, SECONDARY)
	draw_string(body_font, Vector2(166, 106), "+%d" % _catch_xp, HORIZONTAL_ALIGNMENT_RIGHT, 68, 8, INK)
	draw_string(body_font, Vector2(166, 118), "+%d" % _fight_xp, HORIZONTAL_ALIGNMENT_RIGHT, 68, 8, accent if _won else SECONDARY)
	draw_rect(RETURN_BUTTON, accent)
	draw_rect(RETURN_BUTTON.grow(-1.0), Color("#314b4f"))
	_draw_centered("E  Return to map", 138, body_font, 8, INK)


func _draw_centered(value: String, baseline: float, font: Font, font_size: int, color: Color) -> void:
	var width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, Vector2(round((BASE_SIZE.x - width) / 2.0), baseline),
			value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
