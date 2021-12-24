extends HBoxContainer
var selectedNum = 0
var items = []
const CIRCLE = preload("res://Assets/UI/Icons/circle.png")
func _input(event):
	if event.is_action_pressed("item1"):
		selectedNum = 0
	if event.is_action_pressed("item2"):
		selectedNum = 1
	if event.is_action_pressed("item3"):
		selectedNum = 2
	if event.is_action_pressed("item4"):
		selectedNum = 3
	if event.is_action_pressed("next_item"):
		selectedNum += 1
		if selectedNum >= get_child_count():
			selectedNum = 0
	if event.is_action_pressed("previous_item"):
		selectedNum -= 1
		if selectedNum < 0:
			selectedNum = 3
	update_selected()
func update_selected():
	for i in range(get_child_count()):
		if selectedNum == i:
			get_child(i).get_child(0).show()
		else:
			get_child(i).get_child(0).hide()
func update_images():
	for i in range(get_child_count()):
		get_child(i).texture_normal = CIRCLE
	for i in range(len(items)):
		get_child(i).texture_normal = items[i].get_image()
func add_item(item):
	if can_add_item():
		items.append(item)
		update_images()
func take_item(index):
	if len(items) >= index:
		var item = items[index]
		items.remove(index)
		update_images()
		return item
func remove_selected_item():
	items.remove(selectedNum)
	update_images()
func get_selected_item_name():
	if len(items) > selectedNum:
		return items[selectedNum].title
	return "Empty"
func can_add_item():
	return len(items) < get_child_count()
func can_take_item(index):
	return index < len(items)
