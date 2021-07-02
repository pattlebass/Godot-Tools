extends KinematicBody

onready var camera = $Pivot/Camera

const GRAVITY = -30
const MAX_WALK_SPEED = 8
const MAX_SPRINT_SPEED = 14
const ACCELERATION = 0.3
const JUMP_SPEED = 12

var mouse_sensitivity = 0.002  # radians/pixel
var first_person = true

var velocity:Vector3 = Vector3()
var jump = false
var sprinting = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func get_input_direction():
	jump = false
	if Input.is_action_just_pressed("Jump"):
		jump = true
	if Input.is_action_pressed("Sprint"):
		sprinting = true
	else:
		sprinting = false
	
	
	var input_direction = Vector3()
	
	if Input.is_action_pressed("Forward"):
		input_direction += -camera.global_transform.basis.z
	if Input.is_action_pressed("Backward"):
		input_direction += camera.global_transform.basis.z
	if Input.is_action_pressed("Left"):
		input_direction += -camera.global_transform.basis.x
	if Input.is_action_pressed("Right"):
		input_direction += camera.global_transform.basis.x
	
	input_direction = input_direction.normalized()
	
	return input_direction


func _unhandled_input(event):
	# Camera rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.2, 1.2)
	# Camera positions
	if event.is_action_pressed("Change_camera"):
		first_person = !first_person
		
		if first_person:
			camera.translation = Vector3.ZERO
		else:
			camera.translation = Vector3(0.75, 0, 2.25)
	
	# Mouse capturing
	if event.is_action_pressed("Pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("Left_click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
func _physics_process(delta):
	movement(delta)


func movement(delta):
	velocity.y += GRAVITY * delta
	var desired_velocity = get_input_direction()
	
	if jump and is_on_floor():
		velocity.y = JUMP_SPEED
	if sprinting and is_on_floor():
		desired_velocity *= MAX_SPRINT_SPEED
	else:
		desired_velocity *= MAX_WALK_SPEED
	
	velocity.x = lerp(velocity.x, desired_velocity.x, ACCELERATION)
	velocity.z = lerp(velocity.z, desired_velocity.z, ACCELERATION)
	
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
	
