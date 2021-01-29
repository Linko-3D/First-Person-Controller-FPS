extends Position3D

export (PackedScene) var object

var force = 20

func _input(event):
	if Input.is_key_pressed(KEY_G) and $Timer.is_stopped():
		spawn_object()
		$Timer.start()

func spawn_object():
	var object_instance = object.instance()
	object_instance.global_transform = global_transform
	object_instance.linear_velocity = global_transform.basis.z * -force
	get_tree().get_root().add_child(object_instance)
