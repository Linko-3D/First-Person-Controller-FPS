extends RayCast

export (PackedScene) var dot

onready var dot_instance = dot.instance()

onready var player = get_tree().get_root().find_node("Player", true ,false)
onready var shoot = get_tree().get_root().find_node("Shoot", true ,false)
onready var crosshair = get_tree().get_root().find_node("Crosshair", true ,false)
onready var reload_tween = get_tree().get_root().find_node("ReloadTween", true, false)
onready var melee_attack_tween = get_tree().get_root().find_node("MeleeAttackTween", true, false)
onready var grab = get_tree().get_root().find_node("Grab", true, false)

func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().get_root().add_child(dot_instance)

func _process(delta):
	dot_instance.hide()
	
	if player.slide:
		return
	
	if reload_tween:
		if reload_tween.is_active():
			return
	if grab:
		if grab.object_grabbed:
			return
	
	if crosshair:
		if shoot:
			if shoot.accuracy == 2:
				return
			if melee_attack_tween.is_active():
				return
	
	if is_colliding():
		if player.is_on_floor() and player.speed_multiplier != 2:
			dot_instance.show()
			dot_instance.global_transform.origin = get_collision_point()
