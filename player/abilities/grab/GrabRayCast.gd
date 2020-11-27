# Grab ability with E (works on rigid bodies only), throw it with the left click

extends RayCast

var mass_limit = 50
var throw_force = 5

var object_grabbed = null

onready var ShootRayCast = get_tree().get_root().find_node("ShootRayCast", true, false)

func _physics_process(delta):
	if object_grabbed:
		object_grabbed.global_transform = $GrabbingPosition.global_transform
		if ShootRayCast:
			ShootRayCast.can_shoot = false
	else:
		if ShootRayCast:
			ShootRayCast.can_shoot = true
	
func _input(event):
	if Input.is_key_pressed(KEY_E) and $Timer.is_stopped():
		$Timer.start()
		if not object_grabbed: # Grab the object
			if is_colliding():
				if get_collider() is RigidBody and get_collider().mass <= mass_limit:
					object_grabbed = get_collider()
		else: # Drop the object
			object_grabbed.set_mode(0) # Set the mode to RigidBody to reset the gravity
			object_grabbed = false
					
	if event is InputEventMouseButton: # If we grab and object and press the left click, we throw it
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			if object_grabbed:
				object_grabbed.set_mode(0)
				object_grabbed.linear_velocity = global_transform.basis.z * -throw_force
				object_grabbed = false
