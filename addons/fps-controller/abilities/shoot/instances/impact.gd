extends Position3D

func _ready():
	print( $GPUParticles3D1.transparency )
	
	
	$Bullet.scale = Vector3()
	$GPUParticles3D1.emitting = true
	$GPUParticles3D2.emitting = true

	var tween = create_tween()
	tween.tween_property( $Bullet, "scale", Vector3(1, 1, 1), 0.1 ).set_trans(Tween.TRANS_SINE)
	tween.tween_property( $Bullet, "scale", Vector3(), 0.1 ).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free).set_delay(0.5)

	var particle_tween = create_tween()
	particle_tween.tween_property( $GPUParticles3D1, "transparency", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	particle_tween.parallel().tween_property( $GPUParticles3D2, "transparency", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
