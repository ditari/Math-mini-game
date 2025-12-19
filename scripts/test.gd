extends Node2D

var fallboxscene: PackedScene = load("res://scenes/testbox.tscn")

const box_width := 206 #untuk scale 0.7 atau 0.75
var count := 3
var y := 520   # vertical position of boxes



# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_width := get_viewport_rect().size.x

	var gap := (screen_width - count * box_width) / (count + 1)

	for i in range(count):
		var box = fallboxscene.instantiate()
		add_child(box)

		box.position = Vector2(
			gap + box_width / 2 + i * (box_width + gap),
			y
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
