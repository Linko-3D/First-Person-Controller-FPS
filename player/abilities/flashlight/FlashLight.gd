extends Spatial

export (Resource) var light_on_sound
export (Resource) var light_off_sound

var sound = light_on_sound

var can_use = true

var weapon_sway = 5
var mouse_relative_x = 0
var mouse_relative_y = 0

func _ready():
	hide()

func _input(event):
#	Getting the mouse movement for the flashlight sway in the physics process
	if event is InputEventMouseMotion:
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
		
	if Input.is_key_pressed(KEY_F) or Input.is_joy_button_pressed(0, JOY_L):
		if can_use:
			visible = !visible
			play_sound()
			can_use = false
	
	if not Input.is_key_pressed(KEY_F) and not Input.is_joy_button_pressed(0, JOY_L):
		can_use = true

func _physics_process(delta):
	#	Weapon sway
	$SpotLight.rotation_degrees.y = lerp($SpotLight.rotation_degrees.y, mouse_relative_x / 10, weapon_sway * delta)
	$SpotLight.rotation_degrees.x = lerp($SpotLight.rotation_degrees.x, -mouse_relative_y / 5, weapon_sway * delta)

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
	
