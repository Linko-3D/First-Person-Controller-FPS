extends Position3D

func _ready():
	$Flash.scale = Vector3()

	var tween = create_tween()
	tween.tween_property( $Flash, "scale", Vector3(1, 1, 1), 0.1 ).set_trans(Tween.TRANS_SINE)
	tween.tween_property( $Flash, "scale", Vector3(), 0.1 ).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free).set_delay(0.5)
