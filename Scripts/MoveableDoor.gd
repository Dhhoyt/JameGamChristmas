extends MeshInstance

export(Vector3) var move_dist = Vector3(0, -PI/2, 0)

var CLOSE_SOUNDS = [preload("res://Assets/Audio/fxDoorClose01.ogg"), preload("res://Assets/Audio/fxDoorClose02.ogg"),
			 preload("res://Assets/Audio/fxDoorClose03.ogg"), preload("res://Assets/Audio/fxDoorClose04.ogg"),
			 preload("res://Assets/Audio/fxDoorClose05.ogg")]
			
var OPEN_SOUNDS = [preload("res://Assets/Audio/fxDoorOpen01.ogg"), preload("res://Assets/Audio/fxDoorOpen02.ogg"),
			 preload("res://Assets/Audio/fxDoorOpen03.ogg"), preload("res://Assets/Audio/fxDoorOpen04.ogg")]
			
var open = false

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
	if open:
		$AudioStreamPlayer3D.stream = CLOSE_SOUNDS[randi()%len(CLOSE_SOUNDS)]
		$AudioStreamPlayer3D.play()
		rotation -= move_dist
	else:
		$AudioStreamPlayer3D.stream = OPEN_SOUNDS[randi()%len(OPEN_SOUNDS)]
		$AudioStreamPlayer3D.play()
		rotation += move_dist
	open = not open
	add_child(scene.instance())

func get_interaction_text():
	return ("Click to close" if open else "Click to open")
