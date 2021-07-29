extends Position3D

# When instanced, use Editable Children and move the destination's position.

onready var starting_position = $StaticBody.translation
onready var destination_position = $Destination.translation
onready var distance = starting_position - destination_position

export var move_back = true
export var speed = 1
export var start_wait_time = 1
export var end_wait_time = 1

func _process(delta):
	if not $AnimationTween.is_active():
		$AnimationTween.interpolate_property($StaticBody, "translation", starting_position, starting_position, 0)
		$AnimationTween.interpolate_property($StaticBody, "translation", starting_position, destination_position, distance.length() / speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, start_wait_time)
		$AnimationTween.interpolate_property($StaticBody, "translation", destination_position, destination_position, 0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, (distance.length() / speed) + (start_wait_time + end_wait_time))
		if move_back:
			$AnimationTween.interpolate_property($StaticBody, "translation", destination_position, starting_position, distance.length() / speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, (distance.length() / speed) + (start_wait_time + end_wait_time))
		$AnimationTween.start()
