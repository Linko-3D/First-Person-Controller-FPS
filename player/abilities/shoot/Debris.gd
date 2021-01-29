extends RigidBody

func _ready():
	var material = SpatialMaterial.new()
	material.albedo_color = Color(0.75, 0.62, 0.38)
	material.emission = Color(0.92, 0.91, 0.90)
	material.emission_energy = 0.5
	material.emission_enabled = true
	$MeshInstance.set_surface_material(0, material)
	$MeshInstance.scale = Vector3(1.5, 1, 1.5)
	
	$ColorTween.interpolate_property(material, "emission", Color(0.93, 0.9, 0.89), Color(0.88, 0.55, 0.45), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.interpolate_property(material, "emission", Color(0.88, 0.55, 0.45), Color(0, 0, 0), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
	$ColorTween.interpolate_property(material, "emission_energy", 0.5, 0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.interpolate_property($MeshInstance, "scale", Vector3(1.5, 1, 1.5), Vector3(1,  1, 1), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.start()

func _on_Timer_timeout():
	queue_free()
