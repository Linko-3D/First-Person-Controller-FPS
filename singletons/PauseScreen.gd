extends Control

# Singleton

var can_press = true

func _ready():
	pause_mode = PAUSE_MODE_PROCESS # This script can't get paused
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()

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

func _on_Timer_timeout():
	if $Label.text == "GAME PAUSED":
		$Label.text = "GAME PAUSED_"
	else:
		$Label.text = "GAME PAUSED"
	
	$Timer.start()
