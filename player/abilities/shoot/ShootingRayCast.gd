# Shooting ability with left click and reloading with R

extends RayCast

export (PackedScene) var impact
export (PackedScene) var shell

export (Resource) var shoot_sound
export (Resource) var reload_sound
export (Resource) var empty_sound
export (Resource) var shell_impact_sound

var weapon_sway = 8.0
var max_ammo = 12
var shooting_echo = true

var current_ammo = max_ammo

var mouse_relative_x = 0
var mouse_relative_y = 0

var hand_position

var player
var camera_node

var can_shoot = true

func _ready():
	$Shoulder/Hand/Nozzle/ShootLight.hide()
	hand_position = $Shoulder/Hand.translation
	player = get_tree().get_root().find_node("Player", true, false)
	camera_node = get_tree().get_root().find_node("Camera", true, false)
	
	randomize()

func _input(event):
	if event is InputEventMouseMotion: # Getting the mouse movement for the weapon sway in the physics process
		mouse_relative_x = event.relative.x
		mouse_relative_y = event.relative.y
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed: # Shooting
			if can_shoot and $FireRate.time_left == 0 and not $ReloadTween.is_active():
				if current_ammo > 0:
					shoot()
					$FireRate.start()
				else:
					play_sound(empty_sound, 0, 0)
					$FireRate.start()
	
	if Input.is_key_pressed(KEY_R): # Reloading
		if current_ammo < max_ammo:
			if not $ShootTween.is_active() and not $ReloadTween.is_active():
				tween($ReloadTween, $Shoulder/Hand, "rotation_degrees:x", 0, 360, 1, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0, false)
				current_ammo = max_ammo
				play_sound(reload_sound, 0, 0)
				print(current_ammo)

func shoot():
	if shooting_echo:
		var delay = 0
		var volume = 0
		for i in 5: # Add an echo effect when shooting by delaying the sound and reducing the volume
			play_sound(shoot_sound, volume, delay)
			delay += 0.3
			volume -= 25
	else:
		play_sound(shoot_sound, 0, 0)
	
	current_ammo -= 1
	print(current_ammo)
	
	$Shoulder/Hand/Nozzle/ShootLight.show()
	
	# Recoil animation:
	tween($ShootTween, $Shoulder/Hand, "rotation_degrees:x", 0, 25, 0.1, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0, true)
	tween($ShootTween, $Shoulder/Hand, "translation:z", hand_position.z, hand_position.z + 0.1, 0.1, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0, true)
	
	$ShootTween.interpolate_property(camera_node, "rotation_degrees:x", 0, 1, 0.1, 0, 2, 0)
	$ShootTween.interpolate_property(camera_node, "rotation_degrees:x", 1, 0, 0.1 * 2, 0, 2, 0.1)
	
	spawn_shell()
	
	if is_colliding():
		spawn_impact()
		
	yield(get_tree().create_timer(0.1), "timeout")
	$Shoulder/Hand/Nozzle/ShootLight.hide()
	yield(get_tree().create_timer(0.5), "timeout")

func spawn_shell():
	var shell_instance = shell.instance()
	get_tree().get_root().add_child(shell_instance)
	shell_instance.global_transform = $Shoulder/Hand/Shell.global_transform
	shell_instance.linear_velocity = $Shoulder/Hand/Shell.global_transform.basis.x * 5
	shell_instance.get_node("ImpactSound").pitch_scale = rand_range(0.95, 1.05)
	yield(get_tree().create_timer(0.75), "timeout") # We add a delay before playing the sound to simulate the time of the shell to fall on the ground
	shell_instance.get_node("ImpactSound").play()
	yield(get_tree().create_timer(10), "timeout")
	shell_instance.queue_free()

