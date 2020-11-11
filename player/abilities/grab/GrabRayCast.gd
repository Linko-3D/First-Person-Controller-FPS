# Grab ability with E (works on RigidBodies only), throw with the left click

extends RayCast

export var mass_limit = 50
export var push_force = 5

var object_grabbed = null

func _physics_process(delta):


	if object_grabbed:
		object_grabbed.global_transform = $GrabbingPosition.global_transform
		
func _input(event):
	if Input.is_key_pressed(KEY_E) and $Timer.is_stopped():
		$Timer.start()
		if object_grabbed:
			object_grabbed.set_mode(0) # Set the mode to RigidBody to reset the gravity
			object_grabbed = false
		else:
			if is_colliding():
				if get_collider() is RigidBody and get_collider().mass <= mass_limit:
					object_grabbed = get_collider()
					
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			if object_grabbed:
				object_grabbed.set_mode(0)
				object_grabbed.linear_velocity = global_transform.basis.z * -push_force
				object_grabbed = false
