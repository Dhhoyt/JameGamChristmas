extends Node
class_name Item, "res://Assets/UI/Icons/flashlight.png"
export var title = "Item"
export var imgPath = "res://Assets/UI/Icons/flashlight.png"
var img

func _ready():
	img = load(imgPath)
