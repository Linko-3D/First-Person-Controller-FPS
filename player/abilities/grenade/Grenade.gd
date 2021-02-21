extends RigidBody

export (PackedScene) var grenade
var material = SpatialMaterial.new()

func _ready():
	material.albedo_color = Color(1, 1, 1)
	material.emission = Color(1, 0, 0)
	material.emission_energy = 0.1
	material.emission_enabled = true
	$MeshInstance.set_surface_material(0, material)

func _process(delta):
	if $LifetimeTimer.time_left <= 1:
		$LightTimer.wait_time = 0.1

func _on_LifetimeTimer_timeout():
	var grenade_instance = grenade.instance()
	grenade_instance.global_transform = global_transform
	
	get_tree().get_root().add_child(grenade_instance)
	queue_free()

func _on_LightTimer_timeout():
	$BlinkingLight.visible = !$BlinkingLight.visible
	if $BlinkingLight.visible == true:
		material.emission_energy = 1
	else:
		material.emission_energy = 0.1
	$LightTimer.start()
