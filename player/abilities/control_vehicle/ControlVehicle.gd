extends RayCast

var text_visible = false

func _ready():
	$Label.modulate = Color(1, 1, 1, 0)

func _physics_process(delta):
	if get_collider() is VehicleBody:
		grab_text_appears()
		print("a")
	else:
		grab_text_disappears()

func grab_text_appears():
	if not text_visible:
		text_visible = true
		var animation_speed = 0.25
		$Tween.interpolate_property($Label, "margin_top", 45, 35, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Label, "modulate", Color(1, 0.6, 0.1, 0), Color(1, 0.6, 0.1, 1), animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()

func grab_text_disappears():
	if text_visible:
		text_visible = false
		var animation_speed = 0.25
		$Tween.interpolate_property($Label, "margin_top", 35, 45, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Label, "modulate", Color(1, 0.6, 0.1, 1), Color(1, 0.6, 0.1, 0), animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()
