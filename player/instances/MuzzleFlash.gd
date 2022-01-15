extends Position3D

onready var particles_material = $Particles1.get_material_override()

func _ready():
	$Tween.interpolate_property(particles_material, "albedo_color", Color(1, 0.75, 0, 1), Color(1, 0.75, 0, 0), 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Timer_timeout():
	queue_free()

func _on_Tween_tween_all_completed():
	queue_free()
