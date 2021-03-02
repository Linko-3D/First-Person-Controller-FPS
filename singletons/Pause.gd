# Singleton

extends Node

var can_press = true

func _ready():
	pause_mode = PAUSE_MODE_PROCESS # This script can't get paused
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if not Input.is_key_pressed(KEY_ESCAPE):
		can_press = true
	
	if can_press:
		if Input.is_key_pressed(KEY_ESCAPE):
			can_press = false
			if get_tree().paused:
				get_tree().quit()
			
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
