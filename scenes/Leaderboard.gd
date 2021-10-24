extends Control

func _ready():
	hide()

func _input(event):
	if Input.is_key_pressed(KEY_TAB):
		show()
	else:
		hide()
