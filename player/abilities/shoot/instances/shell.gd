extends RigidDynamicBody3D

func _on_timer_timeout():
	queue_free()
