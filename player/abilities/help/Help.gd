extends Control

var can_use = true

func _ready():
	$DisplayHelpTween.interpolate_property($Control2/DisplayHelp, "margin_top", -80, 5, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT, 1)
	$DisplayHelpTween.interpolate_property($Control2/DisplayHelp, "margin_top", 5, -80, 0.5, Tween.TRANS_SINE, Tween.EASE_IN, 4)
	$DisplayHelpTween.start()
	$Control.hide()
	$Control/TitleLabel.margin_top = -80

func _process(delta):
	if Input.is_key_pressed(KEY_F1) or Input.is_joy_button_pressed(0, JOY_SELECT):
		if can_use:
			can_use = false
			$Control.visible = !$Control.visible
			$Control/TitleLabel.margin_top = -80
			$TitleTween.interpolate_property($Control/TitleLabel, "margin_top", -80, 5, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
			$TitleTween.start()
	else:
		can_use = true

#	if $Control.visible:
#		if Input.is_key_pressed(KEY_ENTER) or Input.is_joy_button_pressed(0, JOY_XBOX_A):
#			$Control.hide()
#			$Control/TitleLabel.margin_top = -80
#			$DisplayHelpTween.interpolate_property($DisplayHelp, "margin_top", -80, 5, 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
#			$DisplayHelpTween.interpolate_property($DisplayHelp, "margin_top", 5, -80, 0.5, Tween.TRANS_SINE, Tween.EASE_IN, 3)
#			$DisplayHelpTween.start()
#			$DisplayHelp.show()
#			$TitleTween.stop_all()
#
#	if not $Control.visible:
#		if Input.is_key_pressed(KEY_F1) or Input.is_joy_button_pressed(0, JOY_SELECT):
#			$TitleTween.interpolate_property($Control/TitleLabel, "margin_top", -80, 5, 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
#			$TitleTween.start()
#			$Control.show()
#			$DisplayHelpTween.stop_all()
#			$DisplayHelp.margin_top = -80
#			$DisplayHelp.hide()
#
	if not $PressKeyTween.is_active():
		$PressKeyTween.interpolate_property($Control/PressKeyLabel, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.5), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$PressKeyTween.interpolate_property($Control/PressKeyLabel, "modulate", Color(1, 1, 1, 0.5), Color(1, 1, 1, 1), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
		
		$PressKeyTween.interpolate_property($Control2/DisplayHelp, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.5), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$PressKeyTween.interpolate_property($Control2/DisplayHelp, "modulate", Color(1, 1, 1, 0.5), Color(1, 1, 1, 1), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
		
		
		$PressKeyTween.start()
