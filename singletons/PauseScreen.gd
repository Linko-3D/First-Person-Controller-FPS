extends Control

# Singleton

var can_press = true

func _ready():
	pause_mode = PAUSE_MODE_PROCESS # This script can't get paused
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()
	
	$Label.margin_top = get_viewport().size.y / 4
	get_tree().connect("screen_resized", self, "_on_screen_resized")

func _process(delta):
	if not $Tween.is_active():
		$Tween.interpolate_property($Label, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 1), 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Label, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1)
		$Tween.interpolate_property($Label, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.25)
		$Tween.start()

func _input(event):
	if not Input.is_key_pressed(KEY_ESCAPE) and not Input.is_joy_button_pressed(0, JOY_START):
		can_press = true
	
	if can_press:
		if Input.is_key_pressed(KEY_ESCAPE) or Input.is_joy_button_pressed(0, JOY_START):
			can_press = false
			if get_tree().paused:
				get_tree().quit()
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			show()
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.is_joy_button_pressed(0, JOY_XBOX_A):
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hide()

func _on_screen_resized():
	$Label.margin_top = get_viewport().size.y / 4
