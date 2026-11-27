class_name FishMotion
extends RefCounted
## Samples the same two looping clips for battle sprites and minigame icons.

var frames: SpriteFrames
var _clip: StringName
var _elapsed := 0.0


func sample(delta: float, charging: bool) -> Texture2D:
	if frames == null:
		return null
	var clip := &"charge" if charging else &"idle"
	if clip != _clip:
		_clip = clip
		_elapsed = 0.0
	else:
		_elapsed += delta
	var frame_count := frames.get_frame_count(clip)
	var frame := int(_elapsed * frames.get_animation_speed(clip)) % frame_count
	return frames.get_frame_texture(clip, frame)
