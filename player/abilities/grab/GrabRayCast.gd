# Grab ability with E (works on RigidBodies only)

extends RayCast

export var mass_limit = 30

var object_grabbed = null
var grabbed = false

func _physics_process(delta):
	if Input.is_key_pressed(KEY_E) and $Timer.is_stopped():
		$Timer.start()
		if object_grabbed:
			object_grabbed = false
		else:
			if is_colliding():
				if get_collider() is RigidBody and get_collider().mass <= mass_limit:
					object_grabbed = get_collider()
					grabbed = true

	if object_grabbed:
		object_grabbed.global_transform = $GrabbingPosition.global_transform
		object_grabbed.set_mode(0) # Set the mode to RigidBody to reset the gravity
