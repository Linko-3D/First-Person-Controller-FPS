extends KinematicBody

var mouse_sensitivity = 1

export var speed = 8
export var ground_acceleration = 8
export var air_acceleration = 2
var acceleration = ground_acceleration
export var jump_height = 4.5
export var gravity = 9.8
export var stick_amount = 10

var direction = Vector3()
var velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()
var grounded = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity / 10
		$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x - event.relative.y * mouse_sensitivity / 10, -90, 90)

	direction = Vector3()
	direction.z = -Input.get_action_strength("ui_up") + Input.get_action_strength("ui_down")
	direction.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	direction = direction.normalized().rotated(Vector3.UP, rotation.y)

func _physics_process(delta):
	if is_on_floor():
		gravity_vec = -get_floor_normal() * stick_amount
		acceleration = ground_acceleration
		grounded = true
	else:
		if grounded:
			gravity_vec = Vector3.ZERO
			grounded = false
		else:
			gravity_vec += Vector3.DOWN * gravity * delta
			acceleration = air_acceleration
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		grounded = false
		gravity_vec = Vector3.UP * jump_height
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	movement.z = velocity.z + gravity_vec.z
	movement.x = velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	move_and_slide(movement, Vector3.UP)
