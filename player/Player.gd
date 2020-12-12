extends KinematicBody

var mouse_sensitivity = 1

var walk_speed = 8
var sprint_multiplier = 1.5
var crouch_multiplier = 0.5

var ground_acceleration = 8
var air_acceleration = 2
var acceleration = ground_acceleration

var jump_height = 4.5
var gravity = 9.8

var stick_amount = 10

var direction = Vector3()
var velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()
var grounded = true
var sprint_speed = 1
var crouch_speed = 1
var crouch_animation_speed = 1

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
		sprint_speed = 1 # The control key cancel the shift key if it is pressed
		crouch(true)
	else:
		crouch_speed = 1
		crouch(false)
	
func _physics_process(delta):
	if is_on_floor():
		gravity_vec = -get_floor_normal() * stick_amount # The gravity is in the direction of the ground to climb it more easily
		acceleration = ground_acceleration
		grounded = true
	else:
		if grounded: # Just before leaving the floor we reset the gravity vector to avoid falling in an angle
			gravity_vec = Vector3.ZERO
			grounded = false
		else:
			gravity_vec += Vector3.DOWN * gravity * delta
			acceleration = air_acceleration
	
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		grounded = false
		gravity_vec = Vector3.UP * jump_height
	
	velocity = velocity.linear_interpolate(direction * walk_speed * crouch_speed * sprint_speed, acceleration * delta) # acceleration
	movement.z = velocity.z + gravity_vec.z # The gravity is added
	movement.x = velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	move_and_slide(movement, Vector3.UP)

func crouch(crouched):
	if crouched:
		$CollisionShape.shape.height = 0.5
		$MeshInstance.mesh.mid_height = 0.5
		$Head.translation.y = 0.4
	else:
		$CollisionShape.shape.height = 1
		$MeshInstance.mesh.mid_height = 1
		$Head.translation.y = 0.8
