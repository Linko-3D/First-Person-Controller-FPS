extends Spatial

export (Resource) var rifle_model
export (Resource) var pistol_model
export (Resource) var knife_model

export (PackedScene) var impact
export (PackedScene) var shell
export (PackedScene) var magazine

export (Resource) var rifle_shoot_sound
export (Resource) var pistol_shoot_sound
export (Resource) var bang_sound
export (Resource) var reload_sound
export (Resource) var empty_sound
export (Resource) var melee_hit_sound

onready var shoot_sound = rifle_shoot_sound

var weapon1_ammo = 30
var weapon1_clip = 90
var weapon1_max_ammo = weapon1_ammo

var weapon2_ammo = 20
var weapon2_clip = 120
var weapon2_max_ammo = weapon2_ammo

var ammo = weapon1_ammo
var max_ammo = weapon1_max_ammo
var clip = weapon1_clip

var bullet_spread = 25

var shooting_sound_echo = true

var weapon_sway_amount = 5
var mouse_relative_x = 0
var mouse_relative_y = 0

var singleshot = false
var can_shoot = true
var weapon_selected = 1
var weapon_position_z = -0.2

var can_attack = true

var can_switch_joy_dpad = true

var reload_tip_displayed = false

onready var weapon = $Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon

onready var player = get_tree().get_root().find_node("Player", true, false)
onready var camera = player.get_node("Head/Camera")

func _ready():
	$HUD/DisplayAmmo/AmmoText.text = str(ammo)
	$HUD/DisplayAmmo/ClipText.text = str(clip)

func _input(event):
	# Getting the mouse movement for the weapon sway in the physics process
	if event is InputEventMouseMotion:
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
		
		
	if event is InputEventMouseButton:
		if event.is_pressed() and not $AttackTween.is_active():
			if event.button_index == BUTTON_WHEEL_DOWN:
				if not $ReloadTween.is_active():
					weapon_selected += 1
					switch_weapon()
			if event.button_index == BUTTON_WHEEL_UP:
				if not $ReloadTween.is_active():
					weapon_selected -= 1
					switch_weapon()

