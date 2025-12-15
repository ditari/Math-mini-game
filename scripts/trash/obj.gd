extends Node2D


@onready var sprite: Sprite2D = $Sprite2D


var number := 0

func setup(n: int, color: Color):
	number = n
	sprite.modulate = color
