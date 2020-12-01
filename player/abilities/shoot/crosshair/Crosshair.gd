extends Position2D

var animated = true


var speed = 0.1
var base_position = 47.5
var end_position = base_position + 34

var wide_crosshair = true

var player = null
var movement = Vector3()

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)

func _process(delta):
	position = OS.get_window_size() / 2
	
	if animated:
		movement.x = stepify(player.velocity.x, 10)
		movement.y = stepify(player.velocity.y, 10)
		movement.z = stepify(player.velocity.z, 10)
		
		if player.direction == Vector3() and player.is_on_floor():
				if wide_crosshair and not $Tween.is_active():
					$Tween.interpolate_property($Line1, "position:x", -end_position, -base_position, speed, 0, 2, speed)
					$Tween.interpolate_property($Line2, "position:y", -end_position, -base_position, speed, 0, 2, speed)
					$Tween.interpolate_property($Line3, "position:x", end_position, base_position, speed, 0, 2, speed)
					$Tween.interpolate_property($Line4, "position:y", end_position, base_position, speed, 0, 2, speed)
					$Tween.start()
					wide_crosshair = false
		else:
			if not wide_crosshair and not $Tween.is_active():
				$Tween.interpolate_property($Line1, "position:x", -base_position, -end_position, speed, 0, 2, 0)
				$Tween.interpolate_property($Line2, "position:y", -base_position, -end_position, speed, 0, 2, 0)
				$Tween.interpolate_property($Line3, "position:x", base_position, end_position, speed, 0, 2, 0)
				$Tween.interpolate_property($Line4, "position:y", base_position, end_position, speed, 0, 2, 0)
				$Tween.start()
				wide_crosshair = true