func _process(delta):
	# Animation when falling on the ground
	if player.is_on_floor() and not player.snapped:
		var max_rotation = clamp(player.gravity_vec.y, -20, 0) # Use the impact velocity for the angle and clamp the value
		$LandingTween.interpolate_property($Torso, "rotation_degrees:x", 0, max_rotation, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0)
		$LandingTween.interpolate_property($Torso, "rotation_degrees:x", max_rotation, 0, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
		$LandingTween.start()
	
	
	if not $AttackTween.is_active():
		if not $ReloadTween.is_active():
			if Input.is_key_pressed(KEY_1):
				if weapon_selected != 1:
					weapon_selected = 1
					switch_weapon()
				
			if Input.is_key_pressed(KEY_2):
				if weapon_selected != 2:
					weapon_selected = 2
					switch_weapon()
		
		if can_switch_joy_dpad:
			if Input.is_joy_button_pressed(0, JOY_DPAD_RIGHT) or Input.is_joy_button_pressed(0, JOY_DPAD_DOWN):
				weapon_selected += 1
				switch_weapon()
			if Input.is_joy_button_pressed(0, JOY_DPAD_UP) or Input.is_joy_button_pressed(0, JOY_DPAD_LEFT):
				weapon_selected -= 1
				switch_weapon()
		
		if Input.is_joy_button_pressed(0, JOY_DPAD_LEFT) or Input.is_joy_button_pressed(0, JOY_DPAD_RIGHT) or Input.is_joy_button_pressed(0, JOY_DPAD_UP) or Input.is_joy_button_pressed(0, JOY_DPAD_DOWN):
			can_switch_joy_dpad = false
		else:
			can_switch_joy_dpad = true
		
	# Uses a lerp to copy to smoothly copy the rotation on the LookAt node
	if $BulletSpread/RayCast.is_colliding() and not $LandingTween.is_active():
		$Torso/Position3D/LookAt.look_at($BulletSpread/RayCast.get_collision_point(), Vector3.UP)
		$Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp.rotation_degrees = lerp($Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp.rotation_degrees, $Torso/Position3D/LookAt.rotation_degrees, 10 * delta)
	else:
		$Torso/Position3D/LookAt.rotation_degrees = Vector3()
		$Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp.rotation_degrees = lerp($Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp.rotation_degrees, $Torso/Position3D/LookAt.rotation_degrees, 10 * delta)
	$Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp.rotation_degrees.z = 0

	# Weapon sway
	$Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.z = lerp($Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.z, -mouse_relative_x / 10, weapon_sway_amount * delta)
	$Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.y = lerp($Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.y, mouse_relative_x / 20, weapon_sway_amount * delta)
	$Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.x = lerp($Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.x, -mouse_relative_y / 10, weapon_sway_amount * delta)
	
	var weapon_movement = clamp(player.player_speed * 0.003, 0, 0.018)
	
	
	if round(player.player_speed) == 0:
		$Torso/Position3D.translation.y = lerp($Torso/Position3D.translation.y, -0.1, 5 * delta)
		$Torso/Position3D.translation.z = lerp($Torso/Position3D.translation.z, weapon_position_z, 5 * delta)
	else:
		$Torso/Position3D.translation.y = lerp($Torso/Position3D.translation.y, -0.1 + -weapon_movement, 5 * delta)
		$Torso/Position3D.translation.z = lerp($Torso/Position3D.translation.z, weapon_position_z + weapon_movement, 5 * delta)
		
		if player.is_on_floor() and player.player_speed >= 2:
			weapon_bobbing_animation()
	
	if $ReloadTween.is_active() or $SwitchTween.is_active() or $AttackTween.is_active():
		return
	
	if Input.is_key_pressed(KEY_V) or Input.is_mouse_button_pressed(BUTTON_MIDDLE) or Input.is_joy_button_pressed(0, JOY_R3):
		if can_attack:
			attack_animation()
		can_attack = false
	else:
		can_attack = true
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.get_joy_axis(0, 7) >= 0.6:
		if $FireRateTimer.is_stopped() and can_shoot:
			if ammo > 0:
				if Input.get_joy_axis(0, 7) >= 0.5:
						Input.start_joy_vibration(0, 0, 0.2, 0.1)
				shoot()
				$FireRateTimer.start()
			else:
				play_sound(empty_sound, -15, 0)
				$FireRateTimer.start()
	
	if singleshot:
		if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.get_joy_axis(0, 7) >= 0.6:
			can_shoot = false
		else:
			can_shoot = true
	else:
		can_shoot = true
	
	if Input.is_key_pressed(KEY_R) or Input.is_joy_button_pressed(0, JOY_XBOX_X):
		if ammo != max_ammo and clip > 0:
			$ReloadTween.interpolate_property(weapon, "rotation_degrees:x", 0, 360, 1, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0)
			$ReloadTween.start()
			
			calculate_ammo()
			
			# margin right -360 <> -91
			# spacing 269
			# 30 ammo = +8.96
			
			var step = 269.0 / max_ammo
			var current_position = -360 + (step * ammo)
			var color_step = (1.0 / max_ammo) * ammo
			
			$ReloadTween.interpolate_property($HUD/VisualAmmo, "modulate", Color(1, 0, 0), Color(1, 1, 1), 1)
			$ReloadTween.interpolate_property($HUD/VisualAmmo, "margin_right", -360, current_position, 1)
			$ReloadTween.start()
			
			play_sound(reload_sound, -5, 0)
			$SpawnMagazineTimer.start()

func shoot():
	ammo -= 1
	$HUD/DisplayAmmo/AmmoText.text = str(ammo)
	update_visual_ammo()
	play_sound(shoot_sound, -10, 0)
	# Adding echo
	if shooting_sound_echo:
		var delay = 0.1
		var dB = -15
		for i in 5: # Add an echo effect when shooting by delaying the sound and reducing the volume
			play_sound(bang_sound, dB, delay)
			delay += 0.5
			dB -= 15
	
#	play_sound(bang_sound, 0, 0)
	
	if weapon_selected == 1:
		rifle_shoot_animation()
	if weapon_selected == 2:
		pistol_shoot_animation()
	
	camera_shake()
	spawn_impact($BulletSpread/RayCast)
#	spawn_shell()
	
	# Calculate bullet spread amount
	var recoil = 0
	recoil = $RecoilTimer.time_left * bullet_spread * (1 + player.player_speed / 10)
	
	$BulletSpread.rotation_degrees.z = rand_range(0, 360)
	$BulletSpread/RayCast.rotation_degrees.y = rand_range(-recoil, recoil)
	
	$RecoilTimer.start()

func spawn_shell():
	var shell_instance = shell.instance()
	get_tree().get_root().add_child(shell_instance)
	shell_instance.global_transform = $Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/ShellSpawn.global_transform
	shell_instance.linear_velocity = $Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/ShellSpawn.global_transform.basis.x * 2.5

func spawn_magazine():
	var magazine_instance = magazine.instance()
	get_tree().get_root().add_child(magazine_instance)
	magazine_instance.global_transform = $Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/MagazineSpawn.global_transform
	magazine_instance.linear_velocity = $Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/MagazineSpawn.global_transform.basis.z * -3

func spawn_impact(raycast):
	if not raycast.is_colliding():
		return
	
	var impact_instance = impact.instance()
	get_tree().get_root().add_child(impact_instance)
	
	impact_instance.global_transform.origin = raycast.get_collision_point()
	impact_instance.look_at(raycast.get_collision_point() - raycast.get_collision_normal(), Vector3.UP)
	
	if raycast.get_collider() is RigidBody:
		raycast.get_collider().apply_central_impulse(-raycast.get_collision_normal() * 30)
	
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

func calculate_ammo():
	var difference = max_ammo - ammo
	# If we have more ammo missing than in the clip, take all the ammo in the clip remaining
	if difference > clip:
		ammo += clip
		clip = 0
	else:
		clip -= difference
		ammo = max_ammo

func rifle_shoot_animation():
	randomize()
	var value = rand_range(0.8, 1)
	$ShootTween.interpolate_property($Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight, "light_energy", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property($Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight, "light_energy", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	
	value = rand_range(0.035, 0.045)
	$ShootTween.interpolate_property(weapon, "translation:z", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property(weapon, "translation:z", value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	
	value = rand_range(-0.005, 0.005)
	$ShootTween.interpolate_property(weapon, "translation:x", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property(weapon, "translation:x",value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	
	value = rand_range(0.005, 0.015)
	$ShootTween.interpolate_property(weapon, "translation:y", 0, value, 0.075, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property(weapon, "translation:y", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.075)
	
	value = rand_range(-1.5, -0.5)
	$ShootTween.interpolate_property(weapon, "rotation_degrees:x", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property(weapon, "rotation_degrees:x", value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	
	value = rand_range(-1, 1)
	$ShootTween.interpolate_property(weapon, "rotation_degrees:z", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property(weapon, "rotation_degrees:z", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	$ShootTween.interpolate_property(weapon, "rotation_degrees:z", 0, -value, 0.075, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	$ShootTween.interpolate_property(weapon, "rotation_degrees:z", -value, 0, 0.075, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.175)
	$ShootTween.start()

func pistol_shoot_animation():
	randomize()
	var value = rand_range(0.8, 1)
	$ShootTween.interpolate_property($Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight, "light_energy", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property($Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight, "light_energy", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	
	value = rand_range(8, 12)
	$ShootTween.interpolate_property(weapon, "rotation_degrees:x", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property(weapon, "rotation_degrees:x", value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	
	value = rand_range(0.015, 0.025)
	$ShootTween.interpolate_property(weapon, "translation:y", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.025)
	$ShootTween.interpolate_property(weapon, "translation:y", value, 0, 0.125, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.075)
	
	value = rand_range(0.04, 0.06)
	$ShootTween.interpolate_property(weapon, "translation:z", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.025)
	$ShootTween.interpolate_property(weapon, "translation:z", value, 0, 0.125, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.075)
	
	value = rand_range(-0.005, 0.005)
	$ShootTween.interpolate_property(weapon, "translation:x", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property(weapon, "translation:x",value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	
	value = rand_range(-1, 1)
	$ShootTween.interpolate_property(weapon, "rotation_degrees:z", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property(weapon, "rotation_degrees:z", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	$ShootTween.interpolate_property(weapon, "rotation_degrees:z", 0, -value, 0.075, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	$ShootTween.interpolate_property(weapon, "rotation_degrees:z", -value, 0, 0.075, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.175)
	$ShootTween.start()

func camera_shake():
	$ShootTween.interpolate_property(camera, "rotation_degrees:x", 0, 1, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property(camera, "rotation_degrees:x", 1, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	randomize()
	var value = rand_range(-0.5, 0.5)
	$ShootTween.interpolate_property(camera, "rotation_degrees:y", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property(camera, "rotation_degrees:y", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	$ShootTween.start()

func weapon_bobbing_animation():
	var animation_speed = 1.0 / player.player_speed
	var animation_value = player.player_speed / 600 # 0.01
	
	if not $HBobbingTween.is_active():
		$HBobbingTween.interpolate_property($Torso/Position3D/SwitchAndAttack/Bobbing, "translation:x", 0, animation_value, animation_speed * 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$HBobbingTween.interpolate_property($Torso/Position3D/SwitchAndAttack/Bobbing, "translation:x", animation_value, 0, animation_speed * 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, animation_speed * 2)
		$HBobbingTween.start()
	
	if not $VBobbingTween.is_active():
		$VBobbingTween.interpolate_property($Torso/Position3D/SwitchAndAttack/Bobbing, "translation:y", 0, animation_value / 2, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$VBobbingTween.interpolate_property($Torso/Position3D/SwitchAndAttack/Bobbing, "translation:y", animation_value / 2, 0, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT, animation_speed)
		
		$VBobbingTween.interpolate_property($Torso/Position3D/SwitchAndAttack/Bobbing, "translation:z", 0, -animation_value / 10, animation_speed / 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$VBobbingTween.interpolate_property($Torso/Position3D/SwitchAndAttack/Bobbing, "translation:z", -animation_value / 10, 0, animation_speed / 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, animation_speed / 2)
		$VBobbingTween.interpolate_property($Torso/Position3D/SwitchAndAttack/Bobbing, "translation:z", 0, -animation_value / 10, animation_speed / 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, (animation_speed / 2) * 2)
		$VBobbingTween.interpolate_property($Torso/Position3D/SwitchAndAttack/Bobbing, "translation:z", -animation_value / 10, 0, animation_speed / 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, (animation_speed / 2) * 3)
		$VBobbingTween.start()

func switch_weapon():
	$SwitchSound.play()
	var text_color_active = Color(1, 1, 1, 1)
	var text_color_inactive = Color(1, 1, 1, 0.5)
	
	if weapon_selected > 2:
		weapon_selected = 1
	if weapon_selected < 1:
		weapon_selected = 2
	
	if weapon_selected == 1:
		weapon2_ammo = ammo
		weapon2_clip = clip
		
		ammo = weapon1_ammo
		clip = weapon1_clip 
		max_ammo = weapon1_max_ammo
	if weapon_selected == 2:
		weapon1_ammo = ammo
		weapon1_clip = clip
		
		ammo = weapon2_ammo
		clip = weapon2_clip
		max_ammo = weapon2_max_ammo
	
	update_visual_ammo()
	
	update_ammo_HUD()
	
	$SwitchTween.interpolate_property($Torso/Position3D/SwitchAndAttack, "translation", Vector3(0, -0.25, -0.1), Vector3(), 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$SwitchTween.interpolate_property($Torso/Position3D/SwitchAndAttack, "rotation_degrees", Vector3(-30, 20, 10), Vector3(), 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$SwitchTween.start()
	
	if weapon_selected == 1:
		$HUD/WeaponSelected/Primary.modulate = Color(1, 1, 1, 1)
		$HUD/WeaponSelected/Secondary.modulate = Color(1, 1, 1, 0.5)
		
		$HUD/WeaponSelected/Primary/Selector.color = Color(1, 1, 1, 1)
		$HUD/WeaponSelected/Secondary/Selector.color = Color(1, 1, 1, 0)
		
		weapon_position_z = -0.2
		weapon.mesh = rifle_model
		shoot_sound = rifle_shoot_sound
		singleshot = false
		$HUD/AmmoText.show()
		$HUD/DisplayAmmo.show()
		
		$Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/ShellSpawn.translation.z = -0.2
		$Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight.translation.z = -0.7
		$Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/MagazineSpawn.translation = Vector3(0, -0.11, -0.18)
	
	if weapon_selected == 2:
		$HUD/WeaponSelected/Primary.modulate = Color(1, 1, 1, 0.5)
		$HUD/WeaponSelected/Secondary.modulate = Color(1, 1, 1, 1)
		
		$HUD/WeaponSelected/Primary/Selector.color = Color(1, 1, 1, 0)
		$HUD/WeaponSelected/Secondary/Selector.color = Color(1, 1, 1, 1)
		
		weapon_position_z = -0.3
		weapon.mesh = pistol_model
		shoot_sound = pistol_shoot_sound
		singleshot = true
		$HUD/AmmoText.show()
		$HUD/DisplayAmmo.show()
		
		$Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/ShellSpawn.translation.z = -0.07
		$Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight.translation.z = -0.2
		$Torso/Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/MagazineSpawn.translation = Vector3(0, -0.06, -0.01)

func update_visual_ammo():
	# margin right -360 <> -91
	# spacing 269
	# 30 ammo = +8.96
	
	var step = 269.0 / max_ammo
	var current_position = -360 + (step * ammo)
	var color_step = (1.0 / max_ammo) * ammo
	
	$HUD/VisualAmmo.margin_right = current_position
	$HUD/VisualAmmo.modulate = Color(1, color_step, color_step)

func attack_animation():
	$MeleeTimer.start()
	
	$AttackTween.interpolate_property($Torso/Position3D/SwitchAndAttack, "translation", Vector3(), Vector3(0.015, -0.065, -0.04), 0.08, Tween.TRANS_SINE, Tween.EASE_IN)
	$AttackTween.interpolate_property($Torso/Position3D/SwitchAndAttack, "translation", Vector3(0.015, -0.065, -0.04), Vector3(0.04, -0.056, 0.03), 0.12, Tween.TRANS_SINE, Tween.EASE_OUT, 0.08)
	$AttackTween.interpolate_property($Torso/Position3D/SwitchAndAttack, "translation", Vector3(0.04, -0.056, 0.03), Vector3(0.08, 0.1, -0.38), 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	# Hit 0.35
	$AttackTween.interpolate_property($Torso/Position3D/SwitchAndAttack, "translation", Vector3(0.08, 0.1, -0.38), Vector3(0.15, -0.4, 0), 0.45, Tween.TRANS_SINE, Tween.EASE_IN, 0.35)
	$AttackTween.interpolate_property($Torso/Position3D/SwitchAndAttack, "translation", Vector3(0.15, -0.4, 0), Vector3(), 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.8)
	
	$AttackTween.interpolate_property($Torso/Position3D/SwitchAndAttack, "rotation_degrees", Vector3(), Vector3(20, 45, 15), 0.08, Tween.TRANS_SINE, Tween.EASE_IN)
	$AttackTween.interpolate_property($Torso/Position3D/SwitchAndAttack, "rotation_degrees", Vector3(20, 45, 15), Vector3(0, 90, 90), 0.12, Tween.TRANS_SINE, Tween.EASE_OUT, 0.08)
	$AttackTween.interpolate_property($Torso/Position3D/SwitchAndAttack, "rotation_degrees", Vector3(0, 90, 90), Vector3(-19.6, 130, 105), 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	# Hit
	$AttackTween.interpolate_property($Torso/Position3D/SwitchAndAttack, "rotation_degrees", Vector3(-19.6, 130, 105), Vector3(34.5, 80, 35), 0.45, Tween.TRANS_SINE, Tween.EASE_IN, 0.35)
	$AttackTween.interpolate_property($Torso/Position3D/SwitchAndAttack, "rotation_degrees", Vector3(34.5, 80, 35), Vector3(), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT, 0.8)

	$AttackTween.start()

func _on_RecoilTimer_timeout():
	$BulletSpread/RayCast.rotation_degrees = Vector3()

func update_ammo_HUD():
	$HUD/DisplayAmmo/AmmoText.text = str(ammo)
	$HUD/DisplayAmmo/ClipText.text = str(clip)

func _on_MeleeTimer_timeout():
	if $MeleeRayCast.is_colliding():
		spawn_impact($MeleeRayCast)
		play_sound(melee_hit_sound, -10, 0)

func _on_Button1_pressed():
	if weapon_selected != 1:
		weapon_selected = 1
		switch_weapon()

func _on_Button2_pressed():
	if weapon_selected != 2:
		weapon_selected = 2
		switch_weapon()

func _on_ReloadTween_tween_all_completed():
	update_ammo_HUD()
