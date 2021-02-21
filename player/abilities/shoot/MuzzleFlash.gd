extends Spatial

var material = SpatialMaterial.new()
# .8 55 42
func _ready():
	material.albedo_color = Color(0, 0, 0, 0.01)
	material.emission = Color(0.92, 0.91, 0.90)
	material.emission_energy = 10
	material.flags_transparent = true
	material.emission_enabled = true
	$Flash.set_surface_material(0, material)
	$Tween.interpolate_property(material, "albedo_color", Color(0, 0, 0, 0.01), Color(0, 0, 0, 0), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property(material, "emission", Color(0.93, 0.9, 0.89), Color(0.88, 0.55, 0.45), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property(material, "emission_energy", 10, 0, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property($Flash, "scale", Vector3(1, 1, 1), Vector3(0.3, 0.3, 0.3), 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	
	$Tween.interpolate_property($OmniLight, "light_energy", 0.1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($OmniLight, "light_indirect_energy", 0.1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	$Tween.start()
	
	
func _on_Lifetime_timeout():
	queue_free()
