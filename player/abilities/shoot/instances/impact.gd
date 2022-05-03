extends Position3D

func _ready():
	$Bullet.scale = Vector3()
	$GPUParticles3D1.emitting = true
	$GPUParticles3D2.emitting = true

	var tween = create_tween()
	tween.tween_property( $Bullet, "scale", Vector3(1, 1, 1), 0.1 ).set_trans(Tween.TRANS_SINE)
	tween.tween_property( $Bullet, "scale", Vector3(), 0.1 ).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free).set_delay(0.8)

	$OmniLight3D.omni_range = 0
	$OmniLight3D.light_energy = 0
	var light_tween = create_tween()
	light_tween.tween_property( $OmniLight3D, "position:z", 0.5, 0.3 ).set_trans(Tween.TRANS_SINE)
	light_tween.set_parallel().tween_property( $OmniLight3D, "omni_range", 2.0, 0.15 ).set_trans(Tween.TRANS_SINE)
	light_tween.set_parallel().tween_property( $OmniLight3D, "omni_range", 0.0, 0.15 ).set_trans(Tween.TRANS_SINE).set_delay(0.15)
	light_tween.set_parallel().tween_property( $OmniLight3D, "light_energy", 0.5, 0.15 ).set_trans(Tween.TRANS_SINE)
	light_tween.set_parallel().tween_property( $OmniLight3D, "light_energy", 0.0, 0.15 ).set_trans(Tween.TRANS_SINE).set_delay(0.15)
	
#	$Tween.interpolate_property($OmniLight, "translation:z", 0, 0.5, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
