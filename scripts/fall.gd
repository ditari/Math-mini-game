extends Node2D

var fallboxscene: PackedScene = load("res://scenes/fallbox.tscn")
var fallbox

var gaps

# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size = get_viewport_rect().size
	
	#var screen_size_x = screen_size.x
	#var screen_size_y = screen_size.y
	gaps = ((screen_size.x - (160*3))/4) + 64
	
	fallbox = fallboxscene.instantiate()
	fallbox.position = Vector2(gaps,128)
	
	$arrayboxes.add_child(fallbox)
	fallbox.set_label("1")
	fallbox.set_speed(200)
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
