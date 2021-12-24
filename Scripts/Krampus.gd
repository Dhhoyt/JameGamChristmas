extends KinematicBody

var path = []
var path_node = 0

var speed = 5
var hearing_dist = 5
var fov = cos(PI/2)

var investigated = false
var state = 2 #0 = chase 1 = investigating 2 = wander

onready var nav = $"../DetourNavigation"
onready var player = $"../Player"
onready var spots = $"../RandomSpots"
onready var doors = $"../DetourNavigation/Doors"

var current_priority = 0
var noise_pos = Vector3()

func _ready():
	randomize()
	player.add_enemy(self)
	new_spot()

func _process(delta):
	if within_view():
		state = 0
		new_spot()
	if state == 0:
		$krampus/AnimationPlayer.play("Chase")
		$krampus.look_at(player.global_transform.origin, Vector3.UP)
		$krampus.rotation_degrees = Vector3(0, $krampus.rotation_degrees.y-90, 0)
	elif state == 1 or state == 2:
		$krampus/AnimationPlayer.play("Wander")
		$krampus.look_at(path[path_node], Vector3.UP)
		$krampus.rotation_degrees = Vector3(0, $krampus.rotation_degrees.y-90, 0)
	else:
		$krampus/AnimationPlayer.play("Stand")
		$krampus.look_at(path[path_node], Vector3.UP)
		$krampus.rotation_degrees = Vector3(0, $krampus.rotation_degrees.y-90, 0)
	for i in doors.get_children():
		if i.moved:
			continue
		if not (global_transform.origin - i.global_transform.origin).length() < .75:
			continue
		var facing = (path[path_node] - global_transform.origin)
		var diff = i.global_transform.origin - global_transform.origin
		if facing.normalized().dot(diff.normalized()) > fov:
			i.move()

func _physics_process(delta):
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < delta * speed * 1.2:
			path_node += 1
			if path_node >= path.size():
				path_node = 0
				if state == 0 and not within_view():
					state = 2
				current_priority = 0
				new_spot()
				return
		direction = (path[path_node] - global_transform.origin)
		move_and_slide(direction.normalized() * speed, Vector3.UP)
	else:
		new_spot()


func move_to(target_pos):
	path = nav.get_node("DetourNavigationMesh").find_path(global_transform.origin, target_pos)["points"]
	if path.size() == 0:
		state = 2
		new_spot()
	path_node = 0
	
func within_view():
	if player.hiding or path.size() <= path_node:
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
		state = 2
		move_to(random_spot())
	elif state == 2:
		move_to(random_spot())

func noise(pos, loudness, priority):
	if priority >= current_priority and (pos - global_transform.origin).length() * (1/loudness) < hearing_dist and not state == 0:
		current_priority = priority
		state = 1
		move_to(pos)
