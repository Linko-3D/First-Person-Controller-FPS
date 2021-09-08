extends RayCast

export (PackedScene) var dot

onready var dot_instance = dot.instance()

var distance = 0

func _ready():
	yield(get_tree(), "idle_frame")
	
	if visible:
		get_tree().get_root().add_child(dot_instance)
	else:
		set_process(false)

func _process(delta):
	dot_instance.hide()
	
	if is_colliding():
		dot_instance.global_transform.origin = get_collision_point()
		dot_instance.show()
		distance = global_transform.origin - get_collision_point()
		distance = distance.length()
	else:
		distance = 1000
	$MeshInstance.mesh.height = distance
	$MeshInstance.translation.z = -distance / 2
