extends SpotLight

export (Resource) var light_on_sound
export (Resource) var light_off_sound

var sound = light_on_sound

func _ready():
	hide()

func _input(event):
	if Input.is_key_pressed(KEY_F) and $Timer.is_stopped():
		visible = !visible
		$Timer.start()
		play_sound()

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
