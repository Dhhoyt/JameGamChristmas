extends MeshInstance
export var title = "Inventory"
export var itemPaths = []
export var capacity = 4
var items = []
func _ready():
	for item in itemPaths:
		items.append(load(item))
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
