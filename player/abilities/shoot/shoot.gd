extends Position3D

var ammo = 30

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT) >= 0.6:
		if $FireRateTimer.is_stopped():
			$FireRateTimer.start()

			$TriggerSound.pitch_scale = randf_range(0.95, 1.05)
			$TriggerSound.play()
			
			if ammo > 0:
				ammo -= 1
				print(ammo)
				$AmmoLeft.size.x = ammo

				$ShootSound.pitch_scale = randf_range(0.95, 1.05)
				$ShootSound.play()

				$BangSound.pitch_scale = randf_range(0.95, 1.05)
				$BangSound.play()

				$ShellSound.pitch_scale = randf_range(0.95, 1.05)
				$ShellSound.play()

	if Input.is_key_pressed(KEY_R) or Input.is_joy_button_pressed(0, JOY_BUTTON_X):
		ammo = 30
		print(ammo)
		$AmmoLeft.size.x = ammo
