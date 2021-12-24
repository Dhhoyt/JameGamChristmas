extends Panel
export(NodePath) var itemBarPath
export(NodePath) var playerPath
export(NodePath) var gridContainerPath

var itemBar
var player
var gridContainer
var currentInventoryObject
const CIRCLE = preload("res://Assets/UI/Icons/circle.png")

func _ready():
	itemBar = get_node(itemBarPath)
	player = get_node(playerPath)
	gridContainer = get_node(gridContainerPath)
	for i in range(gridContainer.get_child_count()):
		gridContainer.get_child(i).connect("pressed", self, "remove_item", [i])
func display_inventory(inventoryObject):
	currentInventoryObject = inventoryObject
	for child in gridContainer.get_children():
		child.hide()
		child.texture_normal = CIRCLE
	for i in range(inventoryObject.capacity):
		gridContainer.get_child(i).show()
		if i < len(inventoryObject.items):
			gridContainer.get_child(i).texture_normal = inventoryObject.items[i].get_image()
			print(inventoryObject.items[i])
func update_inventory():
	for child in gridContainer.get_children():
		child.hide()
	for i in range(currentInventoryObject.capacity):
		gridContainer.get_child(i).show()
		if i < len(currentInventoryObject.items):
			gridContainer.get_child(i).texture_normal = currentInventoryObject.items[i].get_image()
			print(currentInventoryObject.items[i])
func remove_item(index):
	if player.in_inventory:
		if currentInventoryObject.can_take_item(index) and itemBar.can_add_item():
			itemBar.add_item(currentInventoryObject.take_item(index))
			display_inventory(currentInventoryObject)
func remove_item_bar(index):
	if player.in_inventory:
		if itemBar.can_take_item(index) and currentInventoryObject.can_add_item():
			currentInventoryObject.add_item(itemBar.take_item(index))
			display_inventory(currentInventoryObject)
