extends Spatial
class_name Scene

signal switch_scene(scene, transition)
func switch_scene(scene, transition=true):
	emit_signal("switch_scene", scene, transition)
