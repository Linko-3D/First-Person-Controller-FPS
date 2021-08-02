extends Spatial

onready var player = get_tree().get_root().find_node("Player", true, false)

var jump_remaining = 1
var can_jump = false

func _physics_process(delta):
	if not player.is_on_floor():
		if $Timer.is_stopped() and not can_jump:
			$Timer.start()
	else:
		can_jump = false
		jump_remaining = 1
	
	if can_jump and jump_remaining > 0:
		if Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_XBOX_A):
			jump_remaining -= 1
			player.jump()

func _on_Timer_timeout():
	can_jump = true
