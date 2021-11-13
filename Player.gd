extends KinematicBody2D


export var speed = Vector2(150.0, 350.0)
onready var gravity = ProjectSettings.get("physics/2d/default_gravity")

const FLOOR_NORMAL = Vector2.UP
const FLOOR_DETECT_DISTANCE = 20.0

var _velocity = Vector2.ZERO

func get_direction():
	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = 0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		y = -1 # going uuuupppppppp
	return Vector2(x, y)

func _physics_process(delta):
	var direction = get_direction()
	_velocity.x = direction.x * speed.x
	if direction.y != 0.0:
		_velocity.y = direction.y * speed.y
	
	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	_velocity = move_and_slide_with_snap(_velocity, snap_vector, FLOOR_NORMAL, false, 4, 0.9, false)
	
	_velocity.y += gravity * delta
