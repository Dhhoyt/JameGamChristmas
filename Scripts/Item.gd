extends Node
class_name Item, "res://Assets/UI/Icons/circle.png"
export var title = "Item"
export var icon = "res://Assets/UI/Icons/circle.png"
var texture

func _init(t, i):
	title = t
	icon = i
	texture = load(icon)
