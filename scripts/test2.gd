extends Node2D


var fallboxscene: PackedScene = preload("res://scenes/box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	#var box = fallboxscene.instantiate()
	#add_child(box)

	#print(box.width)
	
	var temp_box := fallboxscene.instantiate()
	var anim := temp_box.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

	if anim == null or anim.sprite_frames == null:
		push_error("AnimatedSprite2D setup invalid")
		return

	var tex := anim.sprite_frames.get_frame_texture(anim.animation, 0)
	if tex == null:
		push_error("Frame texture missing")
		return

	var box_width: float = tex.get_width()
	print(box_width)
	temp_box.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
