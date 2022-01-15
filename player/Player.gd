extends KinematicBody

export var mouse_look_sensitivity = 1.0
export var joystick_look_sensitivity = 1.0

export var gun = true
enum ShootAnimationEnum {pistol, rifle}
export(ShootAnimationEnum) var shoot_animation = ShootAnimationEnum.rifle
export var auto_fire = false
export var fire_rate = 0.1

export var can_crouch = true

export var flashlight_ability = true

export var run_speed = 8.0
export var walk_speed = 2.5
export var acceleration = 8

export var jump_force = 6.5
export var double_jump_force = 0.0
export var double_jump_timer = 0.2

var jump_number = 0

export var gravity_percentage = 200

export var death_falling_velocity = 30
export var height_death = -20

export var distance_footstep_sound = 2.0

export (PackedScene) var impact
export (PackedScene) var muzzle_flash
export (PackedScene) var flashlight
export (Resource) var gun_shoot_sound
export (Resource) var bang_sound

export (Resource) var flashlight_toggle_sound

export (Resource) var accept_sound
export (Resource) var deny_sound
export (Resource) var footstep_sound1
export (Resource) var footstep_sound2
export (Resource) var footstep_sound3
export (Resource) var footstep_sound4
export (Resource) var footstep_sound5
export (Resource) var footstep_sound6
export (Resource) var footstep_sound7
export (Resource) var footstep_sound8
export (Resource) var footstep_sound9
export (Resource) var footstep_sound10

onready var footstep_sounds = [footstep_sound1, footstep_sound2, footstep_sound3, footstep_sound4, footstep_sound5, footstep_sound6, footstep_sound7, footstep_sound8, footstep_sound9, footstep_sound10]

##########################

var direction = Vector3()
var velocity = Vector3() # Direction with acceleration applied
var movement = Vector3() # Velocity with gravity applied

var current_speed = run_speed

var gravity = 9.81 * (gravity_percentage / 100.0)

var can_jump = true
var can_still_jump = true
var can_double_jump = false
var can_use_interact_key = true
var can_use_flashlight_key = true

var can_shoot = true

var joystick_deadzone = 0.2

var sway_amount = 1
var mouse_relative_x = 0
var mouse_relative_y = 0

var distance = 0

onready var checkpoint_position = global_transform

# Data
var touch_ground = false

var falling_impact_velocity = 0
var movement_speed = 0

onready var feet_raycast = $FeetRayCast
onready var shoot_raycast = $Head/ShootRayCast
onready var interactive_raycast = $Head/InteractiveRayCast

onready var flashlight_instance = flashlight.instance()

func _ready():
	set_physics_process(false)
	set_process_input(false)
	
	if flashlight:
		$Head/RightHand.add_child(flashlight_instance)
		flashlight_instance.hide()
	
	$FireRateTimer.wait_time = fire_rate
	$DoubleJumpTimer.wait_time = double_jump_timer
	spawn_player()
	shoot_raycast.translation.y = $Head/ClippedCamera.translation.y
	
	if not gun:
		$Head/RightHand/GunAnimation.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	rotation_degrees.x = 0
	rotation_degrees.z = 0

func _input(event):
	# Look around with the mouse
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_look_sensitivity / 18
		$Head.rotation_degrees.x -= event.relative.y * mouse_look_sensitivity / 18
		$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x, -90, 90)
		
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

func interact():
	if interactive_raycast.get_collider() is RigidBody and not interactive_raycast.get_collider() is VehicleBody:
		play_sound(accept_sound, -5)
		grab()
	else:
		play_sound(deny_sound, -5)

func grab():
	
	pass

func toggle_flashlight():
	if flashlight_ability:
		flashlight_instance.visible = !flashlight_instance.visible
		
		play_sound(flashlight_toggle_sound, -10)

