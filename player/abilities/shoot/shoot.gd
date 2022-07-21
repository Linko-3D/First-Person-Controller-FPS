extends Position3D

var impact = preload( "res://player/abilities/shoot/instances/impact.tscn" )


var ammo = 30

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT) >= 0.6:
		shoot()

	if Input.is_key_pressed(KEY_R) or Input.is_joy_button_pressed(0, JOY_BUTTON_X):
		if ammo != 30:
			$ReloadTimer.start()
			ammo = 30
			print("ammo: "  , ammo)
			
			$ReloadSound.pitch_scale = randf_range(0.95, 1.05)
			$ReloadSound.play()
			
			var tween = create_tween()
			$AmmoLeft.size.x = 0
			tween.tween_property( $AmmoLeft, "size:x", float(ammo), 1.0 )
			

func shoot():
	if not $ReloadTimer.is_stopped():
		return
	if not $FireRateTimer.is_stopped():
		return
		
	$FireRateTimer.start()
	$TriggerSound.pitch_scale = randf_range(0.95, 1.05)
	$TriggerSound.play()
	
	if ammo <= 0:
		return

	ammo -= 1
	print("ammo: "  , ammo)
	$AmmoLeft.size.x = ammo

	$ShootSound.pitch_scale = randf_range(0.95, 1.05)
	$ShootSound.play()

	$BangSound.pitch_scale = randf_range(0.95, 1.05)
	$BangSound.play()

	$ShellSound.pitch_scale = randf_range(0.95, 1.05)
	$ShellSound.play()

	if $RayCast3D.is_colliding():
		var impact_instance = impact.instantiate()
		
		get_tree().get_root().add_child(impact_instance)
		impact_instance.position = $RayCast3D.get_collision_point()
		impact_instance.rotation = global_transform.basis.get_euler()
		
		if $RayCast3D.get_collider() is RigidDynamicBody3D:
			$RayCast3D.get_collider().apply_central_impulse( -$RayCast3D.get_collision_normal() * 20 )
#		impact_instance.look_at( $RayCast3D.get_collision_point() - $RayCast3D.get_collision_normal(), Vector3.UP )
