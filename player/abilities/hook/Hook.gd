# Hook ability with right click

extends RayCast

var pull_force = 5

onready var player = get_tree().get_root().find_node("Player", true, false)
onready var grab = get_tree().get_root().find_node("Grab", true, false)

var destination
var vector
var can_use = true
var can_use_input = true

func _physics_process(delta):
	if player.is_on_floor():
		if not can_use:
			destination = null
			if $Timer.is_stopped() and not destination:
				$Timer.start()
				$Tween.interpolate_property($CanHook, "margin_left", -30, -5, $Timer.wait_time, Tween.TRANS_SINE, Tween.EASE_OUT)
				$Tween.interpolate_property($CanHook, "margin_top", -30, -5, $Timer.wait_time, Tween.TRANS_SINE, Tween.EASE_OUT)
				$Tween.interpolate_property($CanHook, "margin_right", 30, 5, $Timer.wait_time, Tween.TRANS_SINE, Tween.EASE_OUT)
				$Tween.interpolate_property($CanHook, "margin_bottom", 30, 5, $Timer.wait_time, Tween.TRANS_SINE, Tween.EASE_OUT)
				$Tween.start()
	
	$CanHook.border_color = Color(0, 0, 0, 0.25)
	if get_collider() is StaticBody or get_collider() is CSGPrimitive:
		if can_use:
			if grab:
				if not grab.object_grabbed:
					$CanHook.border_color = Color(1, 0, 0, 0.75)
			else:
				$CanHook.border_color = Color(1, 0, 0)
	
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		if get_collider() is StaticBody or get_collider() is CSGPrimitive:
			if not destination and can_use and can_use_input:
				can_use = false
				can_use_input = false
				if grab:
					if not grab.object_grabbed:
						destination = get_collision_point()
				else:
					destination = get_collision_point()
				
				if destination:
					$Tween.interpolate_property($CanHook, "margin_left", -5, -30, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
					$Tween.interpolate_property($CanHook, "margin_top", -5, -30, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
					$Tween.interpolate_property($CanHook, "margin_right", 5, 30, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
					$Tween.interpolate_property($CanHook, "margin_bottom", 5, 30, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
					$Tween.start()
				
	else:
		destination = null
		can_use_input = true
		
	if destination:
		vector = (destination - player.global_transform.origin)
		player.move_and_slide(vector * pull_force)

func _on_Timer_timeout():
	can_use = true