func _physics_process(delta):
	if Input.is_key_pressed(KEY_E) or Input.is_joy_button_pressed(0, JOY_XBOX_Y):
		if can_use_interact_key:
			interact()
		can_use_interact_key = false
	else:
		can_use_interact_key = true
		
	if Input.is_key_pressed(KEY_F) or Input.is_joy_button_pressed(0, JOY_L):
		if can_use_flashlight_key:
			toggle_flashlight()
		can_use_flashlight_key = false
	else:
		can_use_flashlight_key = true
	
	$Head/RightHand.rotation_degrees.y = lerp($Head/RightHand.rotation_degrees.y, mouse_relative_x * sway_amount / 20, 20 * delta)
	$Head/RightHand.rotation_degrees.x = lerp($Head/RightHand.rotation_degrees.x, -mouse_relative_y * sway_amount / 20, 20 * delta)
	
	if not touch_ground and feet_raycast.is_colliding():
		falling_impact_velocity = -movement.y
		if falling_impact_velocity > 1:
			print("Falling velocity: " , falling_impact_velocity)
		land_animation()
	
	# Inputs
	
	# Look with the right analog of the joystick
	if Input.get_joy_axis(0, 2) < -joystick_deadzone or Input.get_joy_axis(0, 2) > joystick_deadzone:
		rotation_degrees.y -= Input.get_joy_axis(0, 2) * joystick_look_sensitivity * 3
	if Input.get_joy_axis(0, 3) < -joystick_deadzone or Input.get_joy_axis(0, 3) > joystick_deadzone:
		$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x - Input.get_joy_axis(0, 3) * joystick_look_sensitivity * 3, -90, 90)
	
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
	
	direction = direction.rotated(Vector3.UP, rotation.y)
	
	if Input.is_key_pressed(KEY_SHIFT) or Input.get_joy_axis(0, JOY_L2) >= 0.6:
		current_speed = walk_speed
	else:
		current_speed = run_speed
	
	if can_crouch:
		if Input.is_key_pressed(KEY_CONTROL) or Input.is_joy_button_pressed(0, JOY_XBOX_B):
			current_speed = walk_speed
			feet_raycast.cast_to.y = lerp(feet_raycast.cast_to.y, -1.25, 15 * delta)
			$MeshInstance.mesh.mid_height = lerp($MeshInstance.mesh.mid_height, 0.2+0.25, 15 * delta)
			$MeshInstance.translation.y = lerp($MeshInstance.translation.y, -0.625, 15 * delta)
		else:
			feet_raycast.cast_to.y = lerp(feet_raycast.cast_to.y, -2, 15 * delta)
			$MeshInstance.mesh.mid_height = lerp($MeshInstance.mesh.mid_height, 1.2, 15 * delta)
			$MeshInstance.translation.y = lerp($MeshInstance.translation.y, -1, 15 * delta)
	
	velocity = velocity.linear_interpolate(direction * current_speed, acceleration * delta)
	
	# Pushes the player up to allow to climb stairs for example, the raycast tries to be at the same min distance from the ground
	if feet_raycast.is_colliding():
		movement.y = 0
		global_transform.origin.y = lerp(feet_raycast.global_transform.origin.y, feet_raycast.get_collision_point().y - feet_raycast.cast_to.y, 15 * delta)
		touch_ground = true
	else:
		if not is_on_floor():
			movement.y -= gravity * delta
			touch_ground = false
	
	if touch_ground or is_on_floor():
		can_still_jump = true
		$CanStillJumpTimer.stop()
		$DoubleJumpTimer.stop()
		jump_number = 0
	else:
		if $CanStillJumpTimer.is_stopped():
			$CanStillJumpTimer.start()
	
	if Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_XBOX_A):
		if can_jump:
			
			if jump_number == 0 and can_still_jump:
				jump(jump_force)
				
				$DoubleJumpTimer.start()
				
				var pick_footstep_sound = randi() % footstep_sounds.size() # Pick a random sound
				play_sound(footstep_sounds[pick_footstep_sound], -15)
				
			if jump_number == 1 and can_double_jump:
				jump(double_jump_force)
				can_double_jump = false
			
			jump_number = 1
		can_jump = false
	else:
		can_jump = true
	
	if is_on_ceiling() and movement.y > 0:
		movement.y = 0
	
	movement.x = velocity.x
	movement.z = velocity.z
	
	movement_speed = move_and_slide(movement, Vector3.UP, true, 4, 0.785398, false)
	movement_speed = movement_speed.length()
	
	# Shooting ability
	if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.get_joy_axis(0, JOY_R2) >= 0.6:
		
		if $FireRateTimer.is_stopped() and gun:
			if auto_fire:
				shoot()
			else:
				if can_shoot:
					shoot()
			

		can_shoot = false
	else:
		can_shoot = true
	
	# Footstep sound
	if not touch_ground:
		distance = 0
	else:
		distance += movement_speed * delta
	
	if distance > distance_footstep_sound:
		var pick_footstep_sound = randi() % footstep_sounds.size() # Pick a random sound
		var dB_footstep_sound = -40 + (movement_speed * 2)
		play_sound(footstep_sounds[pick_footstep_sound], dB_footstep_sound)
		distance = 0
	
	# Death
	
	if falling_impact_velocity >= death_falling_velocity:
		spawn_player()
	
	if translation.y <= height_death:
		spawn_player()

