extends Node2D

@onready var label = $AnimatedSprite2D/label

signal button_pressed(number, spawn_id)
signal out_of_screen(number, spawn_id)

var number
var speed = 10
var spawn_id := 0   # 🔑 ADD THIS


func set_label(t):
	label.text = str(t)
	number = t
#
#func setup(color: Color):
#	sprite.modulate = color

func set_speed(s):
	speed = s


func _physics_process(delta):
	position.y += speed * delta

	var screen_size = get_viewport_rect().size
	if position.y > (screen_size.y + 160):
		emit_signal("out_of_screen", number, spawn_id)
		queue_free()


func _on_button_pressed():
	emit_signal("button_pressed", number, spawn_id)
	queue_free()
