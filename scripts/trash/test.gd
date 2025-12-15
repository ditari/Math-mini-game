extends Node2D

var objscene: PackedScene = load("res://scenes/obj.tscn")

const COLORS = [
	Color("#E74C3C"),
	Color("#3498DB"),
	Color("#2ECC71"),
	Color("#F1C40F"),
	Color("#9B59B6"),
	Color("#E67E22"),
	Color("#1ABC9C"),
	Color("#FF69B4"),
	Color("#A3E635"),
	Color("#EC4899")# dark blue
]




# Called when the node enters the scene tree for the first time.
func _ready():
	var obj = objscene.instantiate()
	add_child(obj)
	obj.setup(3, COLORS[2])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
