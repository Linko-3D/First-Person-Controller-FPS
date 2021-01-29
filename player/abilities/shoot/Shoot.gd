extends Spatial

export (PackedScene) var impact
export (PackedScene) var muzzle_flash
export (PackedScene) var shell_mesh
export (PackedScene) var magazine

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

onready var shoulder = $Shoulder
onready var hand = $Shoulder/Hand
onready var weapon = $Shoulder/Hand/Weapon
onready var weapon_model = $Shoulder/Hand/Weapon/WeaponModel
onready var muzzle = $Shoulder/Hand/Weapon/WeaponModel/Muzzle
onready var shell = $Shoulder/Hand/Weapon/WeaponModel/Shell
onready var magazine_position = $Shoulder/Hand/Weapon/WeaponModel/AmmoPosition

onready var player = get_tree().get_root().find_node("Player", true, false)
onready var camera = get_tree().get_root().find_node("Camera", true, false)

func _input(event):
	if event is InputEventMouseMotion: # Getting the mouse movement for the weapon sway in the physics process
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

	if Input.is_key_pressed(KEY_R) and not Input.is_mouse_button_pressed(BUTTON_RIGHT): # Reloading
		if not $ReloadTween.is_active() and ammo != max_ammo:
			ammo = max_ammo
			$AmmoText.text = str(ammo)
			$AmmoText.modulate = Color(1, 1, 1)
			spawn_magazine()
			$ReloadTween.interpolate_property(weapon_model, "rotation_degrees:x", 0, 360, 1, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0)
			play_sound(reload_sound, 0, 0)
			$ReloadTween.start()

