extends SpotLight

export (Resource) var light_on_sound
export (Resource) var light_off_sound

var can_use = true

func _ready():
	hide()

func _input(event):
	if Input.is_key_pressed(KEY_F) or Input.is_joy_button_pressed(0, JOY_L):
		if can_use:
			can_use = false
			visible = !visible
			if visible:
				play_sound(light_on_sound, -10)
			else:
				play_sound(light_off_sound, -10)
	else:
		can_use = true

func play_sound(sound, volume):
	var audio_node = AudioStreamPlayer.new()
	add_child(audio_node)
	audio_node.stream = sound
	audio_node.volume_db = volume
	audio_node.pitch_scale = rand_range(0.95, 1.05)
	audio_node.play()
	yield(audio_node, "finished")
	audio_node.queue_free()