func spawn_player():
	movement.y = 0
	set_physics_process(false)
	set_process_input(false)
	$CanUseTimer.start()
	falling_impact_velocity = 0
	global_transform = checkpoint_position
	$Head.rotation_degrees = Vector3()
	
	$DeathTween.interpolate_property($DeathTransition, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	
	var current_camera_fov = $Head/ClippedCamera.fov
	$DeathTween.interpolate_property($Head/ClippedCamera, "fov", current_camera_fov + 20, current_camera_fov, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$DeathTween.start()

func jump(jump_force):
	movement.y = jump_force

func land_animation():
	if falling_impact_velocity < 6:
		return
	
	var pick_footstep_sound = randi() % footstep_sounds.size() # Pick a random sound
	play_sound(footstep_sounds[pick_footstep_sound], -15)
	
	var value = clamp(falling_impact_velocity / 32.5, 0.2, 0.8)
	
	$LandTween.interpolate_property($Head, "translation:y", -0.2, -0.2 - value, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$LandTween.interpolate_property($Head, "translation:y", -0.2 - value, -0.2, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT, 0.2)
	$LandTween.start()

func _on_CanStillJumpTimer_timeout():
	can_still_jump = false

func _on_DoubleJumpTimer_timeout():
	can_double_jump = true

func shoot():
	$FireRateTimer.start()
	if Input.get_joy_axis(0, JOY_R2) >= 0.6:
		Input.start_joy_vibration(0, 0, 0.2, 0.1)
	
	play_sound(gun_shoot_sound, -10)
	play_sound(bang_sound, -25)
	spawn_impact()
	shoot_animation()
	spawn_muzzle_flash()
	
	if shoot_raycast.get_collider() is RigidBody:
		shoot_raycast.get_collider().apply_central_impulse(-shoot_raycast.get_collision_normal() * 20)

func spawn_impact():
	if not shoot_raycast.is_colliding():
		return
	
	if not impact:
		return
	
	var impact_instance = impact.instance()
	get_tree().get_root().add_child(impact_instance)
	
	impact_instance.global_transform.origin = shoot_raycast.get_collision_point()
	impact_instance.look_at(shoot_raycast.get_collision_point() - shoot_raycast.get_collision_normal(), Vector3.UP)

func spawn_muzzle_flash():
	if not muzzle_flash:
		return
	
	var muzzle_flash_instance = muzzle_flash.instance()
	$Head/RightHand/GunAnimation/MuzzleFlashPosition.add_child(muzzle_flash_instance)

func shoot_animation():
	randomize()
	
	var value = 0
	
	if shoot_animation == ShootAnimationEnum.pistol:
		value = rand_range(9, 11) 
		$ShootTween.interpolate_property($Head/RightHand/GunAnimation, "rotation_degrees:x", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
		$ShootTween.interpolate_property($Head/RightHand/GunAnimation, "rotation_degrees:x", value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_OUT, 0.05)
		value = rand_range(0.045, 0.055)
		$ShootTween.interpolate_property($Head/RightHand/GunAnimation, "translation:z", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
		$ShootTween.interpolate_property($Head/RightHand/GunAnimation, "translation:z", value, 0, 0.125, Tween.TRANS_SINE, Tween.EASE_OUT, 0.05)
	
	if shoot_animation == ShootAnimationEnum.rifle:
		value = rand_range(0.035, 0.045)
		$ShootTween.interpolate_property($Head/RightHand/GunAnimation, "translation:z", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
		$ShootTween.interpolate_property($Head/RightHand/GunAnimation, "translation:z", value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
		
		value = rand_range(-0.005, 0.005)
		$ShootTween.interpolate_property($Head/RightHand/GunAnimation, "translation:x", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
		$ShootTween.interpolate_property($Head/RightHand/GunAnimation, "translation:x",value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
		
		value = rand_range(0.005, 0.015)
		$ShootTween.interpolate_property($Head/RightHand/GunAnimation, "translation:y", 0, value, 0.075, Tween.TRANS_SINE, Tween.EASE_OUT)
		$ShootTween.interpolate_property($Head/RightHand/GunAnimation, "translation:y", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.075)
		
		value = rand_range(-1.5, -0.5)
		$ShootTween.interpolate_property($Head/RightHand/GunAnimation, "rotation_degrees:x", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
		$ShootTween.interpolate_property($Head/RightHand/GunAnimation, "rotation_degrees:x", value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	
	# Camera shake
	$ShootTween.interpolate_property($Head/ClippedCamera, "rotation_degrees:x", 0, 0.5, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property($Head/ClippedCamera, "rotation_degrees:x", 0.5, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	
	$ShootTween.start()

func update_checkpoint():
	checkpoint_position = global_transform

func play_sound(sound, dB):
	var audio_node = AudioStreamPlayer.new()
	audio_node.stream = sound
	audio_node.volume_db = dB
	audio_node.pitch_scale = rand_range(0.95, 1.05) # Pitch modulation
	get_tree().get_root().add_child(audio_node)
	audio_node.play()
	yield(get_tree().create_timer(10.0), "timeout")
	audio_node.queue_free()

func _on_CanUseTimer_timeout():
	set_physics_process(true)
	set_process_input(true)
