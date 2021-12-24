extends Spatial


var sounds = [preload("res://Assets/Audio/fxScare01.ogg"), preload("res://Assets/Audio/fxScare02.ogg"), preload("res://Assets/Audio/fxScare03.ogg"),
			preload("res://Assets/Audio/fxScare04.ogg"), preload("res://Assets/Audio/fxScare05.ogg"), preload("res://Assets/Audio/fxScare06.ogg")]
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$krampus/AnimationPlayer.play("Chase")
	$AudioStreamPlayer.stream = sounds[randi()%len(sounds)]
	$AudioStreamPlayer.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$krampus/AnimationPlayer.play("Chase")
	$krampus.global_transform.origin -= $krampus.global_transform.origin * delta * 3
	if $krampus.global_transform.origin.x < 0.1:
		get_tree().change_scene("res://Scenes/TitleScreen.tscn")
