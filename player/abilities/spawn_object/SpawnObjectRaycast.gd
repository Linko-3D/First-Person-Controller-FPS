# Spawn an object with middle click

extends RayCast

export (PackedScene) var object

var snap = Vector3()
var distance = 0

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE and event.is_pressed():
			if is_colliding() and object:
				distance = global_transform.origin - get_collision_point()
				if distance.length() >= 2.5:
					var object_instance = object.instance()
					get_tree().get_root().add_child(object_instance)

					snap.x = stepify(get_collision_point().x + get_collision_normal().x / 10, 1)
					snap.y = stepify(get_collision_point().y + get_collision_normal().y / 10, 1)
					snap.z = stepify(get_collision_point().z + get_collision_normal().z / 10, 1)

					object_instance.global_transform.origin = snap
