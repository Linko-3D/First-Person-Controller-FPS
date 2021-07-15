extends Spatial

export (Resource) var rifle_model
export (Resource) var pistol_model
export (Resource) var knife_model

export (PackedScene) var impact
export (PackedScene) var shell
export (PackedScene) var magazine

export (Resource) var rifle_shoot_sound
export (Resource) var pistol_shoot_sound
export (Resource) var reload_sound
export (Resource) var empty_sound

onready var shoot_sound = rifle_shoot_sound

var weapon1_ammo = 30
var weapon1_clip = 90

var weapon2_ammo = 20
var weapon2_clip = 120

var max_ammo = weapon1_ammo
var ammo = max_ammo
var clip = weapon1_clip

var bullet_spread = 30

var shooting_sound_echo = true

var weapon_sway_amount = 5
var mouse_relative_x = 0
var mouse_relative_y = 0

var singleshot = false
var can_shoot = true
var weapon_selected = 1
var weapon_position = -0.2

var can_switch_joy_dpad = true

onready var weapon = $Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon

onready var player = get_tree().get_root().find_node("Player", true, false)
onready var camera = player.get_node("Head/Camera")

func _ready():
	$HUD/DisplayAmmo/AmmoText.text = str(ammo)
	$HUD/DisplayAmmo/ClipText.text = str(clip)

func _input(event):
#	Getting the mouse movement for the weapon sway in the physics process
	if event is InputEventMouseMotion:
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
		
		
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_DOWN:
				if not $ReloadTween.is_active():
					weapon_selected += 1
					switch_animation()
			if event.button_index == BUTTON_WHEEL_UP:
				if not $ReloadTween.is_active():
					weapon_selected -= 1
					switch_animation()

func _process(delta):
	if not $ReloadTween.is_active():
		if Input.is_key_pressed(KEY_1):
			if weapon_selected != 1:
				weapon_selected = 1
				switch_animation()
			
		if Input.is_key_pressed(KEY_2):
			if weapon_selected != 2:
				weapon_selected = 2
				switch_animation()
				
		if Input.is_key_pressed(KEY_3):
			if weapon_selected != 3:
				weapon_selected = 3
				switch_animation()
				
		if Input.is_key_pressed(KEY_4):
			if weapon_selected != 4:
				weapon_selected = 4
				switch_animation()
		
		if can_switch_joy_dpad:
			if Input.is_joy_button_pressed(0, JOY_DPAD_RIGHT) or Input.is_joy_button_pressed(0, JOY_DPAD_DOWN):
				weapon_selected += 1
				switch_animation()
			if Input.is_joy_button_pressed(0, JOY_DPAD_UP) or Input.is_joy_button_pressed(0, JOY_DPAD_LEFT):
				weapon_selected -= 1
				switch_animation()
		
		if Input.is_joy_button_pressed(0, JOY_DPAD_LEFT) or Input.is_joy_button_pressed(0, JOY_DPAD_RIGHT) or Input.is_joy_button_pressed(0, JOY_DPAD_UP) or Input.is_joy_button_pressed(0, JOY_DPAD_DOWN):
			can_switch_joy_dpad = false
		else:
			can_switch_joy_dpad = true
		

	
	
	if $BulletSpread/RayCast.is_colliding():
		$Position3D/LookAt.look_at($BulletSpread/RayCast.get_collision_point(), Vector3.UP)
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp.rotation_degrees = lerp($Position3D/SwitchAndAttack/Bobbing/LookAtLerp.rotation_degrees, $Position3D/LookAt.rotation_degrees, 10 * delta)
	else:
		$Position3D/LookAt.rotation_degrees = Vector3()
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp.rotation_degrees = lerp($Position3D/SwitchAndAttack/Bobbing/LookAtLerp.rotation_degrees, $Position3D/LookAt.rotation_degrees, 10 * delta)
	$Position3D/SwitchAndAttack/Bobbing/LookAtLerp.rotation_degrees.z = 0
