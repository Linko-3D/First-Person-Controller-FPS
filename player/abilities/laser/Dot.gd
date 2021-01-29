extends Position3D

var player

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)

func _process(delta):
	if not player:
		queue_free()
