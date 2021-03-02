extends SpotLight

export (Resource) var light_on_sound
export (Resource) var light_off_sound

var sound = light_on_sound

var can_use = true

func _ready():
	hide()

func _input(event):
	if Input.is_key_pressed(KEY_F) or Input.is_joy_button_pressed(0, JOY_L):
		if can_use:
			visible = !visible
			play_sound()
			can_use = false
	
	if not Input.is_key_pressed(KEY_F) and not Input.is_joy_button_pressed(0, JOY_L):
		can_use = true

func play_sound():
	var audio_node = AudioStreamPlayer.new()
	if visible:
		audio_node.stream = light_on_sound
	else:
		audio_node.stream = light_off_sound
	add_child(audio_node)
	audio_node.play()
	yield(get_tree().create_timer(1), "timeout")
	audio_node.queue_free()
