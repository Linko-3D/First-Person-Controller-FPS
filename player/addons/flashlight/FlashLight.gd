extends SpotLight

export (Resource) var light_on_sound
export (Resource) var light_off_sound

var sound = light_on_sound

var can_control = true

func _ready():
	hide()
	
	yield(get_tree(), "idle_frame") 
	if get_tree().get_network_unique_id(): # If we play in multiplayer
		if not is_network_master(): # If we aren't this player in multiplayer
			can_control = false

func _input(event):
	if not can_control:
		return
	
	if Input.is_key_pressed(KEY_F) and $Timer.is_stopped():
		visible = !visible
		rpc("visibility", visible)
		rpc("sound")
		$Timer.start()
		play_sound()

func play_sound():
	var audio_node = AudioStreamPlayer3D.new()
	audio_node.unit_size = 10
	if visible:
		audio_node.stream = light_on_sound
	else:
		audio_node.stream = light_off_sound
	add_child(audio_node)
	audio_node.play()
	yield(get_tree().create_timer(1), "timeout")
	audio_node.queue_free()

remote func visibility(data):
	visible = data

remote func sound():
	play_sound()
