extends Position3D

export (PackedScene) var debris

onready var material = $Bullet.get_active_material(0)

func _ready():
	$Particles.emitting = true
	
	$ImpactSound.pitch_scale = rand_range(0.95, 1.05)
	
	$ColorTween.interpolate_property(material, "emission", Color(1, 0.76, 0), Color(1, 0.76, 0), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.interpolate_property(material, "emission", Color(1, 0.76, 0.1), Color(0, 0, 0), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	$ColorTween.interpolate_property(material, "emission_energy", 16, 0, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.interpolate_property($Bullet, "scale", Vector3(2, 2, 2), Vector3(0, 0, 0), 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.start()

func spawn_debris(throw_force):
	$Position3D.rotation_degrees.z = rand_range(0, 360)
	$Position3D/Position3D2.rotation_degrees.x = rand_range(0, 10)
	
	var debris_instance = debris.instance()
	get_tree().get_root().add_child(debris_instance)
	debris_instance.global_transform = $Position3D/Position3D2.global_transform
	debris_instance.linear_velocity = $Position3D/Position3D2.global_transform.basis.z * throw_force

func _on_ColorTween_tween_all_completed():
	queue_free()
