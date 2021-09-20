extends RigidBody

func _ready():
	var material = $Pebble.get_active_material(0)
	$ColorTween.interpolate_property(material, "emission", Color(1, 1, 1), Color(1, 0.75, 0), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.interpolate_property(material, "emission_energy", 5, 0, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ColorTween.interpolate_property(material, "albedo_color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 4)
	$ColorTween.start()

func _on_ColorTween_tween_all_completed():
	queue_free()
