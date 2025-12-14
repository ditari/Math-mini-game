extends Sprite2D

func _ready():
	await get_tree().process_frame

	if texture == null:
		return

	var screen_size = get_viewport().get_visible_rect().size
	var tex_size = texture.get_size()

	var scale_factor = max(
		screen_size.x / tex_size.x,
		screen_size.y / tex_size.y
	)

	scale = Vector2.ONE * scale_factor
	global_position = screen_size / 2
