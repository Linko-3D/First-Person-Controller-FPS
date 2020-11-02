extends RayCast

export var fire_rate = 0.2
export var weapon_sway = 8.0
export var max_ammo = 12

var current_ammo = max_ammo

var impact = "res://player/shoot/Impact.tscn"
var shell = "res://player/shoot/Shell.tscn"

var mouse_relative_x = 0
var mouse_relative_y = 0

var camera_node = null

func _ready():
	$FireRate.wait_time = fire_rate
	camera_node = get_tree().get_root().find_node("Camera", true, false)

func _input(event):
	if event is InputEventMouseMotion: # Getting the mouse movement for the weapon sway in the physics process
		mouse_relative_x = event.relative.x
		mouse_relative_y = event.relative.y
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed: # Shooting
			if $FireRate.time_left == 0 and current_ammo > 0 and not $ReloadTween.is_active():
				current_ammo -= 1
				print(current_ammo)
				$FireRate.start()
				$ShootSound.play()
				
				# Recoil animation:
				tween($ShootTween, $Shoulder/Hand, "rotation_degrees:x", 0, 20, 0.075, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0, true)
				tween($ShootTween, $Shoulder/Hand, "translation:z", $Shoulder/Hand.translation.z, $Shoulder/Hand.translation.z + 0.1, 0.075, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0, true)
				
				# Camera shake:
				tween($ShootTween, camera_node, "rotation_degrees:x", 0, 1, 0.075, 0, 2, 0, true)
				
				var shell_instance = load(shell).instance()
				get_tree().get_root().add_child(shell_instance)
				shell_instance.global_transform = $Shoulder/Hand/ShellPosition.global_transform
				shell_instance.linear_velocity = $Shoulder/Hand/ShellPosition.global_transform.basis.x * 5
				
				if is_colliding():
					var impact_instance = load(impact).instance()
					get_tree().get_root().add_child(impact_instance)
					impact_instance.global_transform.origin = get_collision_point()
					impact_instance.look_at(get_collision_point() - get_collision_normal(), Vector3.UP)
					
					if get_collider() is RigidBody:
						get_collider().apply_central_impulse(-get_collision_normal() * 50)
						impact_instance.hide_bullet()

	if Input.is_key_pressed(KEY_R): # Reloading
		if current_ammo < max_ammo:
			if not $ShootTween.is_active() and not $ReloadTween.is_active():
				tween($ReloadTween, $Shoulder/Hand, "rotation_degrees:x", 0, 360, 1, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0, false)
				current_ammo = max_ammo
				print(current_ammo)
				$ReloadSound.play()

func _physics_process(delta):
	$Shoulder.rotation_degrees.x = lerp($Shoulder.rotation_degrees.x, mouse_relative_y / 4, weapon_sway * delta)
	$Shoulder.rotation_degrees.y = lerp($Shoulder.rotation_degrees.y, mouse_relative_x / 4, weapon_sway * delta)

func tween(tween_node, object, property, initial_val, final_val, duration, trans_type, ease_type, delay, invert):
	tween_node.interpolate_property(object, property, initial_val, final_val, duration, trans_type, ease_type, delay)
	if invert:
		tween_node.interpolate_property(object, property, final_val, initial_val, duration, trans_type, ease_type, duration) # Inverted animation
	tween_node.start()
