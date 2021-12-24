extends MeshInstance
export var title = "Inventory"
export var itemPaths = []
export var capacity = 4
var items = []
func _ready():
	for i in itemPaths:
		var item = load(i).instance()
		items.append(item)
func add_item(item):
	if len(items) < capacity:
		items.append(item)
func take_item(index):
	if index < len(items):
		var item = items[index]
		items.remove(index)
		return item
func can_take_item(index):
	return index < len(items)
func can_add_item():
	return len(items) < capacity
