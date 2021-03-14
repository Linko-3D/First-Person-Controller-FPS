extends RayCast

var speed = 0.1
var base_position = 53.5
var end_position = 81.5

var wide_crosshair = false

onready var player = get_tree().get_root().find_node("Player", true, false)
onready var reload_tween = get_tree().get_root().find_node("ReloadTween", true, false)
onready var melee_attack_tween = get_tree().get_root().find_node("MeleeAttackTween", true, false)
onready var grab  = get_tree().get_root().find_node("Grab", true, false)
onready var shoot  = get_tree().get_root().find_node("Shoot", true, false)

func _ready():
	$Position2D/Lines/Line1.position.x = -base_position
	$Position2D/Lines/Line2.position.y = -base_position
	$Position2D/Lines/Line3.position.x = base_position
	$Position2D/Lines/Line4.position.y = base_position

func _process(delta):
	$Position2D.position = get_viewport().size / 2
	
	$Position2D.show()
	
	if not player.is_on_floor() or player.speed_multiplier == 2 or player.slide:
		$Position2D.hide()
	
	if shoot: # If the node Shoot is in the scene, hide when reloading and aiming
		if reload_tween.is_active():
			$Position2D.hide()
		
		if melee_attack_tween.is_active():
			$Position2D.hide()
		
		if shoot.accuracy == 1:
			$Position2D/Lines.show()
			$Position2D/CenterDot.hide()
		else:
			$Position2D/Lines.hide()
			$Position2D/CenterDot.show()
	
	if grab: # If the node Grab is in the scene, hide when grabbing
		if grab.object_grabbed:
			$Position2D.hide()
	
	# Change color to red when pointing on an enemy
	if is_colliding() and get_collider().is_in_group("enemy"):
		red()
	else:
		white()
	
	animate(delta)

func animate(delta):
	if player.direction != Vector3():
		$Position2D/Lines/Line1.position.x = lerp($Position2D/Lines/Line1.position.x, -end_position, 10 * delta)
		$Position2D/Lines/Line2.position.y = lerp($Position2D/Lines/Line2.position.y, -end_position, 10 * delta)
		$Position2D/Lines/Line3.position.x = lerp($Position2D/Lines/Line3.position.x, end_position, 10 * delta)
		$Position2D/Lines/Line4.position.y = lerp($Position2D/Lines/Line4.position.y, end_position, 10 * delta)
	else:
		$Position2D/Lines/Line1.position.x = lerp($Position2D/Lines/Line1.position.x, -base_position, 10 * delta)
		$Position2D/Lines/Line2.position.y = lerp($Position2D/Lines/Line2.position.y, -base_position, 10 * delta)
		$Position2D/Lines/Line3.position.x = lerp($Position2D/Lines/Line3.position.x, base_position, 10 * delta)
		$Position2D/Lines/Line4.position.y = lerp($Position2D/Lines/Line4.position.y, base_position, 10 * delta)

func white():
	$Position2D/Lines/Line1.white()
	$Position2D/Lines/Line2.white()
	$Position2D/Lines/Line3.white()
	$Position2D/Lines/Line4.white()
	$Position2D/CenterDot.white()

func red():
	$Position2D/Lines/Line1.red()
	$Position2D/Lines/Line2.red()
	$Position2D/Lines/Line3.red()
	$Position2D/Lines/Line4.red()
	$Position2D/CenterDot.red()
