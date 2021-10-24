extends Control
#
#var max_messages = 5
#
#var can_use = true
#
#func _ready():
#	$Message.hide()
#
#	yield(get_tree(), "idle_frame")
#
#	if get_tree().is_network_server():
#		send_message(true, "-- Server is running --", Color(1, 1, 0))
#	else:
#		send_message(false, "-- " + Network.username + " has joined the game --", Color(1, 1, 0))
#	$ChatBox.margin_bottom = get_viewport().size.y / 1.5
#
#func _input(event):
#	if Input.is_key_pressed(KEY_ENTER):
#		if can_use:
#			can_use = false
#
#			if $Message.visible:
#				if $Message/TypedMessage.text != "":
#					send_message(true, Network.username + ": " + $Message/TypedMessage.text, Color(1, 1, 1))
#				$Message.visible = false
#				$Message/TypedMessage.clear()
#				$MessagesFadeOutTimer.start()
#			else:
#				$MessagesFadeOutTimer.stop()
#				$Message.visible = true
#				$ChatBox.show()
#	else:
#		can_use = true
#
#func send_message(to_self, data, color):
#	if to_self:
#		send_message_online(data, color)
#
#	rpc("send_message_online", data, color)
#
#remote func send_message_online(data, color):
#	$ChatBox.show()
#
#	if not $Message.visible:
#		$MessagesFadeOutTimer.start()
#
#	var display_message = Label.new()
#	display_message.modulate = color
#	$ChatBox.add_child(display_message)
#	display_message.text = data
#
#	if $ChatBox.get_child_count() > max_messages:
#		$ChatBox.get_child(0).queue_free()
#
#func _on_MessagesFadeOutTimer_timeout():
#	$ChatBox.hide()
