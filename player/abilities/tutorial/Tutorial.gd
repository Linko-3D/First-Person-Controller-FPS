extends Control

func _process(delta):
	if Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_XBOX_A):
		queue_free()
	
	if not $Tween.is_active():
		$Tween.interpolate_property($Label, "modulate", Color(1, 0.8, 0.2, 1), Color(1, 0.8, 0.2, 0.5), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Label, "modulate", Color(1, 0.8, 0.2, 0.5), Color(1, 0.8, 0.2, 1), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
		$Tween.start()
