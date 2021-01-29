extends Spatial

var player

var number_of_jumps = 1
var jumps_remaining = number_of_jumps
var can_jump = false # Used with a timer to add a delay before each jumps

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)

func _input(event):
	if Input.is_key_pressed(KEY_SPACE) and can_jump and jumps_remaining > 0:
		player.jump()
		can_jump = false
		jumps_remaining -= 1

func _physics_process(delta):
	if not player.is_on_floor() and $Timer.is_stopped() and not can_jump:
		$Timer.start()

	if player.is_on_floor():
		$Timer.stop()
		can_jump = false
		jumps_remaining = number_of_jumps

func _on_Timer_timeout():
	if not player.is_on_floor():
		can_jump = true
