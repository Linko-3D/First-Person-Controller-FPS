# Hook ability with right click

extends RayCast

var pull_force = 5

var player
var destination
var hold = false
var vector

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed and $Timer.is_stopped():
			if get_collider() is StaticBody or get_collider() is CSGPrimitive:
				destination = get_collision_point()
				hold = true
		else:
			hold = false

func _physics_process(delta):
	if hold:
		$Timer.start()
		vector = (destination - player.global_transform.origin)
		player.move_and_slide(vector * pull_force)
