extends RayCast

export (PackedScene) var dot

onready var dot_instance = dot.instance()

onready var crosshair = get_tree().get_root().find_node("Crosshair", true ,false)
onready var shoot = get_tree().get_root().find_node("Shoot", true ,false)
onready var player = get_tree().get_root().find_node("Player", true ,false)
onready var reload_tween = get_tree().get_root().find_node("ReloadTween", true, false)
onready var grab = get_tree().get_root().find_node("Grab", true, false)

func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().get_root().add_child(dot_instance)

func _process(delta):
	dot_instance.hide()
	if is_colliding():
		if player.is_on_floor() and player.speed_multiplier != 2:
			dot_instance.show()
			dot_instance.global_transform.origin = get_collision_point()
	if reload_tween:
		if reload_tween.is_active():
			dot_instance.hide()
	if grab:
		if grab.object_grabbed:
			dot_instance.hide()

	if crosshair:
		if shoot:
			if shoot.accuracy == 2:
				dot_instance.hide()
