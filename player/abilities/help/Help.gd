extends Control

export var tutorial_enabled = true

func _ready():
	set_process(tutorial_enabled)
	visible = tutorial_enabled

func _process(delta):
	if Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_XBOX_A):
		hide()
	
	if Input.is_key_pressed(KEY_F1) or Input.is_joy_button_pressed(0, JOY_SELECT):
		show()
	
	if not $Tween.is_active():
		$Tween.interpolate_property($Control/Label, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.5), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Control/Label, "modulate", Color(1, 1, 1, 0.5), Color(1, 1, 1, 1), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
		$Tween.start()
