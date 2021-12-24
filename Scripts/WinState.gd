extends Spatial


var gravity_vector : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
var gravity_magnitude : int = ProjectSettings.get_setting("physics/3d/default_gravity")

var velocity = Vector3()

var falling = false

var playing = true

var time = 0

onready var chandelier = $"Interactive/InteractiveObjects/Chandelier"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	$Krampus/krampus/AnimationPlayer.play()
	if playing:
		time += delta
		if time >= 1:
			falling = true
		if falling:
			velocity += gravity_vector * gravity_magnitude * delta * 0.5
			chandelier.transform.origin += velocity * delta * 0.5
		if chandelier.transform.origin.y <= 2:
			playing = false
			chandelier.queue_free()
			$AudioStreamPlayer.play()
			$Camera2.current = true
