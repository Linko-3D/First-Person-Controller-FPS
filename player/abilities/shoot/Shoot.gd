extends Spatial

export (PackedScene) var impact
export (PackedScene) var muzzle_flash_mesh
export (PackedScene) var shell_mesh
export (PackedScene) var magazine_mesh

export (Resource) var shoot_sound
export (Resource) var reload_sound
export (Resource) var empty_sound

var damage = 100

var shooting_echo = true

var bullet_spread_angle = 30

var weapon_sway = 5
var mouse_relative_x = 0
var mouse_relative_y = 0

var max_ammo = 30
var ammo = 30

var accuracy = 1

onready var fall = $JumpFall
onready var aim = $JumpFall/Aim
onready var sway_bobbing = $JumpFall/Aim/SwayBobbingIdle
onready var orientation_walk_run = $JumpFall/Aim/SwayBobbingIdle/OrientationWalkRun
onready var look_at = $JumpFall/Aim/SwayBobbingIdle/OrientationWalkRun/LookAt
onready var direction = $JumpFall/Aim/SwayBobbingIdle/OrientationWalkRun/LookAt/Shoot/Direction

onready var shoot = $JumpFall/Aim/SwayBobbingIdle/OrientationWalkRun/LookAt/Shoot
onready var reload = $JumpFall/Aim/SwayBobbingIdle/OrientationWalkRun/LookAt/Shoot/Reload

onready var shell = $JumpFall/Aim/SwayBobbingIdle/OrientationWalkRun/LookAt/Shoot/Reload/WeaponModel/Shell
onready var magazine = $JumpFall/Aim/SwayBobbingIdle/OrientationWalkRun/LookAt/Shoot/Reload/WeaponModel/Magazine
onready var muzzle = $JumpFall/Aim/SwayBobbingIdle/OrientationWalkRun/LookAt/Shoot/Reload/WeaponModel/Muzzle

onready var raycast = $BulletSpread/RayCast

onready var player = get_tree().get_root().find_node("Player", true, false)
onready var camera = get_tree().get_root().find_node("Camera", true, false)
onready var feedback_hit = get_tree().get_root().find_node("FeedbackHit", true, false)
onready var grab = get_tree().get_root().find_node("Grab", true, false)

func _input(event):
#	Getting the mouse movement for the weapon sway in the physics process
	if event is InputEventMouseMotion:
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
	
#	Reload
	if Input.is_key_pressed(KEY_R) or Input.is_joy_button_pressed(0, JOY_XBOX_X):
		if not Input.is_mouse_button_pressed(BUTTON_LEFT) and not Input.get_joy_axis(0, 7) >= 0.5 and not player.slide:
			if not $ReloadTween.is_active() and ammo != max_ammo:
				ammo = max_ammo
				$AmmoText.text = str(ammo)
				$AmmoText.modulate = Color(1, 1, 1)
				$MagazineTimer.start()
				$ReloadTween.interpolate_property(reload, "rotation_degrees:x", 0, 360, 1, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0)
				play_sound(reload_sound, 0, 0)
				$ReloadTween.start()

