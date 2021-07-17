extends Node2D

onready var player = get_tree().get_root().find_node("Player", true, false)
var movement_speed = 0.0

func _ready():
	position = get_viewport().size / 2
	get_tree().connect("screen_resized", self, "_on_screen_resized")

func _process(delta):
	movement_speed = player.movement.length()
	$Line1.position.x = clamp(-11.5 + (movement_speed * -1.6), -21, -11.5)
	$Line2.position.y = clamp(-11.5 + (movement_speed * -1.6), -21, -11.5)
	$Line3.position.x = clamp(11.5 + (movement_speed * 1.6), 11.5, 21)
	$Line4.position.y = clamp(11.5 + (movement_speed * 1.6), 11.5, 21)

func _on_screen_resized():
	position = get_viewport().size / 2
