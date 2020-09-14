extends KinematicBody

var move_speed = 10
var velocity : Vector3 = Vector3.ZERO
var mouse_delta = Vector2.ZERO

var look_sensitivity = 10
var min_look_angle = -90
var max_look_angle = 90

onready var camera = $Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	_handle_movement(delta)
	_handle_camera(delta)

func _handle_movement(delta):
	var z_axis = - int(Input.is_action_pressed("forward")) + int(Input.is_action_pressed("backward"))
	var x_axis = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	var y_axis = int(Input.is_action_pressed("up")) - int(Input.is_action_pressed("down"))
	
	var input = Vector3(x_axis, y_axis, z_axis).normalized();
	
	var forward_basis = transform.basis.z
	var right_basis = transform.basis.x
	var up_basis = transform.basis.y
	
	var relative_direction = (forward_basis * input.z + right_basis * input.x + up_basis * input.y)
	
	velocity.x = relative_direction.x * move_speed
	velocity.y = relative_direction.y * move_speed
	velocity.z = relative_direction.z * move_speed
	
	move_and_slide(velocity, Vector3.UP)


func _handle_camera(delta):
	camera.rotation_degrees.x -= mouse_delta.y * look_sensitivity * delta
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, min_look_angle, max_look_angle)
	
	rotation_degrees.y -= mouse_delta.x * look_sensitivity * delta
	
	mouse_delta = Vector2.ZERO


func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
