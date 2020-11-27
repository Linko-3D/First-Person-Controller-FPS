extends RayCast

export (PackedScene) var dot

onready var dot_instance = dot.instance()

var ShootRayCast = null

func _ready():
	ShootRayCast = get_tree().get_root().find_node("ShootRayCast", true ,false)
	yield(get_tree(), "idle_frame")
	get_tree().get_root().add_child(dot_instance)

func _process(delta):
	dot_instance.global_transform.origin = get_collision_point()
	
	if is_colliding():
		dot_instance.show()
		if ShootRayCast.get_node("ReloadTween"):
			if not ShootRayCast.get_node("ReloadTween").is_active():
				dot_instance.show()
			else:
				dot_instance.hide()
	else:
		dot_instance.hide()
