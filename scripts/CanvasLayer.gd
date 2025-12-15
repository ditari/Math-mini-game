extends CanvasLayer

@onready var flash_rect := $Control/ColorRect
func flash_screen(color: Color = Color.WHITE, duration := 0.1):
	flash_rect.color = color
	flash_rect.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_property(flash_rect, "modulate:a", 0.0, duration)
