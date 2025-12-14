extends Node2D

var objscene: PackedScene = load("res://scenes/obj.tscn")

const COLORS = [
	Color("#e74c3c"), # red
	Color("#f1c40f"), # yellow
	Color("#2ecc71"), # green
	Color("#3498db"), # blue
	Color("#9b59b6"), # purple
	Color("#1abc9c"), # cyan
	Color("#e67e22"), # orange
	Color("#ecf0f1"), # white
	Color("#95a5a6"), # gray
	Color("#34495e")  # dark blue
]


# Called when the node enters the scene tree for the first time.
func _ready():
	var obj = objscene.instantiate()
	add_child(obj)
	obj.setup(3, COLORS[2])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
