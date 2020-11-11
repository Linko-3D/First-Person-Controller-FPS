# Shooting ability with left click and reloading with R

extends RayCast

export var fire_rate = 0.1
export var weapon_sway = 8.0
export var max_ammo = 12

var current_ammo = max_ammo

export (PackedScene) var impact
export (PackedScene) var shell

export (Resource) var shoot
export (Resource) var reload
export (Resource) var empty
export (Resource) var shell_impact


var mouse_relative_x = 0
var mouse_relative_y = 0

var camera_node = null

var hand_position

func _ready():
	$FireRate.wait_time = fire_rate
	camera_node = get_tree().get_root().find_node("Camera", true, false)
	$Shoulder/Hand/Nozzle/ShootLight.hide()
	
	hand_position = $Shoulder/Hand.translation.z

	randomize()

func _input(event):
	if event is InputEventMouseMotion: # Getting the mouse movement for the weapon sway in the physics process
		mouse_relative_x = event.relative.x
		mouse_relative_y = event.relative.y
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed: # Shooting
			if $FireRate.time_left == 0 and not $ReloadTween.is_active():
				if current_ammo > 0:
					shoot()
				else:
					play_sound(empty, 0, 0)
					$FireRate.start()

	if Input.is_key_pressed(KEY_R): # Reloading
		if current_ammo < max_ammo:
			if not $ShootTween.is_active() and not $ReloadTween.is_active():
				tween($ReloadTween, $Shoulder/Hand, "rotation_degrees:x", 0, 360, 1, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0, false)
				current_ammo = max_ammo
				play_sound(reload, 0, 0)
				print(current_ammo)

func shoot():
	play_sound(shoot, 0, 0)
	play_sound(shell_impact, -10, 0.75)
	current_ammo -= 1
	print(current_ammo)
	$FireRate.start()
	$Shoulder/Hand/Nozzle/ShootLight.show()
	
	# Recoil animation:
	tween($ShootTween, $Shoulder/Hand, "rotation_degrees:x", 0, 20, 0.075, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0, true)
	tween($ShootTween, $Shoulder/Hand, "translation:z", hand_position, hand_position + 0.1, 0.075, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0, true)
	
	# Camera shake:
	tween($ShootTween, camera_node, "rotation_degrees:x", 0, 1, 0.075, 0, 2, 0, true)
	
	if shell:
		var shell_instance = shell.instance()
		get_tree().get_root().add_child(shell_instance)
		shell_instance.global_transform = $Shoulder/Hand/Shell.global_transform
		shell_instance.linear_velocity = $Shoulder/Hand/Shell.global_transform.basis.x * 5
	
	if is_colliding():
		if impact:
			var impact_instance = impact.instance()
			get_tree().get_root().add_child(impact_instance)
			impact_instance.global_transform.origin = get_collision_point()
			impact_instance.look_at(get_collision_point() - get_collision_normal(), Vector3.UP)
			
			if get_collider() is RigidBody:
				get_collider().apply_central_impulse(-get_collision_normal() * 100)
				impact_instance.hide_bullet()
			
			if get_collider().is_in_group("Destructible"):
				get_collider().queue_free()
				impact_instance.hide_bullet()
	yield(get_tree().create_timer(0.1), "timeout")
	$Shoulder/Hand/Nozzle/ShootLight.hide()

func _physics_process(delta):
	$Shoulder.rotation_degrees.x = lerp($Shoulder.rotation_degrees.x, mouse_relative_y / 4, weapon_sway * delta)
	$Shoulder.rotation_degrees.y = lerp($Shoulder.rotation_degrees.y, mouse_relative_x / 4, weapon_sway * delta)

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
