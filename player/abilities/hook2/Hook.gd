extends RayCast

export (Resource) var hook_model
onready var hook_instance = hook_model.instance()

func _ready():
	get_tree().get_root().add_child(hook_instance)
	hook_instance.global_transform.origin = $Position3D.global_transform.origin

func _process(delta):
	hook_instance.global_transform.origin = $Position3D.global_transform.origin
	print(hook_instance)
	
	
	
	$LookAt.look_at(get_collision_point(), Vector3.UP)
	
	if not is_colliding():
		$LookAt.rotation_degrees = Vector3()
	
	$Position3D.rotation_degrees = lerp($Position3D.rotation_degrees, $LookAt.rotation_degrees, 10 * delta)
	
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		hook_instance.linear_velocity = global_transform.basis.z * -20
		pass
