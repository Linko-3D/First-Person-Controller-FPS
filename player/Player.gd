extends KinematicBody

var mouse_sensitivity = 1
var joystick_deadzone = 0.2

var run_speed = 6 # Running speed in m/s
var walk_speed = run_speed / 2
var crouch_speed = run_speed / 3
var jump_height = 4

var current_speed = run_speed

var ground_acceleration = 10
var air_acceleration = 5
var acceleration = air_acceleration

var direction = Vector3()
var velocity = Vector3() # Direction with acceleration added
var movement = Vector3() # Velocity with gravity added

var gravity = 9.8
var gravity_vec = Vector3()

var snapped = false
var can_jump = true

var crouched = false
var toggle_mode_crouch = false
var can_press_crouch = true

var in_water = false

# Data:
var player_speed = 0
var falling_velocity = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Look with the mouse
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity / 18
		$Head.rotation_degrees.x -= event.relative.y * mouse_sensitivity / 18
		$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x, -90, 90)
		
	direction = Vector3()

func _physics_process(delta):
	# Look with the right analog of the joystick
	if Input.get_joy_axis(0, 2) < -joystick_deadzone or Input.get_joy_axis(0, 2) > joystick_deadzone:
		rotation_degrees.y -= Input.get_joy_axis(0, 2) * 2
	if Input.get_joy_axis(0, 3) < -joystick_deadzone or Input.get_joy_axis(0, 3) > joystick_deadzone:
		$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x - Input.get_joy_axis(0, 3) * 2, -90, 90)
	
	# Direction inputs
	direction = Vector3()
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_UP):
		direction.z += -1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.z += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_LEFT):
		direction.x += -1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1
		
	direction = direction.normalized()
	
	#If we aren't using the keyboard, take the input from the left analog of the joystick
	if direction == Vector3():
		direction.z = Input.get_joy_axis(0, 1)
		direction.x = Input.get_joy_axis(0, 0)
		
		# Apply a deadzone to the joystick
		if direction.z < joystick_deadzone and direction.z > -joystick_deadzone:
			direction.z = 0
		if direction.x < joystick_deadzone and direction.x > -joystick_deadzone:
			direction.x = 0
	
	# Rotates the direction from the Y axis to move forward
	direction = direction.rotated(Vector3.UP, rotation.y)
	
	# Snaps the character on the ground and changes the gravity vector to climb
	# slopes at the same speed until 45 degrees
	if is_on_floor():
		if snapped == false:
			falling_velocity = gravity_vec.y
			land_animation()
		acceleration = ground_acceleration
		movement.y = 0
		gravity_vec = -get_floor_normal() * 10
		snapped = true
	else:
		acceleration = air_acceleration
		if snapped:
			gravity_vec = Vector3()
			snapped = false
		else:
			if not in_water:
				gravity_vec += Vector3.DOWN * gravity * delta
			else:
				gravity_vec = Vector3.ZERO
	
	if is_on_floor():
		if Input.is_key_pressed(KEY_SHIFT) or Input.get_joy_axis(0, 6) >= 0.6:
			current_speed = walk_speed
		else:
			current_speed = run_speed
		if crouched:
			current_speed = crouch_speed
	
	if Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_XBOX_A):
		if is_on_floor() and can_jump:
			snapped = false
			can_jump = false
			jump()
			if toggle_mode_crouch:
				crouch_animation(false)
	else:
		can_jump = true
	
	if is_on_ceiling():
		gravity_vec.y = 0
	
	if Input.is_key_pressed(KEY_CONTROL):
		toggle_mode_crouch = false
		crouch_animation(true)
	else:
		if not toggle_mode_crouch:
			crouch_animation(false)
	
	if Input.is_key_pressed(KEY_C) or Input.is_joy_button_pressed(0, JOY_XBOX_B):
		toggle_mode_crouch = true
		if can_press_crouch:
			can_press_crouch = false
			crouch_animation(!crouched)
	else:
		can_press_crouch = true
	
	velocity = velocity.linear_interpolate(direction * current_speed, acceleration * delta)
	
	movement.x = velocity.x + gravity_vec.x
	movement.z = velocity.z + gravity_vec.z
	movement.y = gravity_vec.y
	
	movement = move_and_slide(movement, Vector3.UP)
	
	player_speed = movement.length()

func jump():
	gravity_vec = Vector3.UP * jump_height

func land_animation():
	var movement_y = clamp(falling_velocity, -20, 0) / 40
	
	$LandTween.interpolate_property($Head/Camera, "translation:y", 0, movement_y, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$LandTween.interpolate_property($Head/Camera, "translation:y", movement_y, 0, 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	$LandTween.start()

func crouch_animation(button_pressed):
	if button_pressed:
		if not crouched:
			$CrouchTween.interpolate_property($MeshInstance, "mesh:mid_height", $MeshInstance.mesh.mid_height, 0.25, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CrouchTween.interpolate_property($CollisionShape, "shape:height", $CollisionShape.shape.height, 0.25, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CrouchTween.interpolate_property($Head, "translation:y", $Head.translation.y, 1.35, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CrouchTween.start()
			crouched = true
	else:
		if crouched:
			$CrouchTween.interpolate_property($MeshInstance, "mesh:mid_height", $MeshInstance.mesh.mid_height, 0.75, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CrouchTween.interpolate_property($CollisionShape, "shape:height", $CollisionShape.shape.height, 0.75, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CrouchTween.interpolate_property($Head, "translation:y", $Head.translation.y, 1.6, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CrouchTween.start()
			crouched = false

func _on_Area_area_entered(area):
	if area.is_in_group("water"):
		in_water = true

func _on_Area_area_exited(area):
	if area.is_in_group("water"):
		in_water = false
