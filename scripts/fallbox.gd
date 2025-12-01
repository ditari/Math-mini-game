extends Node2D


@onready var label = $box/label
var number
var speed = 10

# Called when the node enters the scene tree for the first time.
signal button_pressed(number)

func set_label(text):
	label.text = text
	
func set_speed(s):
	speed = s
	
func _physics_process(delta):
	position.y += speed * delta
	
	var screen_size = get_viewport_rect().size
	if position.y > (screen_size.y +160):
		queue_free()
		
func _on_button_pressed():
	emit_signal("button_pressed", number)
	queue_free()
