extends RigidBody

func _ready():
	var material = $Pebble.get_active_material(0)
	$ColorTween.interpolate_property(material, "emission", Color(1, 1, 1), Color(1, 0.6, 0), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.interpolate_property(material, "emission_energy", 5, 0, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.interpolate_property(material, "albedo_color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 4)
	$ColorTween.start()
	
	randomize()
	var size_x = rand_range(0.8, 1.2)
	var size_y = rand_range(0.8, 1.2)
	var size_z = rand_range(0.8, 1.2)
	$Pebble.scale = Vector3(size_x, size_y, size_z)
	$CollisionShape.scale = Vector3(size_x, size_y, size_z)

func _on_ColorTween_tween_all_completed():
	queue_free()
