extends Spatial

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func switch_scene(scene):
	get_tree().change_scene(scene)
