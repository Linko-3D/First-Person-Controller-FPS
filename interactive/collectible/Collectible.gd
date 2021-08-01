extends Position3D

var player = null
onready var starting_position = $Object.translation.y


func _process(delta):
	if player:
		var distance = player.translation - translation
		distance = distance.length()
		translation = lerp(translation, player.translation, delta / (distance / 10 ))
	
	$Object.rotation_degrees.y += 2.5
	
	if not $Tween.is_active():
		$Tween.interpolate_property($Object, "translation:y", starting_position, starting_position + 0.1, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Object, "translation:y", starting_position + 0.1, starting_position, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1)
		$Tween.start()

func _on_AreaRange_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_AreaCollect_body_entered(body):
	if body.is_in_group("player"):
		queue_free()
