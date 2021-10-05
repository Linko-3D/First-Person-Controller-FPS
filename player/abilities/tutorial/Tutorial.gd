extends Control

func _process(delta):
	if Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_XBOX_A):
		queue_free()
	
	if not $Tween.is_active():
		$Tween.interpolate_property($Label, "modulate", Color(0.85, 0.6, 0.1, 1), Color(0.85, 0.6, 0.1, 0.5), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Label, "modulate", Color(0.85, 0.6, 0.1, 0.5), Color(0.85, 0.6, 0.1, 1), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
		$Tween.start()
