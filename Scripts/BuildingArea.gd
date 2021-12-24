extends Panel
export(NodePath) var itemBarPath
export(NodePath) var playerPath

var itemBar
var player
var itemTitles = ["Doll", "Broom", "Buttons", "Cotton", "Shirt", "Trousers", "Shoes"]
var itemsCollected = 0
const CIRCLE = preload("res://Assets/UI/Icons/circle.png")

func _ready():
	itemBar = get_node(itemBarPath)
	player = get_node(playerPath)
func remove_item_bar(index):
	if player.in_inventory:
		if itemBar.can_take_item(index) and can_add_item(itemBar.items[index]):
			add_item(itemBar.take_item(index))
func can_add_item(item):
	if item.title in itemTitles:
		return true
func add_item(item):
	get_child(item.title).texture_normal = item.img
	itemsCollected += 1
	if itemsCollected >= 7:
		itemBar.add_item(load("res://Objects/Items/FinishedDoll.tscn").instance())
		$Doll.texture_normal = CIRCLE
		$Broom.texture_normal = CIRCLE
		$Buttons.texture_normal = CIRCLE
		$Shirt.texture_normal = CIRCLE
		$Cotton.texture_normal = CIRCLE
		$Trousers.texture_normal = CIRCLE
		$Shoes.texture_normal = CIRCLE
