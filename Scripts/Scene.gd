extends Spatial
class_name Scene

signal switch_scene(scene, transition)
func switch_scene(scene, transition=true):
	emit_signal("switch_scene", scene, transition)

func exit():
	get_tree().quit()

func toggle_fullscreen():
	OS.window_fullscreen = !OS.window_fullscreen

func set_volume(value):
	if value <= -30:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
