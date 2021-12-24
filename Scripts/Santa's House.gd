extends Spatial

var noiseies = []
var chaseSounds = [preload("res://Assets/Audio/fxChase01.ogg"), preload("res://Assets/Audio/fxChase02.ogg"), preload("res://Assets/Audio/fxChase04.ogg")]
var ambientSounds = [preload("res://Assets/Audio/ambientBells.ogg"), preload("res://Assets/Audio/ambientCarol01.ogg"), preload("res://Assets/Audio/ambientCarol01.ogg"), preload("res://Assets/Audio/ambientCarol02.ogg"), preload("res://Assets/Audio/ambientCarol03.ogg"), preload("res://Assets/Audio/ambientCarol04.ogg"), preload("res://Assets/Audio/ambientCarol05.ogg"), preload("res://Assets/Audio/ambientElf01.ogg"), preload("res://Assets/Audio/ambientGoat.ogg")]

var krampus_turn_off_dist = 1

func add_noisy(new_noisy):
	noiseies.push_front(new_noisy)
	new_noisy.play()
	
func remove_noisy(new_noisy):
	noiseies.erase(new_noisy)
	new_noisy.stop()
	
func _process(delta):
	if $Krampus.state == 0:
		$"Sound Effects/Ambient".stop()
		if not $"Sound Effects/Chase".playing:
			$"Sound Effects/Chase".stream = chaseSounds[randi()%len(chaseSounds)]
			$"Sound Effects/Chase".play()
	else:
		if not $"Sound Effects/Chase".playing:
			if not $"Sound Effects/Ambient".playing:
				if $"Sound Effects/AmbientTimer".time_left <= 0:
					$"Sound Effects/AmbientTimer".start(randi()%3)
func play_ambient():
	$"Sound Effects/Ambient".stream = ambientSounds[randi()%len(ambientSounds)]
	$"Sound Effects/Ambient".play()
func _physics_process(delta):
	for i in noiseies:
		if i.global_transform.origin.distance_to($Krampus.global_transform.origin) < krampus_turn_off_dist:
			noiseies.erase(i)
			i.stop()

func _on_Timer_timeout():
	print($Krampus.state)
	for i in noiseies:
		$Krampus.noise(i.global_transform.origin, 100000, 2)
