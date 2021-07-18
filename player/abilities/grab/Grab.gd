extends RayCast

var mass_limit = 50
var throw_force = 5

var object_grabbed = null

var can_use = true

var text_visible = false

func _ready():
	$GrabText.modulate = Color(0.81, 0.5, 0.09, 0)

func _physics_process(delta):
	if not object_grabbed and $TextTimer.is_stopped() and get_collider() is RigidBody and get_collider().mass <= mass_limit:
		grab_text_appears()
	else:
		grab_text_disappears()
	
	if object_grabbed:
		var vector = $GrabPosition.global_transform.origin - object_grabbed.global_transform.origin
		object_grabbed.linear_velocity = vector * 10
		object_grabbed.axis_lock_angular_x = true
		object_grabbed.axis_lock_angular_y = true
		object_grabbed.axis_lock_angular_z = true
		
		if vector.length() >= 3:
			object_grabbed.set_mode(0)
			release()
	
	if Input.is_key_pressed(KEY_E) or Input.is_joy_button_pressed(0, JOY_XBOX_Y):
		if can_use:
			can_use = false
			if not object_grabbed:
				if get_collider() is RigidBody and get_collider().mass <= mass_limit:
					object_grabbed = get_collider()
					object_grabbed.rotation_degrees.x = 0
					object_grabbed.rotation_degrees.z = 0
			else:
				release()
	else:
		can_use = true
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) or Input.get_joy_axis(0, 7) >= 0.6:
		if object_grabbed:
			object_grabbed.linear_velocity = global_transform.basis.z * -throw_force
			release()

func release():
	object_grabbed.axis_lock_angular_x = false
	object_grabbed.axis_lock_angular_y = false
	object_grabbed.axis_lock_angular_z = false
	object_grabbed = null
	$TextTimer.start()

func grab_text_appears():
	if not text_visible:
		text_visible = true
		var animation_speed = 0.25
		$GrabTween.interpolate_property($GrabText, "margin_top", 90, 80, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$GrabTween.interpolate_property($GrabText, "modulate", Color(0.81, 0.5, 0.09, 0), Color(0.81, 0.5, 0.09, 1), animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$GrabTween.start()

func grab_text_disappears():
	if text_visible:
		text_visible = false
		var animation_speed = 0.25
		$GrabTween.interpolate_property($GrabText, "margin_top", 80, 90, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$GrabTween.interpolate_property($GrabText, "modulate", Color(0.81, 0.5, 0.09, 1), Color(0.81, 0.5, 0.09, 0), animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$GrabTween.start()
		$TextTimer.start()