func spawn_impact():
	var impact_instance = impact.instance()
	get_tree().get_root().add_child(impact_instance)
	impact_instance.global_transform.origin = get_collision_point()
	impact_instance.look_at(get_collision_point() - get_collision_normal(), Vector3.UP)
	impact_instance.get_node("Particles").emitting = true
	impact_instance.get_node("ImpactSound").pitch_scale = rand_range(0.95, 1.05)
	impact_instance.get_node("ImpactSound").play()
	
	if get_collider() is RigidBody:
		get_collider().apply_central_impulse(-get_collision_normal() * 100)
		impact_instance.get_node("Bullet").hide()
		
	if get_collider() is KinematicBody:
		impact_instance.get_node("Bullet").hide()
	
	if get_collider().is_in_group("Destructible"):
		get_collider().queue_free()
		impact_instance.get_node("Bullet").hide()
	
	yield(get_tree().create_timer(60), "timeout")
	impact_instance.queue_free()

func _physics_process(delta):
	# Weapon sway:
	$Shoulder.rotation_degrees.x = lerp($Shoulder.rotation_degrees.x, mouse_relative_y / 4, weapon_sway * delta)
	$Shoulder.rotation_degrees.y = lerp($Shoulder.rotation_degrees.y, mouse_relative_x / 4, weapon_sway * delta)
	
	# Weapon oriented where aiming if not reloading:
	if not $ReloadTween.is_active():
		if is_colliding():
			$Shoulder/Hand/Orientation.look_at(get_collision_point(), Vector3.UP)
			
			$Shoulder/Hand/Weapon.rotation_degrees = lerp($Shoulder/Hand/Weapon.rotation_degrees, $Shoulder/Hand/Orientation.rotation_degrees, 10 * delta)
		else:
			$Shoulder/Hand/Weapon.rotation_degrees = lerp($Shoulder/Hand/Weapon.rotation_degrees, Vector3(), 10 * delta)
	
	# Weapon bobbing when walking:
	if player.direction and player.is_on_floor():
		var speed = 0.4
		var amplitude = 0.02
		# Adjust the speed and amplitude depending if we are crouching, sprinting or walking
		if player.crouch_speed != 1:
			bobbing_animation(speed/player.crouch_multiplier, amplitude/2)
		elif player.sprint_speed != 1:
			bobbing_animation(speed/player.sprint_multiplier, amplitude*2)
		else:
			bobbing_animation(speed, amplitude)
	
	if player.is_on_floor() and not player.grounded: # animation when falling on the ground
		var max_rotation = clamp(player.gravity_vec.y*2, -45, 0)
		tween($BobbingTween, $Shoulder, "rotation_degrees:x", 0, max_rotation, 0.2, 0, 2, 0, true)

func bobbing_animation(duration, amplitude):
	if not $BobbingTween.is_active():
		tween($BobbingTween, $Shoulder/Hand, "translation:x", $Shoulder/Hand.translation.x, $Shoulder/Hand.translation.x + amplitude*2, duration, 0, 2, 0, true)
	if not $BobbingTween2.is_active():
		tween($BobbingTween2, $Shoulder/Hand, "translation:y", $Shoulder/Hand.translation.y, $Shoulder/Hand.translation.y - amplitude, duration/2, 0, 2, 0, true)

func tween(tween_node, object, property, initial_val, final_val, duration, trans_type, ease_type, delay, invert):
	tween_node.interpolate_property(object, property, initial_val, final_val, duration, trans_type, ease_type, delay)
	if invert:
		tween_node.interpolate_property(object, property, final_val, initial_val, duration, trans_type, ease_type, duration) # Inverted animation
	tween_node.start()

func play_sound(sound, dB, delay):
	var audio_node = AudioStreamPlayer.new()
	audio_node.stream = sound
	audio_node.volume_db = dB
	audio_node.pitch_scale = rand_range(0.95, 1.05)
	add_child(audio_node)
	yield(get_tree().create_timer(delay), "timeout")
	audio_node.play()
	yield(get_tree().create_timer(10.0), "timeout")
	audio_node.queue_free()
