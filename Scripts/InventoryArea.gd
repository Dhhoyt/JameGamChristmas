extends Panel
var ItemBar
var Player
var currentInventoryObject
func _init():
	for i in range($GridContainer.get_child_count()):
		$GridContainer.get_child(i).connect("pressed", self, "remove_item", [i])
func display_inventory(inventoryObject):
	currentInventoryObject = inventoryObject
	for child in $GridContainer.get_children():
		child.hide()
	for i in range(inventoryObject.capacity):
		$GridContainer.get_child(i).show()
		if i < len(inventoryObject.inventory):
			$GridContainer.get_child(i).texture = inventoryObject.inventory[i].texture
func remove_item(index):
	if Player.in_inventory:
		if ItemBar.can_add_item():
			ItemBar.add_item(currentInventoryObject.take_item(index))
			display_inventory(currentInventoryObject)
func remove_item_bar(index):
	if Player.in_inventory:
		if currentInventoryObject.can_add_item():
			currentInventoryObject.add_item(ItemBar.take_item(index))
			display_inventory(currentInventoryObject)
