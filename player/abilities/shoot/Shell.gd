extends RigidBody

func _ready():
	var material = SpatialMaterial.new()
	material.albedo_color = Color(1, 1, 0)
	material.metallic = 1
	material.roughness = 0.1
	material.emission_enabled = true
	material.emission = Color(0.88, 0.55, 0.45)
	$MeshInstance.set_surface_material(0, material)
	
	$ColorTween.interpolate_property(material, "emission_energy", 0.1, 0, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.start()

func _on_LifetimeTimer_timeout():
	queue_free()

func _on_AudioTimer_timeout():
	$ImpactSound.play()
