extends Button

@export var press_scale := 0.96
@export var press_time := 0.08

func _ready():
	pivot_offset = size * 0.5

func _pressed():
	scale = Vector2(press_scale, press_scale)
	await get_tree().create_timer(press_time).timeout
	scale = Vector2.ONE
