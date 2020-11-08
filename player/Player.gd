extends KinematicBody

var mouse_sensitivity = 1

export var speed = 8
export var ground_acceleration = 8
export var air_acceleration = 2
var acceleration = ground_acceleration
export var jump_height = 4.5
export var gravity = 9.8
export var stick_amount = 10
export var sprint_multiplier = 1.5
export var crouch_multiplier = 0.5

var direction = Vector3()
var velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()
var grounded = true
var sprint_speed = 1
var crouch_speed = 1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity / 10
		$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x - event.relative.y * mouse_sensitivity / 10, -90, 90)
	
	direction = Vector3()
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_UP):
		direction.z = -1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.z = 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_LEFT):
		direction.x = -1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x = 1
	
	direction = direction.normalized().rotated(Vector3.UP, rotation.y)
	
	if Input.is_key_pressed(KEY_SHIFT):
		sprint_speed = sprint_multiplier
	else:
		sprint_speed = 1
	
	if Input.is_key_pressed(KEY_CONTROL):
		crouch_speed = crouch_multiplier
		sprint_speed = 1
	else:
		crouch_speed = 1	
	
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
	
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		grounded = false
		gravity_vec = Vector3.UP * jump_height
	
	velocity = velocity.linear_interpolate(direction * speed * crouch_speed * sprint_speed, acceleration * delta)
	movement.z = velocity.z + gravity_vec.z
	movement.x = velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	move_and_slide(movement, Vector3.UP)