#	Weapon sway
	$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.z = lerp($Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.z, -mouse_relative_x / 10, weapon_sway_amount * delta)
	$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.y = lerp($Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.y, mouse_relative_x / 20, weapon_sway_amount * delta)
	$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.x = lerp($Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway.rotation_degrees.x, -mouse_relative_y / 10, weapon_sway_amount * delta)
	
	var weapon_movement = clamp(player.player_speed * 0.003, 0, 0.018)
	
	
	if round(player.player_speed) == 0:
		$Position3D.translation.y = lerp($Position3D.translation.y, -0.1, 5 * delta)
		$Position3D.translation.z = lerp($Position3D.translation.z, weapon_position, 5 * delta)
	else:
		$Position3D.translation.y = lerp($Position3D.translation.y, -0.1 + -weapon_movement, 5 * delta)
		$Position3D.translation.z = lerp($Position3D.translation.z, weapon_position + weapon_movement, 5 * delta)
		
		if player.is_on_floor() and player.player_speed >= 2:
			weapon_bobbing_animation()
	
	if $ReloadTween.is_active() or $SwitchAndAttackTween.is_active():
		return
		
	if Input.is_key_pressed(KEY_V) or Input.is_mouse_button_pressed(BUTTON_MIDDLE) or Input.is_joy_button_pressed(0, JOY_R3):
		attack_animation()
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.get_joy_axis(0, 7) >= 0.5:
		if $FireRateTimer.is_stopped() and can_shoot and weapon_selected < 3:
			if ammo > 0:
				if Input.get_joy_axis(0, 7) >= 0.5:
						Input.start_joy_vibration(0, 0, 0.2, 0.1)
				shoot()
				$FireRateTimer.start()
			else:
				play_sound(empty_sound, 0, 0)
				$FireRateTimer.start()
				ammunition_text_blink()
	
	if singleshot:
		if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.get_joy_axis(0, 7) >= 0.5:
			can_shoot = false
		else:
			can_shoot = true
	
	if (Input.is_key_pressed(KEY_R) or Input.is_joy_button_pressed(0, JOY_XBOX_X)):
		if ammo != max_ammo and clip > 0 and weapon_selected < 3:
			$ReloadTween.interpolate_property(weapon, "rotation_degrees:x", 0, 360, 1, Tween.TRANS_BACK, Tween.EASE_IN_OUT, 0)
			$ReloadTween.start()
			play_sound(reload_sound, -5, 0)
			$SpawnMagazineTimer.start()
		
func shoot():
	# Adding echo
	if shooting_sound_echo:
		var delay = 0
		var dB = -5
		for i in 5: # Add an echo effect when shooting by delaying the sound and reducing the volume
			play_sound(shoot_sound, dB, delay)
			delay += 0.5
			dB -= 15
	
	shoot_animation()
	spawn_impact()
	spawn_shell()
	
	# Calculate bullet spread amount
	var recoil = 0
	recoil = $RecoilTimer.time_left * bullet_spread * (1 + player.player_speed / 10)
	
	$BulletSpread.rotation_degrees.z = rand_range(0, 360)
	$BulletSpread/RayCast.rotation_degrees.y = rand_range(-recoil, recoil)
	
	$RecoilTimer.start()
	
	ammo -= 1
	$HUD/DisplayAmmo/AmmoText.text = str(ammo)
	if ammo <= max_ammo / 6:
		ammunition_text_blink()

func spawn_shell():
	var shell_instance = shell.instance()
	get_tree().get_root().add_child(shell_instance)
	shell_instance.global_transform = $Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/ShellSpawn.global_transform
	shell_instance.linear_velocity = $Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/ShellSpawn.global_transform.basis.x * 2.5

func spawn_magazine():
	var magazine_instance = magazine.instance()
	get_tree().get_root().add_child(magazine_instance)
	magazine_instance.global_transform = $Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/MagazineSpawn.global_transform
	magazine_instance.linear_velocity = $Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/MagazineSpawn.global_transform.basis.z * -3

