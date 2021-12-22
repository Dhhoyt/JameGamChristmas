extends KinematicBody

var path = []
var path_node = 0

var speed = 50

onready var nav = get_parent()
onready var player = $"../../Player"

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		elif (not $VisibilityNotifier.is_on_screen()) or blocked():
			move_and_slide(direction.normalized() * speed, Vector3.UP)

func blocked():
	var space_state = get_world().direct_space_state
	for i in $"Cast Points".get_children():
		var result = space_state.intersect_ray(i.global_transform.origin, player.global_transform.origin, [self,player], 2)
		if result.empty():
			return false
	return true

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func _on_Timer_timeout():
	move_to(player.global_transform.origin)
