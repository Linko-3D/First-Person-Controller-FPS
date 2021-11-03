extends RayCast

export (Resource) var accept_sound

var script_enabled = false

var can_use = false

onready var player = get_tree().get_root().find_node("Player", true, false)

func _ready():
	$Text.hide()
	$ColorRect.hide()

func _process(delta):
	if not script_enabled:
		return
	
	if not $Tween.is_active():
		$Tween.interpolate_property($Text/Label2, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.5), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Text/Label2, "modulate", Color(1, 1, 1, 0.5), Color(1, 1, 1, 1), 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
		$Tween.start()
	
	if get_collider() is VehicleBody:
		$Text.show()
		$ColorRect.show()
	else:
		$Text.hide()
		$ColorRect.hide()
	
	if Input.is_key_pressed(KEY_E) or Input.is_joy_button_pressed(0, JOY_XBOX_Y):
		if can_use:
			can_use = false
			if get_collider() is VehicleBody:
				play_sound()
				get_collider().take_control()
				player.queue_free()
	else:
		can_use = true

func play_sound():
	var audio_node = AudioStreamPlayer.new()
	audio_node.stream = accept_sound
	get_tree().get_root().add_child(audio_node)
	audio_node.play()

func _on_Timer_timeout():
	script_enabled = true
