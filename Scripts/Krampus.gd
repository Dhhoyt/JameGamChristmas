extends KinematicBody

var path = []
var path_node = 0

var speed = 5
var hearing_dist = 5

var state = 2 #0 = chase 1 = investigating 2 = wander

onready var nav = get_parent()
onready var player = $"../../Player"
onready var spots = $"../RandomSpots"

var noise_pos = Vector3()

func _ready():
	player.add_enemy(self)

func _physics_process(delta):
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		else:
			move_and_slide(direction.normalized() * speed, Vector3.UP)
	else:
		if state == 1:
			state = 2
			new_spot()
		elif state == 2:
			new_spot()

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func random_spot():
	var available = spots.get_children()
	return available[randi() % available.size()].global_transform.origin

func new_spot():
	if state == 0:
		move_to(player.global_transform.origin)
	elif state == 1:
		move_to(noise_pos)
	elif state == 2:
		move_to(random_spot())
		
func noise(pos):
	if (pos - global_transform.origin).length() < hearing_dist:
		state = 1
		move_to(pos)
