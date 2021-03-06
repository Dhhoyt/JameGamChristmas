
extends KinematicBody

export(float) var sensitivity : float = 0.2
export(float) var friction : float = 50

export(float) var air_coeff : float = 0.25
export(float) var jump_speed : float = 0

export(float) var max_walk_speed : float = 2
export(float) var walk_accel : float = 50

export(float) var max_run_speed : float = 4
export(float) var run_accel : float = 50
export(float) var max_stamina : float = 5
export(float) var stamina_recharge : float = 1

export(float) var max_crouch_speed : float = .5
export(float) var crouch_accel : float = 50

export(float) var crouch_time : float = 0.3 #how long the animation should take
export(float) var crouch_coeff : float = 0.5 #how high the hitbox should be as a coefficient of the standing height

export(float) var audio_speed : float = 1

var last_height : float

signal doll_placed
signal chandelier_cut
signal win

onready var standing_height : float = $CollisionShape.get_shape().get_height()
onready var cam_stand_height : float = $Camera.translation.y
onready var radius : float = $CollisionShape.get_shape().get_radius()

var looking : Vector3 = Vector3() setget set_looking
func set_looking(new_looking):
	looking = new_looking
	$Camera.rotation.y = looking.y
	$Camera.rotation.x = looking.x
	
var velocity : Vector3 = Vector3()

var crouching : bool = false
var hiding : bool = false
var getting_in : bool = false
var in_inventory : bool = false
var inventory_type : int = 0
var doll_placed : bool = false
var open_inventory_delay : bool = false
var current_stamina : float = 5

var gravity_vector : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
var gravity_magnitude : int = ProjectSettings.get_setting("physics/3d/default_gravity")

var enemies : Array = []

var current_hide = null

func _ready():
	current_stamina = max_stamina
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#$CanvasLayer/ItemBar.add_item(load("res://Objects/Items/FinishedDoll.tscn").instance())

func _process(delta):
	audio()
	if $CanvasLayer/ItemBar.get_selected_item_name() == "Flashlight":
		$Camera/Flashlight.show()
	else:
		$Camera/Flashlight.hide()
	if velocity.length() <= max_walk_speed or hiding or getting_in:
		if current_stamina < max_stamina:
			current_stamina += stamina_recharge * delta
	$CanvasLayer/SprintBar.rect_scale = Vector2(current_stamina/max_stamina, 1)

