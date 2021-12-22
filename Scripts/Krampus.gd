extends KinematicBody

var path = []
var path_node = 0

var speed = 5
var hearing_dist = 5
var fov = cos(PI/4)

var investigated = false
var state = 2 #0 = chase 1 = investigating 2 = wander

onready var nav = get_parent()
onready var player = $"../../Player"
onready var spots = $"../RandomSpots"

var current_priority = 0
var noise_pos = Vector3()

func _ready():
	player.add_enemy(self)
	new_spot()

func _process(delta):
	if within_view():
		$ChaseTimer.start()
		state = 0
		new_spot()

func _physics_process(delta):
	var direction = (path[path_node] - global_transform.origin)
	if path_node < path.size():
		if direction.length() < 1:
			path_node += 1
			if path_node >= path.size():
				path_node = 0
				if state == 0 and not within_view():
					state = 2
				current_priority = 0
				new_spot()
	else:
		new_spot()
	direction = (path[path_node] - global_transform.origin)
	move_and_slide(direction.normalized() * speed, Vector3.UP)


func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0
	
func within_view():
	if player.hiding:
		return false
	var facing = (path[path_node] - global_transform.origin)
	var diff = player.global_transform.origin - global_transform.origin
	if not facing.normalized().dot(diff.normalized()) > fov:
		return false
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(global_transform.origin, player.global_transform.origin, [self,player], 2)
	return result.empty()

func random_spot():
	var available = spots.get_children()
	return available[randi() % available.size()].global_transform.origin

func new_spot():
	if state == 0:
		move_to(player.global_transform.origin)
	elif state == 1:
		if investigated:
			state = 2
			move_to(random_spot())
		else:
			investigated = true
			move_to(noise_pos)
	elif state == 2:
		move_to(random_spot())
	elif state == 3:
		move_to(noise_pos)

func noise(pos, priority):
	if (pos - global_transform.origin).length() < hearing_dist and priority > current_priority:
		$NoiseTimer.start()
		state = 1
		investigated = false
		move_to(pos)
