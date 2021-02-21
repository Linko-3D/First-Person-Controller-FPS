extends Position3D

export (PackedScene) var object

var force = 20
onready var grab = get_tree().get_root().find_node("Grab", true, false)

func _input(event):
	if grab:
		if grab.object_grabbed:
			return
	
	if Input.is_key_pressed(KEY_G) or Input.is_joy_button_pressed(0, JOY_R):
		if $Timer.is_stopped():
			spawn_object()
			$Timer.start()

func spawn_object():
	var object_instance = object.instance()
	object_instance.global_transform = $Position3D.global_transform
	object_instance.linear_velocity =global_transform.basis.z * -force
	get_tree().get_root().add_child(object_instance)
