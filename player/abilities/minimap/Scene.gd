extends Spatial

onready var player = get_tree().get_root().find_node("Player", true, false)

func _process(delta):
	$Camera.translation.x = player.translation.x
	$Camera.translation.z = player.translation.z
	$Camera.rotation_degrees.y = player.rotation_degrees.y
