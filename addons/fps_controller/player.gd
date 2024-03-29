extends CharacterBody3D

@export_range(6, 10, 0.5) var run_speed = 8.0
@export_range(6.5, 8, 0.5) var jump_velocity = 6.5
@export_range(0, 10, 1) var air_jumps = 0
@export_range(1, 3, 1) var gravity_multiplier = 2.0

var current_speed = run_speed
var remaining_air_jumps = air_jumps

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier

var on_ground = false

var landing_velocity = 0.0

var distance_per_frame = global_transform.origin
var distance_total = 0.0
var previous_position = global_transform.origin

var weapon_sway_amount = 10
var mouse_relative_x = 0
var mouse_relative_y = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rotation.x = 0
	rotation.z = 0

	$Head/Camera3D/DirectionIndicator.hide()

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / 1000
		$Head/Camera3D.rotation.x -= event.relative.y / 1000
		$Head/Camera3D.rotation.x = clamp( $Head/Camera3D.rotation.x, deg2rad(-90), deg2rad(90) )
		
#	Getting the mouse movement for the weapon sway in the physics process
	if event is InputEventMouseMotion:
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

func _physics_process(delta):
	# Sway
	$Head/Camera3D/Abilities.rotation.y = lerp($Head/Camera3D/Abilities.rotation.y, deg2rad(-mouse_relative_x / 40), weapon_sway_amount * delta)
	$Head/Camera3D/Abilities.rotation.x = lerp($Head/Camera3D/Abilities.rotation.x, deg2rad(-mouse_relative_y / 20), weapon_sway_amount * delta)
	
	if Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) < -0.2 or Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) > 0.2:
		rotation.y -= deg2rad( Input.get_joy_axis(0, 2) * 4.3 )
	if Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) < -0.2 or Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) > 0.2:
		$Head/Camera3D.rotation.x -= deg2rad( Input.get_joy_axis(0, 3) * 4.3 )

	if not is_on_floor():
		velocity.y -= gravity * delta
		if remaining_air_jumps > 0:
			if not $UncrouchRayCast3D.is_colliding():
				if ( Input.is_action_just_pressed("ui_accept") or Input.is_joy_button_pressed(0, JOY_BUTTON_A) ):
					if remaining_air_jumps > 0:
						remaining_air_jumps -= 1
						velocity.y = jump_velocity
						print("air jumps remaining: ", remaining_air_jumps)
	else:
		remaining_air_jumps = air_jumps
		if not $UncrouchRayCast3D.is_colliding():
			if ( Input.is_action_just_pressed("ui_accept") or Input.is_joy_button_pressed(0, JOY_BUTTON_A) ):
				velocity.y = jump_velocity
				$JumpSound.play()
	if $UncrouchRayCast3D.is_colliding():
		remaining_air_jumps = 0
		
	# Get the input direction and handle the movement/deceleration
	var input_dir = Vector2()
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_UP):
		input_dir.y = -1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.y = 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x = -1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x = 1
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if input_dir == Vector2():
		if Input.get_joy_axis(0, JOY_AXIS_LEFT_X) < -0.2 or Input.get_joy_axis(0, JOY_AXIS_LEFT_X) > 0.2:
			input_dir.x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		if Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) < -0.2 or Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) > 0.2:
			input_dir.y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if is_on_floor():
		current_speed = (run_speed / 2) * $CollisionShape3D.shape.height
	else:
		current_speed = run_speed

	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

	if is_on_floor():
		footstep_sound(true)
		if on_ground == false:
			print("landing velocity: " , landing_velocity)
			$LandSound.play()
			on_ground = true
	else:
		footstep_sound(false)
		on_ground = false
		if not  velocity.y >= 0:
			landing_velocity = -velocity.y

	if Input.is_key_pressed(KEY_CTRL) or Input.is_joy_button_pressed(0, JOY_BUTTON_B):
		crouch(delta)
		return
	
	if is_on_floor():
		uncrouch(delta)
	else:
		crouch(delta)

func footstep_sound(add):
	if add:
		distance_per_frame = global_transform.origin - previous_position
		previous_position = global_transform.origin
		distance_total += distance_per_frame.length()
		if distance_total >= 2:
			distance_total = 0
			$FootstepSound.pitch_scale = randf_range(0.9, 1.1)
			$FootstepSound.play()
	else:
		distance_total = 0

func crouch(delta):
	$CollisionShape3D.shape.height = lerp( $CollisionShape3D.shape.height, 1.5, 10 * delta )
	$CollisionShape3D.position.y = lerp( $CollisionShape3D.position.y, 0.25, 10 * delta )
	$MeshInstance3D.mesh.height = $CollisionShape3D.shape.height
	$MeshInstance3D.position.y = $CollisionShape3D.position.y
	
func uncrouch(delta):
	if not $UncrouchRayCast3D.is_colliding():
		$CollisionShape3D.shape.height = lerp( $CollisionShape3D.shape.height, 2.0, 10 * delta )
		$CollisionShape3D.position.y = lerp( $CollisionShape3D.position.y, 0.0, 10 * delta )
		$MeshInstance3D.mesh.height = $CollisionShape3D.shape.height
		$MeshInstance3D.position.y = $CollisionShape3D.position.y