func spawn_impact():
	if not $BulletSpread/RayCast.is_colliding():
		return
	
	var impact_instance = impact.instance()
	get_tree().get_root().add_child(impact_instance)
	
	impact_instance.global_transform.origin = $BulletSpread/RayCast.get_collision_point()
	impact_instance.look_at($BulletSpread/RayCast.get_collision_point() - $BulletSpread/RayCast.get_collision_normal(), Vector3.UP)
	
	if $BulletSpread/RayCast.get_collider() is RigidBody:
		$BulletSpread/RayCast.get_collider().apply_central_impulse(-$BulletSpread/RayCast.get_collision_normal() * 100)
		impact_instance.hide_bullet()

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
	
	$HUD/DisplayAmmo/AmmoText.text = str(ammo)
	$HUD/DisplayAmmo/ClipText.text = str(clip)

func shoot_animation():
	randomize()
	var value = rand_range(0.8, 1)
	$ShootTween.interpolate_property($Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight, "light_energy", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property($Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight, "light_energy", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	
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
	
	value = rand_range(0.5, 1.5)
	$ShootTween.interpolate_property(camera, "rotation_degrees:x", 0, 1, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property(camera, "rotation_degrees:x", 1, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	value = rand_range(-1, 1)
	$ShootTween.interpolate_property(camera, "rotation_degrees:y", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ShootTween.interpolate_property(camera, "rotation_degrees:y", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	$ShootTween.start()

func attack_animation():
	$SwitchAndAttackTween.interpolate_property($Position3D/SwitchAndAttack, "translation", Vector3(), Vector3(0.015, -0.065, -0.04), 0.08, Tween.TRANS_SINE, Tween.EASE_IN)
	$SwitchAndAttackTween.interpolate_property($Position3D/SwitchAndAttack, "translation", Vector3(0.015, -0.065, -0.04), Vector3(0.04, -0.056, 0.03), 0.12, Tween.TRANS_SINE, Tween.EASE_OUT, 0.08)
	# Hit
	$SwitchAndAttackTween.interpolate_property($Position3D/SwitchAndAttack, "translation", Vector3(0.04, -0.056, 0.03), Vector3(0.08, 0.1, -0.38), 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	$SwitchAndAttackTween.interpolate_property($Position3D/SwitchAndAttack, "translation", Vector3(0.08, 0.1, -0.38), Vector3(0.15, -0.4, 0), 0.45, Tween.TRANS_SINE, Tween.EASE_IN, 0.35)
	$SwitchAndAttackTween.interpolate_property($Position3D/SwitchAndAttack, "translation", Vector3(0.15, -0.4, 0), Vector3(), 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.8)
	
	$SwitchAndAttackTween.interpolate_property($Position3D/SwitchAndAttack, "rotation_degrees", Vector3(), Vector3(20, 45, 15), 0.08, Tween.TRANS_SINE, Tween.EASE_IN)
	$SwitchAndAttackTween.interpolate_property($Position3D/SwitchAndAttack, "rotation_degrees", Vector3(20, 45, 15), Vector3(0, 90, 90), 0.12, Tween.TRANS_SINE, Tween.EASE_OUT, 0.08)
	# Hit
	$SwitchAndAttackTween.interpolate_property($Position3D/SwitchAndAttack, "rotation_degrees", Vector3(0, 90, 90), Vector3(-19.6, 130, 105), 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	$SwitchAndAttackTween.interpolate_property($Position3D/SwitchAndAttack, "rotation_degrees", Vector3(-19.6, 130, 105), Vector3(34.5, 80, 35), 0.45, Tween.TRANS_SINE, Tween.EASE_IN, 0.35)
	$SwitchAndAttackTween.interpolate_property($Position3D/SwitchAndAttack, "rotation_degrees", Vector3(34.5, 80, 35), Vector3(), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT, 0.8)

	$SwitchAndAttackTween.interpolate_property(camera, "rotation_degrees", Vector3(), Vector3(-2, -5, 0), 0.25, Tween.TRANS_SINE, Tween.EASE_IN)
	$SwitchAndAttackTween.interpolate_property(camera, "rotation_degrees", Vector3(-2, -5, 0), Vector3(2, 10, 0), 0.1, Tween.TRANS_SINE, Tween.EASE_OUT, 0.25)
	$SwitchAndAttackTween.interpolate_property(camera, "rotation_degrees", Vector3(2, 10, 0), Vector3(-2, -2, 0), 0.4, Tween.TRANS_SINE, Tween.EASE_IN, 0.35)
	$SwitchAndAttackTween.interpolate_property(camera, "rotation_degrees", Vector3(-2, -2, 0), Vector3(0, 0, 0), 0.25, Tween.TRANS_SINE, Tween.EASE_OUT, 0.75)
	
	$SwitchAndAttackTween.start()

func weapon_bobbing_animation():
	var animation_speed = 1.0 / player.player_speed
	var animation_value = player.player_speed / 600 # 0.01
	
	if not $HBobbingTween.is_active():
		$HBobbingTween.interpolate_property($Position3D/SwitchAndAttack/Bobbing, "translation:x", 0, animation_value, animation_speed * 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$HBobbingTween.interpolate_property($Position3D/SwitchAndAttack/Bobbing, "translation:x", animation_value, 0, animation_speed * 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, animation_speed * 2)
		$HBobbingTween.start()
	
	if not $VBobbingTween.is_active():
		$VBobbingTween.interpolate_property($Position3D/SwitchAndAttack/Bobbing, "translation:y", 0, animation_value / 2, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$VBobbingTween.interpolate_property($Position3D/SwitchAndAttack/Bobbing, "translation:y", animation_value / 2, 0, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT, animation_speed)
		
		$VBobbingTween.interpolate_property($Position3D/SwitchAndAttack/Bobbing, "translation:z", 0, -animation_value / 10, animation_speed / 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$VBobbingTween.interpolate_property($Position3D/SwitchAndAttack/Bobbing, "translation:z", -animation_value / 10, 0, animation_speed / 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, animation_speed / 2)
		$VBobbingTween.interpolate_property($Position3D/SwitchAndAttack/Bobbing, "translation:z", 0, -animation_value / 10, animation_speed / 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, (animation_speed / 2) * 2)
		$VBobbingTween.interpolate_property($Position3D/SwitchAndAttack/Bobbing, "translation:z", -animation_value / 10, 0, animation_speed / 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, (animation_speed / 2) * 3)
		$VBobbingTween.start()

func switch_animation():
	background_color_animation()
#	var flash_color = Color(1, 0.95, 0.1, 0.5)
	
	var background_color_active = Color(0, 0, 0, 0.5)
	var background_color_inactive = Color(0, 0, 0, 0)
	
	if weapon_selected > 4:
		weapon_selected = 1
	if weapon_selected < 1:
		weapon_selected = 4
	
	$SwitchAndAttackTween.interpolate_property($Position3D/SwitchAndAttack, "translation", Vector3(0, -0.25, -0.1), Vector3(), 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$SwitchAndAttackTween.interpolate_property($Position3D/SwitchAndAttack, "rotation_degrees", Vector3(-30, 20, 10), Vector3(), 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$SwitchAndAttackTween.start()
	
	if weapon_selected == 1:
		$HUD/BackgroundColor/ColorRect1.color = background_color_active
		$HUD/BackgroundColor/ColorRect2.color = background_color_inactive
		$HUD/BackgroundColor/ColorRect3.color = background_color_inactive
		$HUD/BackgroundColor/ColorRect4.color = background_color_inactive
		
		weapon_position = -0.2
		weapon.mesh = rifle_model
		shoot_sound = rifle_shoot_sound
		singleshot = false
		$HUD/AmmoText.show()
		$HUD/DisplayAmmo.show()
		$HUD/AmmoBackgroundColor.show()
		
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/ShellSpawn.translation.z = -0.2
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight.translation.z = -0.7
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/MagazineSpawn.translation = Vector3(0, -0.11, -0.18)
	
	if weapon_selected == 2:
		$HUD/BackgroundColor/ColorRect1.color = background_color_inactive
		$HUD/BackgroundColor/ColorRect2.color = background_color_active
		$HUD/BackgroundColor/ColorRect3.color = background_color_inactive
		$HUD/BackgroundColor/ColorRect4.color = background_color_inactive
		
		weapon_position = -0.3
		weapon.mesh = pistol_model
		shoot_sound = pistol_shoot_sound
		singleshot = true
		$HUD/AmmoText.show()
		$HUD/DisplayAmmo.show()
		$HUD/AmmoBackgroundColor.show()
		
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/ShellSpawn.translation.z = -0.07
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight.translation.z = -0.2
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/MagazineSpawn.translation = Vector3(0, -0.06, -0.01)
		
	if weapon_selected == 3:
		$HUD/BackgroundColor/ColorRect1.color = background_color_inactive
		$HUD/BackgroundColor/ColorRect2.color = background_color_inactive
		$HUD/BackgroundColor/ColorRect3.color = background_color_active
		$HUD/BackgroundColor/ColorRect4.color = background_color_inactive
		
		weapon_position = -0.4
		weapon.mesh = knife_model
		$HUD/AmmoText.hide()
		$HUD/DisplayAmmo.hide()
		$HUD/AmmoBackgroundColor.hide()
		
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/ShellSpawn.translation.z = -0.07
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight.translation.z = -0.2
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/MagazineSpawn.translation = Vector3(0, -0.06, -0.01)

	if weapon_selected == 4:
		$HUD/BackgroundColor/ColorRect1.color = background_color_inactive
		$HUD/BackgroundColor/ColorRect2.color = background_color_inactive
		$HUD/BackgroundColor/ColorRect3.color = background_color_inactive
		$HUD/BackgroundColor/ColorRect4.color = background_color_active
		
		weapon_position = -0.4
		weapon.mesh = knife_model
		$HUD/AmmoText.show()
		$HUD/DisplayAmmo.show()
		$HUD/AmmoBackgroundColor.show()
		
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/ShellSpawn.translation.z = -0.07
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/Weapon/OmniLight.translation.z = -0.2
		$Position3D/SwitchAndAttack/Bobbing/LookAtLerp/Sway/MagazineSpawn.translation = Vector3(0, -0.06, -0.01)

func _on_RecoilTimer_timeout():
	$BulletSpread/RayCast.rotation_degrees = Vector3()

func _on_SpawnMagazineTimer_timeout():
	spawn_magazine()

func _on_ReloadTween_tween_all_completed():
	calculate_ammo()
	background_color_animation()


func background_color_animation():
	var animation_speed = 0.1
	
	$InterfaceTween.interpolate_property($HUD/AmmoText, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), animation_speed)
	$InterfaceTween.interpolate_property($HUD/DisplayAmmo/AmmoText, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), animation_speed)
	$InterfaceTween.interpolate_property($HUD/DisplayAmmo/Slash, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), animation_speed)
	$InterfaceTween.interpolate_property($HUD/DisplayAmmo/ClipText, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), animation_speed)
	$InterfaceTween.start()

func ammunition_text_blink():
	var animation_speed = 0.1
	
	if not $InterfaceTween.is_active():
		$InterfaceTween.interpolate_property($HUD/DisplayAmmo/AmmoText, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), animation_speed, 0, 2)
		$InterfaceTween.interpolate_property($HUD/DisplayAmmo/AmmoText, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), animation_speed, 0, 2, animation_speed)
		$InterfaceTween.interpolate_property($HUD/DisplayAmmo/AmmoText, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), animation_speed, 0, 2, animation_speed * 2)
		$InterfaceTween.interpolate_property($HUD/DisplayAmmo/AmmoText, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), animation_speed, 0, 2, animation_speed * 3)
		$InterfaceTween.start()
