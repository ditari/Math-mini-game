extends Node2D

@onready var flash_rect := $CanvasLayer/Control/ColorRect
func flash_screen(color: Color = Color.WHITE, duration := 0.1):
	flash_rect.color = color
	flash_rect.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_property(flash_rect, "modulate:a", 0.0, duration)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(3).timeout
	flash_screen(Color.WHITE, 0.08)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
