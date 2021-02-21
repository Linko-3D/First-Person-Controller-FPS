extends Position2D

func _ready():
	$Visual.position = get_viewport().size / 2
	$Visual.hide()

func display():
	$Visual.show()
	$Tween.stop_all()
	
	$Tween.interpolate_property($Visual/PositionTopLeft/ColorRect, "color", Color(0.78, 0.24, 0.39, 1), Color(0.78, 0.24, 0.39, 0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
	$Tween.interpolate_property($Visual/PositionTopRight/ColorRect, "color", Color(0.78, 0.24, 0.39, 1), Color(0.78, 0.24, 0.39, 0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
	$Tween.interpolate_property($Visual/PositionBotLeft/ColorRect, "color", Color(0.78, 0.24, 0.39, 1), Color(0.78, 0.24, 0.39, 0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
	$Tween.interpolate_property($Visual/PositionBotRight/ColorRect, "color", Color(0.78, 0.24, 0.39, 1), Color(0.78, 0.24, 0.39, 0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
	
	$Tween.start()
