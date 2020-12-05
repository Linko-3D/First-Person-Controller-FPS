extends Spatial

export (Resource) var footstep_sound1
export (Resource) var footstep_sound2
export (Resource) var footstep_sound3
export (Resource) var footstep_sound4
export (Resource) var footstep_sound5
export (Resource) var footstep_sound6
export (Resource) var footstep_sound7
export (Resource) var footstep_sound8
export (Resource) var footstep_sound9
export (Resource) var footstep_sound10

onready var footstep_sounds = [footstep_sound1, footstep_sound2, footstep_sound3, footstep_sound4, footstep_sound5, footstep_sound6, footstep_sound7, footstep_sound8, footstep_sound9, footstep_sound10]

var player = null
var has_jumped = false
var velocity = 0

var timer_speed

func _ready():
	player = get_tree().get_root().find_node("Player", true ,false)
	timer_speed = $Timer.wait_time

func _process(delta):
	if player:
		if $Timer.is_stopped():
			if player.direction != Vector3() and player.is_on_floor(): # If we move on the floor play the sound and adjust the footstep rate
				if player.crouch_speed != 1:
					$Timer.wait_time = timer_speed / player.crouch_multiplier
					play_sound(-35)
				elif player.sprint_speed != 1:
					$Timer.wait_time = timer_speed / player.sprint_multiplier
					play_sound(-15)
				else:
					$Timer.wait_time = timer_speed
					play_sound(-25)
				$Timer.start()
	
	if player.is_on_floor() and not player.grounded: # Sound when landing
		var volume = clamp((player.gravity_vec.y * -1)-10, -10, 5)
		play_sound(volume)

func play_sound(volume): # To avoid the sound from clipping, we generate a new audio node each time then we delete it
	var audio_node = AudioStreamPlayer.new()
	var sound = randi() % footstep_sounds.size() # Pick a random sound
	audio_node.stream = footstep_sounds[sound]
	audio_node.volume_db = volume
	audio_node.pitch_scale = rand_range(0.95, 1.05)
	add_child(audio_node)
	audio_node.play()
	yield(get_tree().create_timer(2), "timeout")
	audio_node.queue_free()
