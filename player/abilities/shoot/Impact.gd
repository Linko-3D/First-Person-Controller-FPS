extends Position3D

export (PackedScene) var debris
var color = Color(1, 1, 1)

func _ready():
	$ImpactSound.pitch_scale = rand_range(0.95, 1.05)
	
	var material = SpatialMaterial.new()
	material.albedo_color = Color(0, 0, 0)
	material.metallic = 1
	material.emission = Color(0.92, 0.91, 0.90)
	material.emission_energy = 10
	material.emission_enabled = true
	$Bullet.set_surface_material(0, material)
	$Bullet.scale = Vector3(2, 2, 2)
	
	$ColorTween.interpolate_property(material, "emission", Color(0.93, 0.9, 0.89), Color(0.88, 0.55, 0.45), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.interpolate_property(material, "emission", Color(0.88, 0.55, 0.45), Color(0, 0, 0), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
	$ColorTween.interpolate_property(material, "emission_energy", 10, 0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.interpolate_property($Bullet, "scale", Vector3(2, 2, 2), Vector3(1, 1, 1), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.start()
	yield(get_tree(), "idle_frame")
	for i in 5:
		spawn_debris(rand_range(1, 5))
	
func hide_bullet():
	yield(get_tree().create_timer(0.1), "timeout")
	$Bullet.hide()

func spawn_debris(throw_force):
	$Position3D.rotation_degrees.z = rand_range(0, 360)
	$Position3D/Position3D2.rotation_degrees.x = rand_range(0, 10)
	var debris_instance = debris.instance()
	debris_instance.color = color
	get_tree().get_root().add_child(debris_instance)
	debris_instance.global_transform = $Position3D/Position3D2.global_transform
	debris_instance.linear_velocity = $Position3D/Position3D2.global_transform.basis.z * throw_force