func _physics_process(delta):
	if not in_inventory:
		onscreen_text()
		if not $Crouch.is_active():
			if Input.is_action_pressed("player_crouch") and not crouching:
				crouching = true
				$Crouch.interpolate_method(self, "set_height", standing_height, standing_height * crouch_coeff, crouch_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
				$Crouch.start()
			elif not Input.is_action_pressed("player_crouch") and crouching and not uncrouch_blocked():
				crouching = false
				$Crouch.interpolate_method(self, "set_height", standing_height * crouch_coeff, standing_height, crouch_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
				$Crouch.start()
		
		if hiding and not $Hide.is_active():
			global_transform.origin = current_hide.get_node("HidingPoint").global_transform.origin
			return
		
		var multiplier : float = 1
		if !is_on_floor():
			multiplier = air_coeff
		var move_accel : float
		var max_speed : float
		
		if crouching:
			move_accel = crouch_accel
			max_speed = max_crouch_speed
		elif Input.is_action_pressed("player_run") and current_stamina > 0:
			move_accel = run_accel
			max_speed = max_run_speed
			current_stamina -= delta
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
	if vel.length() >= audio_speed and not $StepAudioPlayer.playing and not crouching:
		$StepAudioPlayer.play()
	elif vel.length() < audio_speed:
		$StepAudioPlayer.stop()
	elif $StepAudioPlayer.playing:
		for i in enemies:
			i.noise(global_transform.origin, 0.5, 3)	

func _input(event):
	if event is InputEventMouseMotion and not in_inventory:
		var new_looking = looking
		new_looking.y -= deg2rad(event.relative.x * sensitivity)
		new_looking.x -= deg2rad(event.relative.y * sensitivity)
		new_looking.x = clamp(new_looking.x, -PI/3, PI/3)
		set_looking(new_looking)
	if event.is_action_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("exit_inventory") and in_inventory:
		in_inventory = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$CanvasLayer/InventoryArea.hide()
		$CanvasLayer/Building.hide()
		open_inventory_delay = true
	if event.is_action_pressed("player_interact"):
		if not in_inventory:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func set_height(new_height):
	if last_height > new_height:
		translation.y += new_height - last_height
	var capsule = $CollisionShape.get_shape()
	last_height = capsule.get_height()
	$Camera.translation.y = cam_stand_height * (new_height/standing_height)/2
	capsule.set_height(new_height)
	$CollisionShape.set_shape(capsule)

func onscreen_text():
	if hiding:
		$"CanvasLayer/Label".text = "Press E to get out"
		if Input.is_action_just_pressed("player_interact"):
			do_hide(current_hide)
		return
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray($Camera.global_transform.origin, $Camera/Pickup.global_transform.origin, [self])
	if not result.empty():
		if result["collider"].is_in_group("Interactable") and result["collider"].is_in_group("Moveable"):
			$"CanvasLayer/Label".text = "E to open\n Click to move"
			if Input.is_action_just_pressed("player_interact"):
				if open_inventory_delay:
					open_inventory_delay = false
				else:
					$CanvasLayer/InventoryArea.show()
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					$CanvasLayer/InventoryArea.display_inventory(result["collider"].get_parent())
					in_inventory = true
					inventory_type = 1
			if Input.is_action_just_pressed("player_affect"):
				result["collider"].move()
		elif result["collider"].is_in_group("Interactable"):
			$"CanvasLayer/Label".text = "E to open" 
			if Input.is_action_just_pressed("player_interact"):
				if open_inventory_delay:
					open_inventory_delay = false
				else:
					$CanvasLayer/InventoryArea.show()
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					$CanvasLayer/InventoryArea.display_inventory(result["collider"].get_parent())
					in_inventory = true
					inventory_type = 1
		elif result["collider"].is_in_group("Hideable") and result["collider"].is_in_group("Moveable"):
			$"CanvasLayer/Label".text = "E to hide\n Click to move"
			if Input.is_action_just_pressed("player_interact"):
				do_hide(result["collider"])
			if Input.is_action_just_pressed("player_affect"):
				result["collider"].move()
		elif result["collider"].is_in_group("Hideable"):
			$"CanvasLayer/Label".text = "E to hide"
			if Input.is_action_just_pressed("player_interact"):
				do_hide(result["collider"])
		elif result["collider"].is_in_group("Moveable"):
			$"CanvasLayer/Label".text = result["collider"].get_interaction_text()
			if Input.is_action_just_pressed("player_affect"):
				for i in enemies:
					i.noise(result["collider"].global_transform.origin, 0.5, 1)
				result["collider"].move()
		elif result["collider"].is_in_group("Noisy"):
			if not result["collider"].playing:
				$"CanvasLayer/Label".text = "E to make noise"
				if Input.is_action_just_pressed("player_interact"):
					get_parent().add_noisy(result["collider"])
			else: 
				$"CanvasLayer/Label".text = "E to stop noise"
				if Input.is_action_just_pressed("player_interact"):
					get_parent().remove_noisy(result["collider"])
		elif result["collider"].is_in_group("Builder"):
			$"CanvasLayer/Label".text = "E to build"
			if Input.is_action_just_released("player_interact"):
				if open_inventory_delay:
					open_inventory_delay = false
				else:
					$CanvasLayer/Building.show()
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					in_inventory = true
					inventory_type = 2
		elif result["collider"].is_in_group("PlacementArea"):
			if $CanvasLayer/ItemBar.get_selected_item_name() == "Finished Doll":
				$"CanvasLayer/Label".text = "Click to Place Doll"
				if Input.is_action_just_pressed("player_affect") or Input.is_action_just_pressed("player_interact"):
					emit_signal("doll_placed")
					$CanvasLayer/ItemBar.remove_selected_item()
					doll_placed = true
		elif result["collider"].is_in_group("Chandelier") and doll_placed:
			if $CanvasLayer/ItemBar.get_selected_item_name() == "Knife":
				$"CanvasLayer/Label".text = "Click to Cut Down Chandelier"
				if Input.is_action_just_pressed("player_affect") or Input.is_action_just_pressed("player_interact"):
					emit_signal("win")
				
		else:
			Input.is_action_just_pressed("player_interact")
			$"CanvasLayer/Label".text = ""
	else:
		Input.is_action_just_pressed("player_interact")
		$"CanvasLayer/Label".text = ""


func add_enemy(new_enemy):
	enemies.append(new_enemy)

func do_hide(hiding_space):
	if $Hide.is_active():
		return
	if not hiding and not getting_in:
		getting_in = true
		current_hide = hiding_space
		$Hide.interpolate_property(self, "looking", looking, hiding_space.get_node("HidingPoint").global_transform.basis.get_euler(), 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Hide.interpolate_property(self, "translation", global_transform.origin, hiding_space.get_node("HidingPoint").global_transform.origin, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Hide.start()
	else:
		hiding = false
		$Hide.interpolate_property(self, "looking", looking, hiding_space.get_node("GetoutPoint").global_transform.basis.get_euler(), 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Hide.interpolate_property(self, "translation", global_transform.origin, hiding_space.get_node("GetoutPoint").global_transform.origin, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Hide.start()

func _on_Hide_tween_all_completed():
	if getting_in:
		getting_in = false
		hiding = true
func item_pressed(index):
	if in_inventory:
		if inventory_type == 1:
			$CanvasLayer/InventoryArea.remove_item_bar(index)
		elif inventory_type == 2:
			$CanvasLayer/Building.remove_item_bar(index)