func _process(delta):
#	Animation when falling on the ground
	if player.is_on_floor() and not player.on_ground:
		var max_rotation = clamp(player.gravity_vec.y * 2, -30, 0) # Use the impact velocity for the angle and clamp the value
		$LandingTween.interpolate_property(fall, "rotation_degrees:x", 0, max_rotation, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0)
		$LandingTween.interpolate_property(fall, "rotation_degrees:x", max_rotation, 0, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
		$LandingTween.start()
	
#	When aiming with the right-click the weapon is centered and the accuracy set to 2 for the bullet spread calculation
	
	if Input.is_mouse_button_pressed(BUTTON_RIGHT) or Input.get_joy_axis(0, 6) >= 0.6:
		if player.is_on_floor() and not $ReloadTween.is_active() and not player.slide:
			accuracy = 2
		else:
			accuracy = 1
	else:
		accuracy = 1
	
	if grab:
		if grab.object_grabbed:
			accuracy = 1
	
	if not $AimTween.is_active():
		if accuracy == 1:
			if player.direction == Vector3():
				if aim.translation != Vector3(0.15, -0.1, -0.2):
					$AimTween.interpolate_property(aim, "translation", aim.translation, Vector3(0.15, -0.1, -0.2), 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
					$AimTween.start()
			else:
				if aim.translation != Vector3(0.14, -0.12, -0.2): # If we walk or run the weapon is lower
					$AimTween.interpolate_property(aim, "translation", aim.translation, Vector3(0.14, -0.12, -0.2), 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
					$AimTween.start()
		else:
			if aim.translation != Vector3(0, -0.06, -0.12):
				$AimTween.interpolate_property(aim, "translation", aim.translation, Vector3(0, -0.06, -0.12), 0.3)
				$AimTween.start()
	
#	Weapon sway
	sway_bobbing.rotation_degrees.z = lerp(sway_bobbing.rotation_degrees.z, -mouse_relative_x / 10, weapon_sway * delta)
	sway_bobbing.rotation_degrees.y = lerp(sway_bobbing.rotation_degrees.y, mouse_relative_x / 20, weapon_sway * delta)
	sway_bobbing.rotation_degrees.x = lerp(sway_bobbing.rotation_degrees.x, -mouse_relative_y / 10, weapon_sway * delta)
	
#	Weapon bobbing if walking, the player speed (walking, crouching, sprinting) is used for the animation speed
	if player.direction != Vector3():
		if not $HBobbingTween.is_active():
			var animation_speed = clamp(0.4 / player.speed_multiplier, 0.4/1.6, 0.4)
			$HBobbingTween.interpolate_property(sway_bobbing, "translation:x", sway_bobbing.translation.x, -0.01 * player.speed_multiplier, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$HBobbingTween.interpolate_property(sway_bobbing, "translation:x", -0.01 * player.speed_multiplier, 0, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, animation_speed)
			$HBobbingTween.start()
		if not $VBobbingTween.is_active(): 
			var animation_speed = clamp(0.25 / player.speed_multiplier, 0.25/1.6, 0.25)
			$VBobbingTween.interpolate_property(sway_bobbing, "translation:y", sway_bobbing.translation.y, -0.01 * player.speed_multiplier, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$VBobbingTween.interpolate_property(sway_bobbing, "translation:y", -0.01 * player.speed_multiplier, 0, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT, animation_speed)
			$VBobbingTween.start()
	
#	If sprinting orient the weapon
	if player.speed_multiplier == 2 and not $ReloadTween.is_active() and not player.get_node("CrouchTween").is_active():
		$WeaponTween.stop_all() #Stop the shooting animation
		if not $OrientationWalkRunTween.is_active() and orientation_walk_run.rotation_degrees != Vector3(-5, 35, 15):
			$OrientationWalkRunTween.interpolate_property(orientation_walk_run, "rotation_degrees", orientation_walk_run.rotation_degrees, Vector3(-5, 35, 15), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$OrientationWalkRunTween.start()
	else:
		if not $OrientationWalkRunTween.is_active() and orientation_walk_run.rotation_degrees != Vector3():
			$OrientationWalkRunTween.interpolate_property(orientation_walk_run, "rotation_degrees", orientation_walk_run.rotation_degrees, Vector3(), 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$OrientationWalkRunTween.start()
	
	# The weapon is oriented on the target if not running
	if player.speed_multiplier != 2:
		if raycast.is_colliding():
			direction.look_at(raycast.get_collision_point(), Vector3.UP)
			look_at.rotation_degrees = lerp(look_at.rotation_degrees, direction.rotation_degrees, 10 * delta)
		else:
			look_at.rotation_degrees = lerp(look_at.rotation_degrees, Vector3(), 10 * delta)
	else:
		look_at.rotation_degrees = lerp(look_at.rotation_degrees, Vector3(), 10 * delta)
	
#	Position the ammo text dynamically at any screen resolution
	$AmmoText.margin_top = get_viewport().size.y / 10 * -1
	$AmmoText.margin_left = get_viewport().size.y / 10 * -1
	
#	Shoot
	if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.get_joy_axis(0, 7) >= 0.5:
		if $FireRate.is_stopped() and player.is_on_floor():
			if not player.speed_multiplier == 2 and not player.slide and not $ReloadTween.is_active() and orientation_walk_run.rotation_degrees.y < 5:
				$FireRate.start()
				if ammo > 0:
					ammo -= 1
					$AmmoText.text = str(ammo)
					$AmmoTextTween.stop_all()
					$AmmoTextTween.interpolate_property($AmmoText.get_font("font"), "size", 35, 30, 0.15)
					$AmmoTextTween.start()
					shoot()
					if ammo <= 5:
						$AmmoText.modulate = Color(0.68, 0.17, 0.15)
				else:
					play_sound(empty_sound, 0, 0)

func shoot():
	shoot_animation()
	
	# Calculate bullet spread amount
	var recoil = 0
	if player.direction == Vector3():
		recoil = $RecoilTimer.time_left * bullet_spread_angle / accuracy
	else:
		recoil = $RecoilTimer.time_left * bullet_spread_angle * 1.5 / accuracy
	
	$BulletSpread.rotation_degrees.z = rand_range(0, 360)
	raycast.rotation_degrees.y = rand_range(-recoil, recoil)
	$RecoilTimer.start()
	
	# Spawn instances
	spawn_impact()
	spawn_muzzle_flash()
	spawn_shell()
	
	# Hit enemy feedback
	if raycast.is_colliding():
		if raycast.get_collider().is_in_group("Enemy"):
			if feedback_hit:
				feedback_hit.display()
	
	# Adding echo
	if shooting_echo:
		var delay = 0
		var volume = 0
		for i in 5: # Add an echo effect when shooting by delaying the sound and reducing the volume
			play_sound(shoot_sound, volume, delay)
			delay += 0.5
			volume -= 15
	else:
		play_sound(shoot_sound, 0, 0)


func spawn_muzzle_flash():
	var muzzle_flash_instance = muzzle_flash_mesh.instance()
	get_tree().get_root().add_child(muzzle_flash_instance)
	muzzle_flash_instance.global_transform = muzzle.global_transform

func spawn_impact():
	if raycast.is_colliding():
		
		var color = Color(1, 1, 1)
		
		var collider = raycast.get_collider()
		if collider.get_class() == "CSGBox" or collider.get_class() == "CSGCylinder" or collider.get_class() == "CSGMesh" or collider.get_class() == "CSGPolygon" or collider.get_class() == "CSGSphere" or collider.get_class() == "CSGTorus":
			if collider.get_material_override():
				color = collider.get_material_override().albedo_color
		
		for i in collider.get_child_count():
			if collider.get_child(i).get_class() == "MeshInstance":
				if collider.get_child(i).get_material_override():
					color = collider.get_child(i).get_material_override().albedo_color
				if collider.get_child(i).get_surface_material(0):
					color = collider.get_child(i).get_surface_material(0).albedo_color
		
		var impact_instance = impact.instance()
		
		impact_instance.color = color
		
		get_tree().get_root().add_child(impact_instance)
		
		impact_instance.global_transform.origin = raycast.get_collision_point()
		impact_instance.look_at(raycast.get_collision_point() - raycast.get_collision_normal(), Vector3.UP)
		impact_instance.get_node("Particles").emitting = true
		impact_instance.get_node("ImpactSound").pitch_scale = rand_range(0.95, 1.05)
		

		
		if raycast.get_collider() is RigidBody:
			raycast.get_collider().apply_central_impulse(-raycast.get_collision_normal() * damage)
			impact_instance.hide_bullet()

func spawn_shell():
	var shell_instance = shell_mesh.instance()
	get_tree().get_root().add_child(shell_instance)
	shell_instance.global_transform = shell.global_transform
	shell_instance.linear_velocity = shell.global_transform.basis.x * 2.5
	shell_instance.get_node("ImpactSound").pitch_scale = rand_range(0.95, 1.05)

func spawn_magazine():
	var magazine_instance = magazine_mesh.instance()
	get_tree().get_root().add_child(magazine_instance)
	magazine_instance.global_transform = magazine.global_transform
	magazine_instance.linear_velocity = magazine.global_transform.basis.z * 3

func play_sound(sound, dB, delay):
	var audio_node = AudioStreamPlayer.new()
	audio_node.stream = sound
	audio_node.volume_db = dB
	audio_node.pitch_scale = rand_range(0.95, 1.05)
	get_tree().get_root().add_child(audio_node)
	yield(get_tree().create_timer(delay), "timeout")
	audio_node.play()
	yield(get_tree().create_timer(10.0), "timeout")
	audio_node.queue_free()

func shoot_animation():
	var strength = float(damage) / 100 / accuracy
	$WeaponTween.stop_all()

	# Weapon animation
	$WeaponTween.interpolate_property(shoot, "translation:z", 0, 0.03 * strength, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$WeaponTween.interpolate_property(shoot, "translation:z", 0.03 * strength, -0.02 * strength, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	$WeaponTween.interpolate_property(shoot, "translation:z", -0.02 * strength, 0.01 * strength, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	$WeaponTween.interpolate_property(shoot, "translation:z", 0.01 * strength, 0, 0.6, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)

	$WeaponTween.interpolate_property(shoot, "rotation_degrees:x", 0, -2, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$WeaponTween.interpolate_property(shoot, "rotation_degrees:x", -2, 3, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.15)
	$WeaponTween.interpolate_property(shoot, "rotation_degrees:x", 3, -1, 0.65, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.25)
	$WeaponTween.interpolate_property(shoot, "rotation_degrees:x", -1, 0, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.9)

	$WeaponTween.interpolate_property(shoot, "rotation_degrees:z", 0, 5 * strength, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	$WeaponTween.interpolate_property(shoot, "rotation_degrees:z", 5 * strength, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.25)

	# Camera shaking
	$WeaponTween.interpolate_property(camera, "rotation_degrees:x", camera.rotation_degrees.x, 1 * strength, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$WeaponTween.interpolate_property(camera, "rotation_degrees:x", 1 * strength, -0.5 / accuracy, 0.6, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	$WeaponTween.interpolate_property(camera, "rotation_degrees:x", -0.5 * strength, 0, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.7)
	$WeaponTween.interpolate_property(camera, "rotation_degrees:z", 0, -2 * strength, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$WeaponTween.interpolate_property(camera, "rotation_degrees:z", -2 * strength, 1.5 * strength, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	$WeaponTween.interpolate_property(camera, "rotation_degrees:z", 1.5 * strength, -1 * strength, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.15)
	$WeaponTween.interpolate_property(camera, "rotation_degrees:z", -1 * strength, 0.5 * strength, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.25)
	$WeaponTween.interpolate_property(camera, "rotation_degrees:z", 0.5 * strength, -0.25 * strength, 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.35)
	$WeaponTween.interpolate_property(camera, "rotation_degrees:z", -0.25 * strength, 0, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.6)

	$WeaponTween.start()

func _on_RecoilTimer_timeout():
	raycast.rotation_degrees = Vector3()

func _on_MagazineTimer_timeout():
	spawn_magazine()
