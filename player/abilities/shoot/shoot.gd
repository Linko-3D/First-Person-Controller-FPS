extends Position3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT) >= 0.6:
		if $FireRateTimer.is_stopped():
			print("shoot")
			$FireRateTimer.start()
			
			$TriggerSound.pitch_scale = randf_range(0.95, 1.05)
			$TriggerSound.play()
			
			$ShootSound.pitch_scale = randf_range(0.95, 1.05)
			$ShootSound.play()

			$BangSound.pitch_scale = randf_range(0.95, 1.05)
			$BangSound.play()
			
			$ShellSound.pitch_scale = randf_range(0.95, 1.05)
			$ShellSound.play()