func _process(delta):
	# Position the ammo text dynamically at any screen resolution
	$AmmoText.margin_top = get_viewport().size.y / 10 * -1
	$AmmoText.margin_left = get_viewport().size.y / 10 * -1
	$AmmoText.margin_right = $AmmoText.margin_left + 16
	$AmmoText.margin_bottom = $AmmoText.margin_top + 12
	
	$BackgroundText.margin_top = $AmmoText.margin_top
	$BackgroundText.margin_left = $AmmoText.margin_left
	$BackgroundText.margin_right = $AmmoText.margin_right
	$BackgroundText.margin_bottom = $AmmoText.margin_bottom
	
	# If sprinting orient the weapon
	if player.speed_multiplier == 2 and not $ReloadTween.is_active() and not player.get_node("CrouchTween").is_active():
		weapon.rotation_degrees = lerp(weapon.rotation_degrees, Vector3(-5, 35, 15), 10 * delta)
		$WeaponTween.stop_all()
	else:
		weapon.rotation_degrees = lerp(weapon.rotation_degrees, Vector3(), 10 * delta)
	
	# Weapon bobbing if walking, the player speed (walking, crouching, sprinting) is used for the animation speed
	if player.direction != Vector3():
		if not $HBobbingTween.is_active():
			var animation_speed = clamp(0.4 / player.speed_multiplier, 0.4/1.6, 0.4)
			$HBobbingTween.interpolate_property(weapon, "translation:x", 0, -0.01 * player.speed_multiplier, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$HBobbingTween.interpolate_property(weapon, "translation:x", -0.01 * player.speed_multiplier, 0, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, animation_speed)
			$HBobbingTween.start()
		if not $VBobbingTween.is_active(): 
			var animation_speed = clamp(0.25 / player.speed_multiplier, 0.25/1.6, 0.25)
			$VBobbingTween.interpolate_property(weapon, "translation:y", 0, -0.01 * player.speed_multiplier, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$VBobbingTween.interpolate_property(weapon, "translation:y", -0.01 * player.speed_multiplier, 0, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT, animation_speed)
			$VBobbingTween.start()
	
	# When aiming with the right-click the weapon is centered and the accuracy set to 2 for the bullet spread calculation
	if Input.is_mouse_button_pressed(BUTTON_RIGHT) and player.is_on_floor() and not $ReloadTween.is_active():
		accuracy = 2
		hand.translation = lerp(hand.translation, Vector3(0, -0.13, -0.12), 10 * delta)
		hand.rotation_degrees = lerp(hand.rotation_degrees, Vector3(), 10 * delta)
	else:
		accuracy = 1
		if player.direction == Vector3(): # The weapon is slightly lower when walking
			hand.translation = lerp(hand.translation, Vector3(0.15, -0.15, -0.2), 10 * delta)
			hand.rotation_degrees.x = lerp(hand.rotation_degrees.x, 0, 10 * delta)
		else:
			hand.translation = lerp(hand.translation, Vector3(0.14, -0.17, -0.2), 10 * delta)
			hand.rotation_degrees.x = lerp(hand.rotation_degrees.x, 2, 10 * delta)
	
	# Weapon sway
	hand.rotation_degrees.z = lerp(hand.rotation_degrees.z, -mouse_relative_x / 10, weapon_sway * delta)
	hand.rotation_degrees.y = lerp(hand.rotation_degrees.y, mouse_relative_x / 20, weapon_sway * delta)
	hand.rotation_degrees.x = lerp(hand.rotation_degrees.x, -mouse_relative_y / 10, weapon_sway * delta)
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and $FireRate.is_stopped() and player.is_on_floor():
		if not player.speed_multiplier == 2 and not $ReloadTween.is_active() and weapon.rotation_degrees.y < 5:
			$FireRate.start()
			if ammo > 0:
				ammo -= 1
				$AmmoText.text = str(ammo)
				if ammo <= 5:
					$AmmoText.modulate = Color(1, 0, 0)
				shoot()
			else:
				play_sound(empty_sound, 0, 0)
			
	# Animation when falling on the ground
	if player.is_on_floor() and not player.on_ground:
		var max_rotation = clamp(player.gravity_vec.y * 2, -30, 0) # Use the impact velocity for the angle and clamp the value
		$LandingTween.interpolate_property($Shoulder, "rotation_degrees:x", 0, max_rotation, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0)
		$LandingTween.interpolate_property($Shoulder, "rotation_degrees:x", max_rotation, 0, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
		$LandingTween.start()

func shoot_animation():
	var strength = float(damage) / 100 / accuracy
	$WeaponTween.stop_all()
	
	# Weapon animation
	$WeaponTween.interpolate_property(weapon, "translation:z", 0, 0.03 * strength, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$WeaponTween.interpolate_property(weapon, "translation:z", 0.03 * strength, -0.02 * strength, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	$WeaponTween.interpolate_property(weapon, "translation:z", -0.02 * strength, 0.01 * strength, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	$WeaponTween.interpolate_property(weapon, "translation:z", 0.01 * strength, 0, 0.6, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)

	$WeaponTween.interpolate_property(weapon, "rotation_degrees:x", 0, -2, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$WeaponTween.interpolate_property(weapon, "rotation_degrees:x", -2, 3, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.15)
	$WeaponTween.interpolate_property(weapon, "rotation_degrees:x", 3, -1, 0.65, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.25)
	$WeaponTween.interpolate_property(weapon, "rotation_degrees:x", -1, 0, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.9)

	$WeaponTween.interpolate_property(weapon, "rotation_degrees:z", 0, 5 * strength, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	$WeaponTween.interpolate_property(weapon, "rotation_degrees:z", 5 * strength, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.25)
	
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

func shoot():
	shoot_animation()
	
	# Calculate bullet spread amount
	var recoil = 0
	if player.direction == Vector3():
		recoil = $RecoilTimer.time_left * bullet_spread_angle / accuracy
	else:
		recoil = $RecoilTimer.time_left * bullet_spread_angle * 1.5 / accuracy
	
	$BulletSpread.rotation_degrees.z = rand_range(0, 360)
	$BulletSpread/RayCast.rotation_degrees.y = rand_range(-recoil, recoil)
	$RecoilTimer.start()
	
	# Spawn instances
	spawn_impact()
	spawn_muzzle_flash()
	spawn_shell()
	
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
	var muzzle_flash_instance = muzzle_flash.instance()
	get_tree().get_root().add_child(muzzle_flash_instance)
	muzzle_flash_instance.global_transform = muzzle.global_transform

func spawn_impact():
	if $BulletSpread/RayCast.is_colliding():
		var impact_instance = impact.instance()
		get_tree().get_root().add_child(impact_instance)
		impact_instance.global_transform.origin = $BulletSpread/RayCast.get_collision_point()
		impact_instance.look_at($BulletSpread/RayCast.get_collision_point() - $BulletSpread/RayCast.get_collision_normal(), Vector3.UP)
		impact_instance.get_node("Particles").emitting = true
		impact_instance.get_node("ImpactSound").pitch_scale = rand_range(0.95, 1.05)
			
		if $BulletSpread/RayCast.get_collider() is RigidBody:
			$BulletSpread/RayCast.get_collider().apply_central_impulse(-$BulletSpread/RayCast.get_collision_normal() * damage)
			impact_instance.hide_bullet()

func spawn_shell():
	var shell_instance = shell_mesh.instance()
	get_tree().get_root().add_child(shell_instance)
	shell_instance.global_transform = shell.global_transform
	shell_instance.linear_velocity = shell.global_transform.basis.x * 2.5
	shell_instance.get_node("ImpactSound").pitch_scale = rand_range(0.95, 1.05)
	yield(get_tree().create_timer(0.75), "timeout") # We add a delay before playing the sound to simulate the time of the shell to fall on the ground
	shell_instance.get_node("ImpactSound").play()
	yield(get_tree().create_timer(10), "timeout")
	shell_instance.queue_free()

func spawn_magazine():
	var magazine_instance = magazine.instance()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().get_root().add_child(magazine_instance)
	magazine_instance.global_transform = magazine_position.global_transform
	magazine_instance.linear_velocity = magazine_position.global_transform.basis.z * 3

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
