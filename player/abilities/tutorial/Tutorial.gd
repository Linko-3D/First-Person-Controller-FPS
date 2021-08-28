extends Control

func _process(delta):
	if Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_XBOX_A):
		queue_free()
	
	if not $Tween.is_active():
		$Tween.interpolate_property($Label, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 1), 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Label, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1)
		$Tween.interpolate_property($Label, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.25)
		$Tween.start()
