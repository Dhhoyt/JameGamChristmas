extends MeshInstance
export var title = "Inventory"
var items = []
var capacity = 4
func add_item(item):
	if len(items) < capacity:
		items.append(item)
func take_item(index):
	if len(items) >= index:
		var item = items[index]
		items.remove(index)
		return item
func can_add_item():
	return len(items) < capacity
