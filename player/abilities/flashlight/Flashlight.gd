extends Position3D

export (Resource) var light_on_sound
export (Resource) var light_off_sound

var can_use = true

var sway_amount = 5
var mouse_relative_x = 0
var mouse_relative_y = 0

func _ready():
	hide()

func _input(event):
	if Input.is_key_pressed(KEY_F) or Input.is_joy_button_pressed(0, JOY_L):
		if can_use:
			can_use = false
			visible = !visible
			if visible:
				play_sound(light_on_sound, -25)
			else:
				play_sound(light_off_sound, -25)
	else:
		can_use = true
		
	#	Getting the mouse movement for the weapon sway in the physics process
	if event is InputEventMouseMotion:
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

func _process(delta):
	#	Weapon sway
	$SpotLight.rotation_degrees.y = lerp($SpotLight.rotation_degrees.y, -mouse_relative_x / 10, sway_amount * delta)
	$SpotLight.rotation_degrees.x = lerp($SpotLight.rotation_degrees.x, -mouse_relative_y / 5, sway_amount * delta)

func play_sound(sound, volume):
	var audio_node = AudioStreamPlayer.new()
	add_child(audio_node)
	audio_node.stream = sound
	audio_node.volume_db = volume
	audio_node.pitch_scale = rand_range(0.95, 1.05)
	audio_node.play()
	yield(audio_node, "finished")
	audio_node.queue_free()
