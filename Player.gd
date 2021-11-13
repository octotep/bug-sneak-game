extends KinematicBody2D


export var run_speed = Vector2(150.0, 350.0)
export var crawl_speed = Vector2(75.0, 350.0)
onready var gravity = ProjectSettings.get("physics/2d/default_gravity")

const FLOOR_NORMAL = Vector2.UP
const FLOOR_DETECT_DISTANCE = 20.0

var _velocity = Vector2.ZERO

enum STATE {
	IDLE,
	RUNNING,
	STOPPING,
	START_JUMP,
	MID_JUMP,
	FALLING,
	LANDING,
	CROUCHING,
	CRAWLING,
}
var _state = STATE.IDLE

func get_direction():
	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = 0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		y = -1 # going uuuupppppppp
	return Vector2(x, y)

func _physics_process(delta):
	var is_crouching = Input.is_action_pressed("down") and is_on_floor()

	var speed = run_speed
	if is_crouching:
		speed = crawl_speed
	
	var direction = get_direction()
	_velocity.x = direction.x * speed.x
	if direction.y != 0.0:
		_velocity.y = direction.y * speed.y
	
	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	_velocity = move_and_slide_with_snap(_velocity, snap_vector, FLOOR_NORMAL, false, 4, 0.9, false)
	
	_velocity.y += gravity * delta
	
	# Update floor animations based on x value
	if _velocity.x > 0:
		$AnimatedSprite.set_flip_h(false)
	elif _velocity.x < 0:
		$AnimatedSprite.set_flip_h(true)
	
	print(_state == STATE.START_JUMP)
	print(_velocity.y)
	print(is_on_floor())
	print()
	
	if _velocity.x != 0 and is_on_floor() and not is_crouching:
		$AnimatedSprite.play("run")
		_state = STATE.RUNNING
	elif _velocity.x == 0 and _state == STATE.RUNNING and is_on_floor():
		$AnimatedSprite.play("stop")
		_state = STATE.STOPPING
	elif _velocity.x == 0 and _state == STATE.STOPPING and is_on_floor() and $AnimatedSprite.frame == 1:
		$AnimatedSprite.play("idle")
		_state = STATE.IDLE
	elif Input.is_action_just_pressed("jump"):
		$AnimatedSprite.play("jump")
		_state = STATE.START_JUMP
	elif _velocity.y >= -100 and not is_on_floor() and _state == STATE.START_JUMP:
		$AnimatedSprite.play("jump_mid")
		_state = STATE.MID_JUMP
	elif _velocity.y >= 0 and not is_on_floor():
		$AnimatedSprite.play("fall")
		_state = STATE.FALLING
	elif (_state == STATE.FALLING or _state == STATE.MID_JUMP or _state == STATE.START_JUMP) and is_on_floor():
		$AnimatedSprite.play("land")
		_state = STATE.LANDING
	elif _state == STATE.LANDING and $AnimatedSprite.frame == 1:
		if _velocity.x != 0:
			$AnimatedSprite.play("run")
			_state = STATE.RUNNING
		elif _velocity.x == 0:
			$AnimatedSprite.play("idle")
			_state = STATE.IDLE
	elif _velocity.x == 0 and is_on_floor() and is_crouching:
		$AnimatedSprite.play("crouch")
		_state = STATE.CROUCHING
	elif _velocity.x == 0 and is_on_floor() and Input.is_action_just_released("down"):
		$AnimatedSprite.play("idle")
		_state = STATE.IDLE
	elif _velocity.x != 0 and is_on_floor() and is_crouching:
		$AnimatedSprite.play("crawl")
		_state = STATE.CRAWLING
