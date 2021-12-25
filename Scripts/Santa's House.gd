extends Scene

var noiseies = []
var chaseSounds = [preload("res://Assets/Audio/fxChase01.ogg"), preload("res://Assets/Audio/fxChase02.ogg"), preload("res://Assets/Audio/fxChase04.ogg")]
var ambientSounds = [preload("res://Assets/Audio/ambientBells.ogg"), preload("res://Assets/Audio/ambientCarol01.ogg"), preload("res://Assets/Audio/ambientCarol02.ogg"), preload("res://Assets/Audio/ambientCarol03.ogg"), preload("res://Assets/Audio/ambientCarol04.ogg"), preload("res://Assets/Audio/ambientCarol05.ogg"), preload("res://Assets/Audio/ambientCarol06.ogg"), preload("res://Assets/Audio/ambientCarol07.ogg"), preload("res://Assets/Audio/ambientCarol08.ogg"), preload("res://Assets/Audio/ambientCarol09.ogg"), preload("res://Assets/Audio/ambientCarol10.ogg"), preload("res://Assets/Audio/ambientElf01.ogg"), preload("res://Assets/Audio/ambientGoat.ogg")]

var krampus_turn_off_dist = 1
var DOLL_PLACE = preload("res://Objects/DollPlace.tscn")
var PLACEMENT_AREA = preload("res://Objects/PlacementArea.tscn")

func add_noisy(new_noisy):
	noiseies.push_front(new_noisy)
	new_noisy.play()
	
func remove_noisy(new_noisy):
	noiseies.erase(new_noisy)
	new_noisy.stop()

func _ready():
	$Krampus.disable()

func _process(delta):
	if $Krampus.state == 0:
		$ChaseTimer.start()
		$"Sound Effects/Ambient".stop()
		if not $"Sound Effects/Chase".playing:
			$"Sound Effects/Chase".stream = chaseSounds[randi()%len(chaseSounds)]
			$"Sound Effects/Chase".play()
	else:
		if not $"Sound Effects/Ambient".playing:
			if $"Sound Effects/AmbientTimer".time_left <= 0:
				$"Sound Effects/AmbientTimer".start(rand_range(10, 120))
		if $"Sound Effects/Chase".playing:
			if not $SoundTween.is_active():
				$SoundTween.interpolate_property($"Sound Effects/Chase", "volume_db", 0, -60, 10)
				$SoundTween.start()
	if not $ChaseTimer.paused and $Krampus.global_transform.origin.distance_to($Player.global_transform.origin) < 0.75 and $Krampus.visible:
		switch_scene("res://Scenes/Jumpscare.tscn", false)
func play_ambient():
	$"Sound Effects/Ambient".stream = ambientSounds[randi()%len(ambientSounds)]
	$"Sound Effects/Ambient".play()
func _physics_process(delta):
	for i in noiseies:
		if i.global_transform.origin.distance_to($Krampus.global_transform.origin) < krampus_turn_off_dist:
			noiseies.erase(i)
			i.stop()

func _on_SoundTween_tween_all_completed():
	$"Sound Effects/Chase".stop()
	$"Sound Effects/Chase".volume_db = 0

func _on_noisetimer_timeout():
	for i in noiseies:
		$Krampus.noise(i.global_transform.origin, 100000, 2)

func on_item_pickup():
	if not $Krampus.visible:
		$Krampus.enable()
func on_doll_built():
	var place = PLACEMENT_AREA.instance()
	place.translate(Vector3(0, 0, -3))
	add_child(place)
func on_doll_placed():
	var place = DOLL_PLACE.instance()
	place.translate(Vector3(0, 0, -3))
	$Krampus.doll_placed = true
	$Player.doll_placed = true
	add_child(place)
func on_win():
	switch_scene("res://Scenes/WinScene.tscn", true)
