extends MeshInstance

export(Vector3) var move_dist = Vector3(0, -PI/2, 0)

var close = [preload("res://Assets/Audio/fxDoorClose01.ogg"), preload("res://Assets/Audio/fxDoorClose02.ogg"),
			 preload("res://Assets/Audio/fxDoorClose03.ogg"), preload("res://Assets/Audio/fxDoorClose04.ogg"),
			 preload("res://Assets/Audio/fxDoorClose05.ogg")]
			
var open = [preload("res://Assets/Audio/fxDoorOpen01.ogg"), preload("res://Assets/Audio/fxDoorOpen02.ogg"),
			 preload("res://Assets/Audio/fxDoorOpen03.ogg"), preload("res://Assets/Audio/fxDoorOpen04.ogg")]


var moved = false

const scene = preload("res://Objects/MoveableDoorCollider.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	add_child(scene.instance())

func move():
	for i in get_children():
		if i == $AudioStreamPlayer3D:
			continue
		i.queue_free()
	if moved:
		$AudioStreamPlayer3D.stream = close[randi()%len(close)]
		$AudioStreamPlayer3D.play()
		rotation -= move_dist
	else:
		$AudioStreamPlayer3D.stream = open[randi()%len(open)]
		$AudioStreamPlayer3D.play()
		rotation += move_dist
	moved = not moved
	add_child(scene.instance())
