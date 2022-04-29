extends CharacterBody3D


var run_speed = 8.0
var walk_speed = run_speed / 2

var current_speed = run_speed
var JUMP_VELOCITY = 6.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2

var landed = false
var landing_velocity = 0.0

var distance_per_frame = Vector3()
var distance_total = 0.0
var previous_position = position

var sway_amount = 1
var mouse_relative_x = 0
var mouse_relative_y = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rotation.x = 0
	rotation.z = 0

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / 1000
		$Head/LandingAnimation/Camera3D.rotation.x -= event.relative.y / 1000
		$Head/LandingAnimation/Camera3D.rotation.x = clamp( $Head/LandingAnimation/Camera3D.rotation.x, deg2rad(-90), deg2rad(90) )

		mouse_relative_x = event.relative.x
		mouse_relative_y = event.relative.y

func _physics_process(delta):
	if Input.get_joy_axis(0, 2) < -0.2 or Input.get_joy_axis(0, 2) > 0.2:
		rotation.y -= deg2rad( Input.get_joy_axis(0, 2) * 4.3 )
	if Input.get_joy_axis(0, 3) < -0.2 or Input.get_joy_axis(0, 3) > 0.2:
		$Head/LandingAnimation/Camera3D.rotation.x -= deg2rad( Input.get_joy_axis(0, 3) * 4.3 )
	
	# Hand look at the raycast collision point to be able to put an object like a gun in the arm that shoots the center of the screen
	if $Head/LandingAnimation/Camera3D/RayCast3D.is_colliding():
		$Head/LandingAnimation/Camera3D/RightHand/LookAt.look_at( $Head/LandingAnimation/Camera3D/RayCast3D.get_collision_point(), Vector3.UP )
	else:
		$Head/LandingAnimation/Camera3D/RightHand/LookAt.rotation = Vector3()
	
	$Head/LandingAnimation/Camera3D/RightHand/RightHandLookAtLerp.rotation.x = lerp( $Head/LandingAnimation/Camera3D/RightHand/RightHandLookAtLerp.rotation.x, $Head/LandingAnimation/Camera3D/RightHand/LookAt.rotation.x, 10 * delta )
	$Head/LandingAnimation/Camera3D/RightHand/RightHandLookAtLerp.rotation.y = lerp( $Head/LandingAnimation/Camera3D/RightHand/RightHandLookAtLerp.rotation.y, $Head/LandingAnimation/Camera3D/RightHand/LookAt.rotation.y, 10 * delta )
	$Head/LandingAnimation/Camera3D/RightHand/RightHandLookAtLerp.rotation.z = lerp( $Head/LandingAnimation/Camera3D/RightHand/RightHandLookAtLerp.rotation.z, $Head/LandingAnimation/Camera3D/RightHand/LookAt.rotation.z, 10 * delta )

	# Hand sway
	$Head/LandingAnimation/Camera3D/RightHand/RightHandLookAtLerp/RightHandSway.rotation.y = lerp( $Head/LandingAnimation/Camera3D/RightHand/RightHandLookAtLerp/RightHandSway.rotation.y, mouse_relative_x / 3000.0, 20 * delta )
	$Head/LandingAnimation/Camera3D/RightHand/RightHandLookAtLerp/RightHandSway.rotation.x = lerp( $Head/LandingAnimation/Camera3D/RightHand/RightHandLookAtLerp/RightHandSway.rotation.x, -mouse_relative_y / 3000.0, 20 * delta )
	$Head/LandingAnimation/Camera3D/RightHand/RightHandLookAtLerp/RightHandSway.rotation.z = lerp( $Head/LandingAnimation/Camera3D/RightHand/RightHandLookAtLerp/RightHandSway.rotation.y, -mouse_relative_x / 1500.0, 20 * delta )

	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		landing_velocity = velocity.y
		landed = false
	else:
		if not landed:
			var head_position = landing_velocity / 50
			if head_position < 0:
				print("landing velocity: ", landing_velocity)
				var tween = create_tween()
				# ici
				tween.tween_property($Head/LandingAnimation, "position:y", clamp(0.0 + head_position, -0.2, 0.0), head_position / -2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				tween.tween_property($Head/LandingAnimation, "position:y", 0.0, head_position / -2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				if landing_velocity < -3:
					$LandSound.play()
				else:
					$FootstepSound.play()
			landed = true

	# Jumping
	if ( Input.is_action_just_pressed("ui_accept") or Input.is_joy_button_pressed(0, JOY_BUTTON_A) ) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$FootstepSound.pitch_scale = randf_range(0.9, 1.1)
		$JumpSound.play()

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

	current_speed = run_speed

	# Crouching
	if Input.is_key_pressed(KEY_CTRL) or Input.is_joy_button_pressed(0, JOY_BUTTON_B):
		$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 1.4, 10 * delta)
		$Head.position.y = lerp($Head.position.y, 0.3, 10 * delta)
		current_speed = walk_speed
	else:
		if not $UncrouchRayCast3D.is_colliding():
			$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 2, 10 * delta)
			$Head.position.y = lerp($Head.position.y, 0.75, 10 * delta)

	if Input.is_key_pressed(KEY_SHIFT) or Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT) >= 0.6:
		current_speed = walk_speed
		

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

	if is_on_floor():
		distance_per_frame = previous_position - position
		distance_total += distance_per_frame.length()
	else:
		distance_total = 0

	if distance_total >= 2:
		distance_total = 0
		$FootstepSound.pitch_scale = randf_range(0.9, 1.1)
		$FootstepSound.play()
	
	previous_position = position
