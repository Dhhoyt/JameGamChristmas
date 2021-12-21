
extends KinematicBody

export(float) var sensitivity : float = 0.2
export(float) var friction : float = 50

export(float) var air_coeff : float = 0.25
export(float) var jump_speed : float = 7

export(float) var max_walk_speed : float = 3
export(float) var walk_accel : float = 50

export(float) var max_run_speed : float = 30
export(float) var run_accel : float = 50

export(float) var max_crouch_speed : float = 5
export(float) var crouch_accel : float = 50

export(float) var crouch_time : float = 0.3 #how long the animation should take
export(float) var crouch_coeff : float = 0.5 #how high the hitbox should be as a coefficient of the standing height

export(float) var audio_speed : float = 2

var last_height : float

onready var standing_height : float = $CollisionShape.get_shape().get_height()
onready var cam_stand_height : float = $Camera.translation.y
onready var radius : float = $CollisionShape.get_shape().get_radius()

var looking : Vector3 = Vector3()
var velocity : Vector3 = Vector3()

var crouching : bool = false

var gravity_vector : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
var gravity_magnitude : int = ProjectSettings.get_setting("physics/3d/default_gravity")

var enemies : Array = []

func _ready():
	pass
func _physics_process(delta):
	if not $Crouch.is_active():
		if Input.is_action_pressed("player_crouch") and not crouching:
			crouching = true
			$Crouch.interpolate_method(self, "set_height", standing_height, standing_height * crouch_coeff, crouch_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			$Crouch.start()
		elif not Input.is_action_pressed("player_crouch") and crouching and not uncrouch_blocked():
			crouching = false
			$Crouch.interpolate_method(self, "set_height", standing_height * crouch_coeff, standing_height, crouch_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			$Crouch.start()
	
	var multiplier : float = 1
	if !is_on_floor():
		multiplier = air_coeff
	var move_accel : float
	var max_speed : float
	
	if crouching:
		move_accel = crouch_accel
		max_speed = max_crouch_speed
	elif Input.is_action_pressed("player_run"):
		move_accel = run_accel
		max_speed = max_run_speed
	else:
		move_accel = walk_accel
		max_speed = max_walk_speed
	apply_friction(delta, multiplier)
	var walkvector : Vector2 = walk(delta, move_accel, max_speed, multiplier)
	
	if is_on_floor() and Input.is_action_pressed("player_jump"):
		velocity.y = jump_speed
	
	velocity = Vector3(walkvector.x, velocity.y, -walkvector.y)
	velocity = move_and_slide(velocity, Vector3(0, 1, 0), false, 4, 0.785398, false)
	velocity += (gravity_magnitude * delta) * gravity_vector
	
	audio()

func walk(delta, move_accel, max_speed, multiplier):
	var frame_accel = (move_accel + friction) * multiplier
	var new_walkvector : Vector2 = Vector2()
	new_walkvector.x += velocity.x
	new_walkvector.y -= velocity.z
	new_walkvector += Vector2(frame_accel * delta * (Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")), 0).rotated($Camera.rotation.y + PI/2)
	new_walkvector += Vector2(0, frame_accel * delta * (Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"))).rotated($Camera.rotation.y + PI/2)
	var walkvector : Vector2
	var old_walkvector : Vector2 = Vector2(velocity.x, -velocity.z)
	if new_walkvector.length() > max_speed:
		if old_walkvector.length() < max_speed:
			walkvector = new_walkvector.clamped(max_speed)
		elif new_walkvector.length() < old_walkvector.length(): 
			walkvector = new_walkvector
		else:
			walkvector = old_walkvector
	else:
		walkvector = new_walkvector
	return walkvector

func apply_friction(delta, multiplier):
	var frame_friction : float = friction * multiplier
	var vel_2d : Vector2 = Vector2(velocity.x, velocity.z)
	var power : float = vel_2d.length()
	if power > frame_friction * delta:
		power -= frame_friction * delta
	else:
		power = 0
	vel_2d = vel_2d.normalized() * power
	velocity.x = vel_2d.x
	velocity.z = vel_2d.y

func uncrouch_blocked():
	var space_state : PhysicsDirectSpaceState = get_world().direct_space_state
	var new_height : Vector3 = global_transform.origin
	new_height.y += standing_height
	new_height.y += radius
	new_height.y -= standing_height * crouch_coeff
	var result = space_state.intersect_ray(global_transform.origin, new_height, [self])
	return result.size() != 0

func audio():
	var vel : Vector2 = Vector2(velocity.x, velocity.z)
	if vel.length() > audio_speed and not $StepAudioPlayer.playing:
		$StepAudioPlayer.play()
	elif vel.length() < audio_speed:
		$StepAudioPlayer.stop()
	elif $StepAudioPlayer.playing:
		for i in enemies:
			i.noise(global_transform.origin)

func _input(event):
	if event is InputEventMouseMotion:
		looking.y -= deg2rad(event.relative.x * sensitivity)
		looking.x -= deg2rad(event.relative.y * sensitivity)
		looking.x = clamp(looking.x, -PI/3, PI/3)
		$Camera.rotation.y = looking.y
		$Camera.rotation.x = looking.x

func set_height(new_height):
	if last_height > new_height:
		translation.y += new_height - last_height
	var capsule = $CollisionShape.get_shape()
	last_height = capsule.get_height()
	$Camera.translation.y = cam_stand_height * (new_height/standing_height)/2
	capsule.set_height(new_height)
	$CollisionShape.set_shape(capsule)

func add_enemy(new_enemy):
	enemies.append(new_enemy)
