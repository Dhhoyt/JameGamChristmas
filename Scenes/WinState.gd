extends Spatial


var gravity_vector : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
var gravity_magnitude : int = ProjectSettings.get_setting("physics/3d/default_gravity")

var velocity = Vector3()

var falling = true

onready var chandelier = $"Interactive/InteractiveObjects/Chandelier"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if falling:
		velocity += gravity_vector * gravity_magnitude * delta
		chandelier.transform.origin += velocity
