extends RayCast

var text_visible = false

func _ready():
	$Label.modulate = Color(1, 0.8, 0.2, 0)

func _physics_process(delta):
	if get_collider() is VehicleBody:
		grab_text_appears()
	else:
		grab_text_disappears()

func grab_text_appears():
	if not text_visible:
		text_visible = true
		var animation_speed = 0.1
		$Tween.interpolate_property($Label, "margin_top", 45, 35, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Label, "modulate", Color(1, 0.8, 0.2, 0), Color(1, 0.8, 0.2, 1), animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()

func grab_text_disappears():
	if text_visible:
		text_visible = false
		var animation_speed = 0.1
		$Tween.interpolate_property($Label, "margin_top", 35, 45, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Label, "modulate", Color(1, 0.8, 0.2, 1), Color(1, 0.8, 0.2, 0), animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()
