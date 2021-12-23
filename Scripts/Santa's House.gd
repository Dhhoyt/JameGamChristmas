extends Spatial

var noiseies = []

var krampus_turn_off_dist = 1

func add_noisy(new_noisy):
	noiseies.append(new_noisy)
	new_noisy.play()
	
func remove_noisy(new_noisy):
	noiseies.erase(new_noisy)
	new_noisy.play()
	
func _physics_process(delta):
	for i in noiseies:
		if i.global_transform.origin.distance_to($Krampus.global_transform.origin) < krampus_turn_off_dist:
			noiseies.erase(i)
			i.stop()

func _on_Timer_timeout():
	for i in noiseies:
		$Krampus.noise(i.global_transform_origin, 100000, 2)
