extends Node2D

@onready var flash_rect := $CanvasLayer/Control/ColorRect
#func flash_screen(color: Color = Color.WHITE, duration := 0.1):
#	flash_rect.color = color
#	flash_rect.modulate.a = 1.0

#	var tween = create_tween()
#	tween.tween_property(flash_rect, "modulate:a", 0.0, duration)
	
func flash_screen(color: Color = Color.WHITE, duration := 0.1):
	flash_rect.color = color
	flash_rect.modulate.a = 0.6

	var tween = create_tween()
	tween.tween_property(flash_rect, "modulate:a", 0.0, duration)\
		.set_trans(Tween.TRANS_LINEAR)

	
func glow_screen(color: Color = Color(1, 1, 1), duration := 0.25, intensity := 0.15):
	flash_rect.color = color
	flash_rect.modulate.a = intensity

	var tween = create_tween()
	tween.tween_property(flash_rect, "modulate:a", 0.0, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(3).timeout
	flash_screen(Color.RED)
	#flash_screen(Color.WHITE, 0.08)
	await get_tree().create_timer(3).timeout
	glow_screen(Color(0.8, 1, 0.8))
	#flash_screen(Color.RED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
