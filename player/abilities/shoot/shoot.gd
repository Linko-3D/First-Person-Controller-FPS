extends Position3D

var impact = preload("res://player/abilities/shoot/instances/impact.tscn")
var shell = preload( "res://player/abilities/shoot/instances/shell.tscn" )

var ammo = 30.0

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT) >= 0.6:
		if $FireRateTimer.is_stopped():
			if ammo > 0:
				shoot()
			$TriggerSound.pitch_scale = randf_range(0.95, 1.05)
			$TriggerSound.play()
			$FireRateTimer.start()

	if Input.is_key_pressed(KEY_R) or Input.is_joy_button_pressed(0, JOY_BUTTON_X):
		ammo = 30
		$AmmoLeft.size.x = ammo

func shoot():
	ammo -= 1
	$AmmoLeft.size.x = ammo

	$BulletSpread.rotation.z = randf_range( 0, deg2rad(360) )
	$BulletSpread/RayCast3D.rotation.x = randf_range(0, deg2rad(5)) * $RecoilStabilizationTimer.time_left * 5
	$RecoilStabilizationTimer.start()

	$ShootSound.pitch_scale = randf_range(0.95, 1.05)
	$ShootSound.play()

	$BangSound.pitch_scale = randf_range(0.95, 1.05)
	$BangSound.play()
	
	$ShellSound.pitch_scale = randf_range(0.95, 1.05)
	$ShellSound.play()

	var tween = get_tree().create_tween()
	tween.tween_property( $Weapon, "position:z", randf_range(0.035, 0.045), 0.05 ).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property( $Weapon, "position:y", randf_range(0.005, 0.015), 0.05 ).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property( $Weapon, "position:x", randf_range(-0.005, 0.005), 0.05 ).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property( $Weapon, "rotation:x", deg2rad( randf_range(-1.5, -0.5) ), 0.05 ).set_trans(Tween.TRANS_SINE)

	tween.tween_property( $Weapon, "position:z", 0.0, 0.15 ).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property( $Weapon, "position:y", 0.0, 0.15 ).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property( $Weapon, "position:x", 0.0, 0.15 ).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property( $Weapon, "rotation:x", 0.0, 0.15 ).set_trans(Tween.TRANS_SINE)

	if $BulletSpread/RayCast3D.get_collider() is RigidDynamicBody3D:
		$BulletSpread/RayCast3D.get_collider().apply_central_impulse( -$BulletSpread/RayCast3D.get_collision_normal() * 20 )
#		$BulletSpread/RayCast3D.get_collider().apply_impulse( -$BulletSpread/RayCast3D.get_collision_normal(), $BulletSpread/RayCast3D.get_collision_point() )

	if $BulletSpread/RayCast3D.is_colliding():
		var impact_instance = impact.instantiate()

		get_tree().get_root().add_child(impact_instance)
		impact_instance.position = $BulletSpread/RayCast3D.get_collision_point()
		impact_instance.look_at( $BulletSpread/RayCast3D.get_collision_point() - $BulletSpread/RayCast3D.get_collision_normal(), Vector3.UP )
		if $BulletSpread/RayCast3D.get_collider() is StaticBody3D: # Orientation is bugged on static bodies
			if $BulletSpread/RayCast3D.get_collision_normal() == Vector3.UP:
				impact_instance.rotation.x = deg2rad(-90)
			if $BulletSpread/RayCast3D.get_collision_normal() == Vector3.DOWN:
				impact_instance.rotation.x = deg2rad(90)

	var shell_instance = shell.instantiate()
	
	$ShellSpawn.add_child(shell_instance)
