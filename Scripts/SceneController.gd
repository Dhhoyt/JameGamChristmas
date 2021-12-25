extends Spatial

#var PRELOAD_SCENES = [preload("res://Scenes/TitleScreen.tscn"), preload("res://Scenes/Santa's House.tscn")]
var load_scene
var switching = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$TransitionAnimations.play("FadeIn")

func switch_scene(scene, transition):
	if not switching:
		load_scene = scene
		switching = true
		if transition:
			$TransitionAnimations.play("FadeOut")
			$TransitionAnimations.connect("animation_finished", self, "load_new_scene")
		else:
			load_new_scene()
func load_new_scene(bruh=0):
	$Current.get_child(0).queue_free()
	
	var new_scene = load(load_scene).instance()
	new_scene.connect("switch_scene", self, "switch_scene")
	$TransitionAnimations.disconnect("animation_finished", self, "load_new_scene")
	$TransitionAnimations.play("FadeIn")
	switching = false
	$Current.add_child(new_scene)

func set_volume(value):
	if value <= -30:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func exit():
	get_tree().quit()

func toggle_fullscreen():
	OS.window_fullscreen = !OS.window_fullscreen

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
