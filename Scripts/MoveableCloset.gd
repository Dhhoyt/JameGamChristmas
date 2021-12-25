extends MeshInstance

export(Vector3) var move_dist = Vector3(0, 90, 0)

var moved = false

const scene = preload("res://Objects/MoveableClosetCollider.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(scene.instance())

func move():
	for i in get_children():
		i.queue_free()
	if moved:
		transform.origin -= move_dist
	else:
		transform.origin += move_dist
	moved = not moved
	add_child(scene.instance())

func get_interaction_text():
	return "Click to move"
