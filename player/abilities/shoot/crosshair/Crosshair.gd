extends Position2D

var animated = true


var time = 0.05
var base_position = 47.5
var end_position = 81.5

var player = null
var speed = Vector3()

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)

func _process(delta):
	position = OS.get_window_size() / 2
	
	if animated:
		speed.x = stepify(player.velocity.x, 10)
		speed.y = stepify(player.velocity.y, 10)
		speed.z = stepify(player.velocity.z, 10)
		
		if speed == Vector3():
			if player.is_on_floor():
				if $Line1.position.x == -end_position and not $Tween.is_active():
					$Tween.interpolate_property($Line1, "position:x", -end_position, -base_position, time, 0, 2, time)
					$Tween.interpolate_property($Line2, "position:y", -end_position, -base_position, time, 0, 2, time)
					$Tween.interpolate_property($Line3, "position:x", end_position, base_position, time, 0, 2, time)
					$Tween.interpolate_property($Line4, "position:y", end_position, base_position, time, 0, 2, time)
					$Tween.start()
		else:
			if $Line1.position.x == -base_position and not $Tween.is_active():
				$Tween.interpolate_property($Line1, "position:x", -base_position, -end_position, time, 0, 2, 0)
				$Tween.interpolate_property($Line2, "position:y", -base_position, -end_position, time, 0, 2, 0)
				$Tween.interpolate_property($Line3, "position:x", base_position, end_position, time, 0, 2, 0)
				$Tween.interpolate_property($Line4, "position:y", base_position, end_position, time, 0, 2, 0)
				$Tween.start()
