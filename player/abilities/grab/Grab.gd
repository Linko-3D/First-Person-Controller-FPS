# Grab ability with E (works on rigid bodies only), throw it with the left click

extends RayCast

var mass_limit = 50
var throw_force = 5

var object_grabbed = null

func _physics_process(delta):
	$GrabText.margin_top = get_viewport().size.y / 2 * -1
	
	if is_colliding() and not object_grabbed:
		$GrabText.show()
	else:
		$GrabText.hide()
	
	if object_grabbed:
		object_grabbed.global_transform = $GrabPosition.global_transform
		object_grabbed.rotation.x = 0

	if Input.is_key_pressed(KEY_E) or Input.is_joy_button_pressed(0, JOY_XBOX_Y):
		if $Timer.is_stopped():
			$Timer.start()
			if not object_grabbed: # Grab the object
				if is_colliding():
					if get_collider() is RigidBody and get_collider().mass <= mass_limit:
						object_grabbed = get_collider()
			else: # Drop the object
				object_grabbed.set_mode(0) # Set the mode to reset the gravity
				object_grabbed = false

	if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.get_joy_axis(0, 7) >= 0.5:
		if object_grabbed:
			object_grabbed.set_mode(0)
			object_grabbed.linear_velocity = global_transform.basis.z * -throw_force
			object_grabbed = false
