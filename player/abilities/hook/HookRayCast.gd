# Hook ability with right click

extends RayCast

export var pull_force = 5

var player
var destination
var hold = false
var vector

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed and $Timer.is_stopped():
			if is_colliding() and get_collider() is StaticBody:
				destination = get_collision_point()
				hold = true
				$Timer.start()
		else:
			hold = false
				

func _physics_process(delta):
	if hold:
		vector = (destination - player.global_transform.origin)
		player.move_and_slide(vector * pull_force)


func _on_Timer_timeout():
	pass # Replace with function body.
