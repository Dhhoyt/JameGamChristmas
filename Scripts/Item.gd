extends Node
class_name Item, "res://Assets/UI/Icons/flashlight.png"
export var title = "Item"
export var imgPath = "res://Assets/UI/Icons/flashlight.png"

func get_image():
	return load(imgPath)
