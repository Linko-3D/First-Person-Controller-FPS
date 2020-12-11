extends Position3D

export (PackedScene) var object

var can_control = true

func _ready():
	yield(get_tree(), "idle_frame") 
	if get_tree().get_network_unique_id(): # If we play in multiplayer
		if not is_network_master(): # If we aren't this player in multiplayer
			can_control = false
		
func _input(event):
	if not can_control:
		return
	
	if Input.is_key_pressed(KEY_G) and $Timer.is_stopped():
		spawn_object()
		rpc("spawn_object_remotely")
		$Timer.start()

func spawn_object():
	var object_instance = object.instance()
	object_instance.global_transform = global_transform
	object_instance.linear_velocity = global_transform.basis.z * -15
	get_tree().get_root().add_child(object_instance)

remote func spawn_object_remotely():
	spawn_object()
