extends RayCast3D

var object_grabbed = null
var mass_limit = 50

func _process(delta):
	if get_collider() is RigidDynamicBody3D and not get_collider() is VehicleBody3D and get_collider().mass <= mass_limit:
		print("can grab")
