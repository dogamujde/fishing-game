extends HBoxContainer

@export var full_heart: Texture2D
@export var empty_heart: Texture2D

var follow_target: Node2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 3)

func update_hearts(hits_left: int, max_hits: int) -> void:
	while get_child_count() < max_hits:
		var heart := TextureRect.new()
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = Vector2(9, 9)
		heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(heart)

	for i in range(get_child_count()):
		var heart := get_child(i) as TextureRect
		heart.visible = i < max_hits
		heart.texture = full_heart if i < hits_left else empty_heart

func _process(_delta: float) -> void:
	if not is_instance_valid(follow_target):
		return

	var screen_position := follow_target.get_global_transform_with_canvas().origin
	var row_width := get_combined_minimum_size().x
	position = (screen_position + Vector2(-row_width / 2.0, -22)).round()
