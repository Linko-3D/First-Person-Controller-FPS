# Spawn an object with middle click and snaps his position in a grid

extends RayCast

export (PackedScene) var object

var snap = Vector3()
var distance = 0

var can_control = true

func _ready():
	yield(get_tree(), "idle_frame") 
	if get_tree().get_network_unique_id(): # If we play in multiplayer
		if not is_network_master(): # If we aren't this player in multiplayer
			can_control = false
	
func _input(event):
	if not can_control:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE and event.is_pressed():
			if is_colliding() and object:
				distance = global_transform.origin - get_collision_point()
				if distance.length() >= 2.5:
					calculate_position()
					spawn_object()
					rpc("spawn_object_remotely", snap)

func calculate_position():
	# The snapping adds the normal divided by 10 to avoid spawning an object inside another
	snap.x = stepify(get_collision_point().x + get_collision_normal().x / 10, 1)
	snap.y = stepify(get_collision_point().y + get_collision_normal().y / 10, 1)
	snap.z = stepify(get_collision_point().z + get_collision_normal().z / 10, 1)
	
func spawn_object():
	var object_instance = object.instance()
	get_tree().get_root().add_child(object_instance)
	
	object_instance.global_transform.origin = snap

remote func spawn_object_remotely(snap_value):
	snap = snap_value
	spawn_object()
