extends KinematicBody

onready var camera = $Pivot/Camera
onready var interact_ray = $Pivot/Camera/RayCast
onready var inventory = $Inventory

const GRAVITY = -30
const MAX_WALK_SPEED = 8
const MAX_SPRINT_SPEED = 14
const ACCELERATION = 0.3
const JUMP_SPEED = 12

var mouse_sensitivity = 0.002  # radians/pixel
var first_person = true

var velocity := Vector3()
var jump := false
var sprinting := false

var hover_object

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta) -> void:
	movement(delta)

func _unhandled_input(event):
	# Camera rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		$Pivot.rotation_degrees.x = clamp(
			$Pivot.rotation_degrees.x,
			-85,
			85
		)
	# Camera positions
	if event.is_action_pressed("change_camera"):
		first_person = !first_person
		if first_person:
			camera.translation = Vector3.ZERO
		else:
			camera.translation = Vector3(0.75, 0, 2.25)
	
	# Mouse capturing
	if event.is_action_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("left_click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var hover_object = interact_ray.get_collider()
	if hover_object:
		var interaction_text = ("[%s] " + hover_object.get_interaction_text()) \
			% InputMap.get_action_list("interact")[0].as_text()
		Variables.interact_label.text = interaction_text
		
		if event.is_action_pressed("interact"):
			hover_object.on_interact()
	else:
		Variables.interact_label.text = ""


func movement(delta) -> void:
	jump = false
	if Input.is_action_just_pressed("jump"):
		jump = true
	if Input.is_action_pressed("sprint"):
		sprinting = true
	else:
		sprinting = false
	
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


func get_input_direction() -> Vector3:
	var input_direction := Vector3()
	
	if Input.is_action_pressed("forward"):
		input_direction += -camera.global_transform.basis.z
	if Input.is_action_pressed("backward"):
		input_direction += camera.global_transform.basis.z
	if Input.is_action_pressed("left"):
		input_direction += -camera.global_transform.basis.x
	if Input.is_action_pressed("right"):
		input_direction += camera.global_transform.basis.x
	
	input_direction.y = 0 # Else the player controls like a spectator
	input_direction = input_direction.normalized()

	return input_direction
